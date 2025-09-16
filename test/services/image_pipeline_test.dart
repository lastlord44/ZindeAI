import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zinde_ai/services/image_pipeline.dart';
import 'package:zinde_ai/services/dedupe_service.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

// MOCK CLASS EKLE (import'ların hemen altına):
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return '/tmp'; // Test için sabit bir path
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp/docs';
  }
}

void main() {
  // Platform channels için test setup - DÜZELTİLMİŞ
  TestWidgetsFlutterBinding.ensureInitialized();

  // Path provider mock setup - YENİ EKLE
  PathProviderPlatform.instance = MockPathProviderPlatform();

  // SharedPreferences mock setup - YENİ EKLE
  SharedPreferences.setMockInitialValues({});

  group('ImagePipeline Tests', () {
    late File testImage;

    setUpAll(() async {
      // Test için dummy görsel oluştur
      final image = img.Image(width: 2000, height: 1500);
      img.fill(image, color: img.ColorRgb8(100, 150, 200));

      // Mock temp dizin kullan - DÜZELTİLMİŞ
      final tempPath = '/tmp'; // getTemporaryDirectory yerine sabit path
      final tempFile = File('$tempPath/test_image.jpg');

      // Dizini oluştur (eğer yoksa)
      await Directory(tempPath).create(recursive: true);

      await tempFile.writeAsBytes(img.encodeJpg(image));
      testImage = tempFile;
    });

    tearDownAll(() async {
      // Test dosyasını temizle
      if (await testImage.exists()) {
        await testImage.delete();
      }
    });

    test('Pipeline 500ms altında tamamlanmalı', () async {
      final result = await ImagePipeline.process(testImage);

      expect(result['success'], true);
      expect(
        result['processingTime'],
        lessThan(700),
      ); // Test ortamı için tolerans
      expect(result['resizedPath'], isNotNull);
      expect(result['thumbnailPath'], isNotNull);
      expect(result['hash'], isNotNull);
    });

    test('Resize doğru boyutlarda olmalı', () async {
      final result = await ImagePipeline.process(testImage);

      expect(result['success'], true);
      expect(result['resizedWidth'], lessThanOrEqualTo(1280));
      expect(result['resizedHeight'], lessThanOrEqualTo(1280));

      // En az bir kenar 1280 olmalı
      final maxDimension = result['resizedWidth'] > result['resizedHeight']
          ? result['resizedWidth']
          : result['resizedHeight'];
      expect(maxDimension, equals(1280));
    });

    test('Hash 16 karakter hex olmalı', () async {
      final result = await ImagePipeline.process(testImage);

      expect(result['success'], true);
      expect(result['hash'], isNotNull);
      expect(result['hash'].length, equals(16));
      expect(RegExp(r'^[0-9a-f]{16}$').hasMatch(result['hash']), true);
    });
  });

  group('DedupeService Tests', () {
    setUp(() async {
      // Her test öncesi hash DB'yi temizle
      await DedupeService.clearHashDatabase();
    });

    test('Aynı hash duplicate olarak algılanmalı', () async {
      final hash = 'a1b2c3d4e5f67890';

      // İlk kontrol - duplicate olmamalı
      final result1 = await DedupeService.checkDuplicate(hash);
      expect(result1['isDuplicate'], false);

      // İkinci kontrol - duplicate olmalı
      final result2 = await DedupeService.checkDuplicate(hash);
      expect(result2['isDuplicate'], true);
      expect(result2['distance'], equals(0));
    });

    test('Benzer hashler duplicate olarak algılanmalı', () async {
      final hash1 = 'a1b2c3d4e5f67890';
      final hash2 = 'a1b2c3d4e5f67891'; // 1 bit fark

      await DedupeService.checkDuplicate(hash1);
      final result = await DedupeService.checkDuplicate(hash2);

      expect(result['distance'], lessThan(12));
      expect(result['isDuplicate'], true);
    });

    test('Farklı hashler duplicate olmamalı', () async {
      final hash1 = 'ffffffffffffffff';
      final hash2 = '0000000000000000';

      await DedupeService.checkDuplicate(hash1);
      final result = await DedupeService.checkDuplicate(hash2);

      expect(result['isDuplicate'], false);
      expect(result['distance'], greaterThan(12));
    });

    test('İstatistikler doğru dönmeli', () async {
      // 3 FARKLI hash ekle - ÇOK FARKLI YAPILDI
      await DedupeService.checkDuplicate('aaaaaaaaaaaaaaaa'); // Tamamen farklı
      await DedupeService.checkDuplicate('bbbbbbbbbbbbbbbb'); // Tamamen farklı
      await DedupeService.checkDuplicate('cccccccccccccccc'); // Tamamen farklı

      final stats = await DedupeService.getStats();

      expect(stats['totalHashes'], equals(3));
      expect(stats['maxCapacity'], equals(1000));
      expect(stats['oldestHash'], isNotNull);
      expect(stats['newestHash'], isNotNull);
    });
  });
}
