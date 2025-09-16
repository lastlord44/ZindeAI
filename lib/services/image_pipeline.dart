import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Image processing pipeline for food photos
/// Handles EXIF fix, resize, thumbnail generation, and average hash calculation
class ImagePipeline {
  static const int _maxWidth = 1280;
  static const int _maxHeight = 1280;
  static const int _thumbnailSize = 256;
  static const int _hashSize = 8;
  
  /// Process image through the complete pipeline
  Future<ProcessedImage> processImage(File imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        throw ImageProcessingException('DECODE_FAILED', 'Failed to decode image');
      }
      
      // Fix EXIF orientation
      final img.Image orientedImage = _fixExifOrientation(originalImage);
      
      // Resize main image
      final img.Image resizedImage = _resizeImage(orientedImage, _maxWidth, _maxHeight);
      
      // Generate thumbnail
      final img.Image thumbnail = _generateThumbnail(orientedImage, _thumbnailSize);
      
      // Calculate average hash
      final String averageHash = _calculateAverageHash(resizedImage);
      
      // Encode processed images
      final Uint8List resizedBytes = img.encodeJpg(resizedImage, quality: 85);
      final Uint8List thumbnailBytes = img.encodeJpg(thumbnail, quality: 75);
      
      return ProcessedImage(
        originalSize: ImageSize(originalImage.width, originalImage.height),
        resizedSize: ImageSize(resizedImage.width, resizedImage.height),
        thumbnailSize: ImageSize(thumbnail.width, thumbnail.height),
        resizedBytes: resizedBytes,
        thumbnailBytes: thumbnailBytes,
        averageHash: averageHash,
        fileSize: bytes.length,
        processedFileSize: resizedBytes.length,
        thumbnailFileSize: thumbnailBytes.length,
      );
    } catch (e) {
      if (e is ImageProcessingException) rethrow;
      throw ImageProcessingException('PROCESSING_FAILED', 'Image processing failed: $e');
    }
  }
  
  /// Fix EXIF orientation
  img.Image _fixExifOrientation(img.Image image) {
    // Get EXIF data if available
    final exif = image.exif;
    if (exif.isEmpty) return image;
    
    // Check orientation tag (274)
    final orientationTag = exif['Image Orientation']?.toString();
    if (orientationTag == null) return image;
    
    final int orientation = int.tryParse(orientationTag) ?? 1;
    
    switch (orientation) {
      case 2:
        return img.flipHorizontal(image);
      case 3:
        return img.copyRotate(image, angle: 180);
      case 4:
        return img.flipVertical(image);
      case 5:
        return img.flipHorizontal(img.copyRotate(image, angle: 90));
      case 6:
        return img.copyRotate(image, angle: 90);
      case 7:
        return img.flipHorizontal(img.copyRotate(image, angle: 270));
      case 8:
        return img.copyRotate(image, angle: 270);
      default:
        return image;
    }
  }
  
  /// Resize image maintaining aspect ratio
  img.Image _resizeImage(img.Image image, int maxWidth, int maxHeight) {
    final int width = image.width;
    final int height = image.height;
    
    if (width <= maxWidth && height <= maxHeight) {
      return image;
    }
    
    final double aspectRatio = width / height;
    int newWidth, newHeight;
    
    if (width > height) {
      newWidth = maxWidth;
      newHeight = (maxWidth / aspectRatio).round();
    } else {
      newHeight = maxHeight;
      newWidth = (maxHeight * aspectRatio).round();
    }
    
    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
  }
  
  /// Generate thumbnail
  img.Image _generateThumbnail(img.Image image, int size) {
    final int width = image.width;
    final int height = image.height;
    final int minDimension = width < height ? width : height;
    
    // Crop to square from center
    final img.Image cropped = img.copyCrop(
      image,
      x: (width - minDimension) ~/ 2,
      y: (height - minDimension) ~/ 2,
      width: minDimension,
      height: minDimension,
    );
    
    // Resize to thumbnail size
    return img.copyResize(
      cropped,
      width: size,
      height: size,
      interpolation: img.Interpolation.linear,
    );
  }
  
  /// Calculate average hash for duplicate detection
  String _calculateAverageHash(img.Image image) {
    // Resize to 8x8 for hash calculation
    final img.Image hashImage = img.copyResize(
      image,
      width: _hashSize,
      height: _hashSize,
      interpolation: img.Interpolation.average,
    );
    
    // Convert to grayscale
    final img.Image grayscale = img.grayscale(hashImage);
    
    // Calculate average pixel value
    int sum = 0;
    final int totalPixels = _hashSize * _hashSize;
    
    for (int y = 0; y < _hashSize; y++) {
      for (int x = 0; x < _hashSize; x++) {
        final pixel = grayscale.getPixel(x, y);
        sum += pixel.r.toInt();
      }
    }
    
    final double average = sum / totalPixels;
    
    // Generate hash string
    String hash = '';
    for (int y = 0; y < _hashSize; y++) {
      for (int x = 0; x < _hashSize; x++) {
        final pixel = grayscale.getPixel(x, y);
        hash += pixel.r > average ? '1' : '0';
      }
    }
    
    return hash;
  }
  
  /// Convert binary hash to hexadecimal
  String binaryToHex(String binaryHash) {
    if (binaryHash.length != 64) {
      throw ArgumentError('Binary hash must be 64 characters long');
    }
    
    String hex = '';
    for (int i = 0; i < binaryHash.length; i += 4) {
      final String chunk = binaryHash.substring(i, i + 4);
      final int value = int.parse(chunk, radix: 2);
      hex += value.toRadixString(16);
    }
    
    return hex.toUpperCase();
  }
  
  /// Convert hexadecimal hash back to binary
  String hexToBinary(String hexHash) {
    String binary = '';
    for (int i = 0; i < hexHash.length; i++) {
      final int value = int.parse(hexHash[i], radix: 16);
      binary += value.toRadixString(2).padLeft(4, '0');
    }
    return binary;
  }
  
  /// Calculate quality score of image
  double calculateQualityScore(img.Image image) {
    final int width = image.width;
    final int height = image.height;
    final int totalPixels = width * height;
    
    // Size score (larger is better, but with diminishing returns)
    double sizeScore = (totalPixels / (1280 * 1280)).clamp(0.0, 1.0);
    
    // Aspect ratio score (closer to square is better for food photos)
    double aspectRatio = width / height;
    double aspectScore = 1.0 - (aspectRatio - 1.0).abs().clamp(0.0, 1.0);
    
    // Simple sharpness estimation (edge detection)
    double sharpnessScore = _calculateSharpness(image);
    
    return (sizeScore * 0.3 + aspectScore * 0.2 + sharpnessScore * 0.5).clamp(0.0, 1.0);
  }
  
  /// Simple sharpness calculation using edge detection
  double _calculateSharpness(img.Image image) {
    // Resize to smaller size for performance
    final img.Image small = img.copyResize(image, width: 100, height: 100);
    final img.Image gray = img.grayscale(small);
    
    double edgeSum = 0.0;
    int edgeCount = 0;
    
    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        final center = gray.getPixel(x, y).r;
        final right = gray.getPixel(x + 1, y).r;
        final bottom = gray.getPixel(x, y + 1).r;
        
        final double edgeX = (right - center).abs().toDouble();
        final double edgeY = (bottom - center).abs().toDouble();
        
        edgeSum += sqrt(edgeX * edgeX + edgeY * edgeY);
        edgeCount++;
      }
    }
    
    return edgeCount > 0 ? (edgeSum / edgeCount / 255.0).clamp(0.0, 1.0) : 0.0;
  }
}

