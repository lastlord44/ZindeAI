import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePipeline {
  static const int _targetLongEdge = 1280;
  static const int _thumbnailSize = 256;

  /// Ana pipeline - tüm işlemleri koordine eder
  static Future<Map<String, dynamic>> process(File imageFile) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Temp dizini ana thread'de al
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Isolate'e gönderilecek parametreler
      final params = {
        'imagePath': imageFile.path,
        'tempDirPath': tempDir.path,
        'timestamp': timestamp,
      };

      // Isolate'de ağır işlemleri yap
      final result = await Isolate.run(() => _processInIsolate(params));

      stopwatch.stop();
      result['processingTime'] = stopwatch.elapsedMilliseconds;

      return result;
    } catch (e) {
      stopwatch.stop();
      return {
        'success': false,
        'error': e.toString(),
        'processingTime': stopwatch.elapsedMilliseconds,
      };
    }
  }

  /// Isolate içinde çalışan işlemler
  static Future<Map<String, dynamic>> _processInIsolate(
    Map<String, dynamic> params,
  ) async {
    try {
      final imagePath = params['imagePath'] as String;
      final tempDirPath = params['tempDirPath'] as String;
      final timestamp = params['timestamp'] as int;

      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // EXIF yön düzeltmesi
      final orientedImage = img.bakeOrientation(image);

      // Resize işlemi
      final resized = _resizeImage(orientedImage, _targetLongEdge);

      // Thumbnail oluştur
      final thumbnail = _createThumbnail(orientedImage, _thumbnailSize);

      // Basit hash oluştur
      final imageHash = _calculateAverageHash(thumbnail);

      // Dosyaları kaydet
      final resizedPath = path.join(tempDirPath, 'resized_$timestamp.jpg');
      final thumbnailPath = path.join(tempDirPath, 'thumb_$timestamp.jpg');

      await File(resizedPath).writeAsBytes(img.encodeJpg(resized, quality: 85));
      await File(
        thumbnailPath,
      ).writeAsBytes(img.encodeJpg(thumbnail, quality: 75));

      return {
        'success': true,
        'resizedPath': resizedPath,
        'thumbnailPath': thumbnailPath,
        'hash': imageHash,
        'originalWidth': orientedImage.width,
        'originalHeight': orientedImage.height,
        'resizedWidth': resized.width,
        'resizedHeight': resized.height,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Görsel boyutlandırma
  static img.Image _resizeImage(img.Image source, int maxDimension) {
    if (source.width <= maxDimension && source.height <= maxDimension) {
      return source;
    }

    final isLandscape = source.width > source.height;
    final targetWidth = isLandscape ? maxDimension : null;
    final targetHeight = isLandscape ? null : maxDimension;

    return img.copyResize(
      source,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear, // linear kullan
    );
  }

  /// Thumbnail oluşturma
  static img.Image _createThumbnail(img.Image source, int size) {
    // Önce kareye crop et
    final shortEdge = source.width < source.height
        ? source.width
        : source.height;
    final offsetX = (source.width - shortEdge) ~/ 2;
    final offsetY = (source.height - shortEdge) ~/ 2;

    final cropped = img.copyCrop(
      source,
      x: offsetX,
      y: offsetY,
      width: shortEdge,
      height: shortEdge,
    );

    // Sonra resize et
    return img.copyResize(
      cropped,
      width: size,
      height: size,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Average hash hesaplama - DÜZELTİLMİŞ
  static String _calculateAverageHash(img.Image image) {
    // 8x8'e küçült
    final tiny = img.copyResize(
      image,
      width: 8,
      height: 8,
      interpolation: img.Interpolation.linear, // average yerine linear
    );

    // Grayscale'e çevir ve ortalama hesapla
    num total = 0;
    final pixels = <int>[];

    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        final pixel = tiny.getPixel(x, y);
        // Yeni image API için düzeltme
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final gray = (r * 0.299 + g * 0.587 + b * 0.114).round();
        pixels.add(gray);
        total += gray;
      }
    }

    final average = total / 64;

    // Hash oluştur
    final hash = StringBuffer();
    for (final pixel in pixels) {
      hash.write(pixel >= average ? '1' : '0');
    }

    // Hex'e çevir
    final binary = hash.toString();
    final hex = StringBuffer();
    for (int i = 0; i < binary.length; i += 4) {
      final chunk = binary.substring(i, i + 4);
      hex.write(int.parse(chunk, radix: 2).toRadixString(16));
    }

    return hex.toString();
  }
}