/// Processed image data container
class ProcessedImage {
  final ImageSize originalSize;
  final ImageSize resizedSize;
  final ImageSize thumbnailSize;
  final Uint8List resizedBytes;
  final Uint8List thumbnailBytes;
  final String averageHash;
  final int fileSize;
  final int processedFileSize;
  final int thumbnailFileSize;
  
  const ProcessedImage({
    required this.originalSize,
    required this.resizedSize,
    required this.thumbnailSize,
    required this.resizedBytes,
    required this.thumbnailBytes,
    required this.averageHash,
    required this.fileSize,
    required this.processedFileSize,
    required this.thumbnailFileSize,
  });
  
  /// Compression ratio for main image
  double get compressionRatio => fileSize > 0 ? processedFileSize / fileSize : 1.0;
  
  /// Thumbnail compression ratio
  double get thumbnailCompressionRatio => fileSize > 0 ? thumbnailFileSize / fileSize : 1.0;
  
  @override
  String toString() {
    return 'ProcessedImage('
        'original: ${originalSize.width}x${originalSize.height}, '
        'resized: ${resizedSize.width}x${resizedSize.height}, '
        'thumbnail: ${thumbnailSize.width}x${thumbnailSize.height}, '
        'hash: $averageHash, '
        'compression: ${(compressionRatio * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// Image size container
class ImageSize {
  final int width;
  final int height;
  
  const ImageSize(this.width, this.height);
  
  double get aspectRatio => width / height;
  int get totalPixels => width * height;
  
  @override
  String toString() => '${width}x$height';
}

/// Custom exception for image processing operations
class ImageProcessingException implements Exception {
  final String code;
  final String message;
  
  const ImageProcessingException(this.code, this.message);
  
  @override
  String toString() => 'ImageProcessingException($code): $message';
}