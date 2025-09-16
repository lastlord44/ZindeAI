import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/services/foodsnap_service.dart';

void main() {
  group('FoodSnapService Tests', () {
    late FoodSnapService service;
    late Uint8List testImageBytes;
    const String testGroqApiKey = 'test-groq-api-key';

    setUp(() {
      // Test için dummy image bytes
      testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    });

    test('OpenFoodFacts başarılı arama testi', () async {
      // Mock HTTP client
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('openfoodfacts.org')) {
          // OpenFoodFacts mock response
          final mockResponse = {
            'products': [
              {
                'product_name': 'Turkish Rice Pilav',
                'nutriments': {
                  'energy-kcal_100g': 130,
                  'proteins_100g': 2.7,
                  'carbohydrates_100g': 28.2,
                  'fat_100g': 0.3,
                },
              },
            ],
          };
          return http.Response(json.encode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      service = FoodSnapService(
        groqApiKey: testGroqApiKey,
        httpClient: mockClient,
      );

      final result = await service.analyzeImageWithCaption(
        testImageBytes,
        'pilav',
      );

      expect(result.source, equals('OpenFoodFacts'));
      expect(result.calories, equals(130));
      expect(result.proteinG, equals(2.7));
      expect(result.carbsG, equals(28.2));
      expect(result.fatG, equals(0.3));
      expect(result.estimatedFoodName, equals('Turkish Rice Pilav'));
    });

    test('Groq LLM fallback testi', () async {
      // Mock HTTP client
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('openfoodfacts.org')) {
          // OpenFoodFacts boş sonuç dönsün
          return http.Response('{"products": []}', 200);
        } else if (request.url.toString().contains('groq.com')) {
          // Groq API mock response - content field'ı direkt string olarak ver
          final mockResponse = {
            'choices': [
              {
                'message': {
                  'content':
                      '{"calories": 215, "protein_g": 20.5, "carbs_g": 8.5, "fat_g": 11.2, "estimated_food_name": "Izgara Köfte"}',
                },
              },
            ],
          };
          return http.Response(json.encode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      service = FoodSnapService(
        groqApiKey: testGroqApiKey,
        httpClient: mockClient,
      );

      final result = await service.analyzeImageWithCaption(
        testImageBytes,
        'ızgara köfte',
      );

      expect(result.source, equals('LLM'));
      expect(result.calories, equals(215));
      expect(result.proteinG, equals(20.5));
      expect(result.carbsG, equals(8.5));
      expect(result.fatG, equals(11.2));
      expect(result.estimatedFoodName, equals('Izgara Köfte'));
    });

    test('Cache mekanizması testi', () async {
      // Mock HTTP client
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('openfoodfacts.org')) {
          return http.Response('{"products": []}', 200);
        } else if (request.url.toString().contains('groq.com')) {
          // Türkçe karakterleri escape et veya İngilizce kullan
          final mockResponse = {
            'choices': [
              {
                'message': {
                  'content':
                      '{"calories": 350, "protein_g": 8.5, "carbs_g": 45.2, "fat_g": 15.8, "estimated_food_name": "Spinach Borek"}',
                },
              },
            ],
          };
          return http.Response(json.encode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      service = FoodSnapService(
        groqApiKey: testGroqApiKey,
        httpClient: mockClient,
      );

      // İlk çağrı
      final result1 = await service.analyzeImageWithCaption(
        testImageBytes,
        'ıspanaklı börek',
      );

      expect(result1.calories, equals(350));
      expect(service.getCacheSize(), equals(1));

      // İkinci çağrı - cache'ten gelmeli
      final result2 = await service.analyzeImageWithCaption(
        testImageBytes,
        'ıspanaklı börek',
      );

      // Aynı sonuç olmalı
      expect(result2.calories, equals(result1.calories));
      expect(result2.proteinG, equals(result1.proteinG));
      expect(result2.carbsG, equals(result1.carbsG));
      expect(result2.fatG, equals(result1.fatG));

      // Cache boyutu hala 1 olmalı (aynı item)
      expect(service.getCacheSize(), equals(1));
    });

    test('Farklı caption ile cache miss testi', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('openfoodfacts.org')) {
          return http.Response('{"products": []}', 200);
        } else if (request.url.toString().contains('groq.com')) {
          // Caption'a göre farklı response - Türkçe karakterleri escape et
          final body = json.decode(request.body);
          final userMessage = body['messages'][1]['content'] as String;

          if (userMessage.toLowerCase().contains('mercimek')) {
            final mockResponse = {
              'choices': [
                {
                  'message': {
                    'content':
                        '{"calories": 140, "protein_g": 5.5, "carbs_g": 12.0, "fat_g": 3.5, "estimated_food_name": "Lentil Soup"}',
                  },
                },
              ],
            };
            return http.Response(json.encode(mockResponse), 200);
          } else if (userMessage.toLowerCase().contains('salata')) {
            final mockResponse = {
              'choices': [
                {
                  'message': {
                    'content':
                        '{"calories": 65, "protein_g": 5.5, "carbs_g": 12.0, "fat_g": 3.5, "estimated_food_name": "Shepherd Salad"}',
                  },
                },
              ],
            };
            return http.Response(json.encode(mockResponse), 200);
          }

          // Default response
          final mockResponse = {
            'choices': [
              {
                'message': {
                  'content':
                      '{"calories": 100, "protein_g": 5.5, "carbs_g": 12.0, "fat_g": 3.5, "estimated_food_name": "Unknown Food"}',
                },
              },
            ],
          };
          return http.Response(json.encode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      service = FoodSnapService(
        groqApiKey: testGroqApiKey,
        httpClient: mockClient,
      );

      // İlk yemek
      final result1 = await service.analyzeImageWithCaption(
        testImageBytes,
        'mercimek çorbası',
      );
      expect(result1.estimatedFoodName, equals('Lentil Soup'));
      expect(result1.calories, equals(140));

      // İkinci farklı yemek
      final result2 = await service.analyzeImageWithCaption(
        testImageBytes,
        'çoban salatası',
      );
      expect(result2.estimatedFoodName, equals('Shepherd Salad'));
      expect(result2.calories, equals(65));

      // Cache'te 2 item olmalı
      expect(service.getCacheSize(), equals(2));
    });

    test('API hata durumu testi', () async {
      final mockClient = MockClient((request) async {
        // Tüm istekler başarısız olsun
        return http.Response('Server Error', 500);
      });

      service = FoodSnapService(
        groqApiKey: testGroqApiKey,
        httpClient: mockClient,
      );

      final result = await service.analyzeImageWithCaption(
        testImageBytes,
        'test yemek',
      );

      // Hata durumunda default değerler
      expect(result.source, equals('Error'));
      expect(result.calories, equals(0));
      expect(result.proteinG, equals(0));
      expect(result.carbsG, equals(0));
      expect(result.fatG, equals(0));
    });

    test('Cache temizleme testi', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('openfoodfacts.org')) {
          // OpenFoodFacts boş sonuç
          return http.Response('{"products": []}', 200);
        } else if (request.url.toString().contains('groq.com')) {
          // Groq API her zaman bir response döndürsün - content direkt JSON string
          final mockResponse = {
            'choices': [
              {
                'message': {
                  'content':
                      '{"calories": 100, "protein_g": 5, "carbs_g": 10, "fat_g": 3, "estimated_food_name": "Test Yemek"}',
                },
              },
            ],
          };
          return http.Response(json.encode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      service = FoodSnapService(
        groqApiKey: testGroqApiKey,
        httpClient: mockClient,
      );

      // Cache'e birkaç item ekle
      await service.analyzeImageWithCaption(testImageBytes, 'yemek1');
      await service.analyzeImageWithCaption(
        Uint8List.fromList([6, 7, 8]), // Farklı image bytes
        'yemek2',
      );

      expect(service.getCacheSize(), equals(2));

      // Cache'i temizle
      service.clearCache();

      expect(service.getCacheSize(), equals(0));
    });

    test('FoodSnapResult JSON serialization testi', () {
      final result = FoodSnapResult(
        calories: 250.5,
        proteinG: 15.3,
        carbsG: 30.2,
        fatG: 8.7,
        estimatedFoodName: 'Test Yemek',
        source: 'LLM',
      );

      // toJson
      final json = result.toJson();
      expect(json['calories'], equals(250.5));
      expect(json['protein_g'], equals(15.3));
      expect(json['carbs_g'], equals(30.2));
      expect(json['fat_g'], equals(8.7));
      expect(json['estimated_food_name'], equals('Test Yemek'));
      expect(json['source'], equals('LLM'));

      // fromJson
      final recreated = FoodSnapResult.fromJson(json);
      expect(recreated.calories, equals(result.calories));
      expect(recreated.proteinG, equals(result.proteinG));
      expect(recreated.carbsG, equals(result.carbsG));
      expect(recreated.fatG, equals(result.fatG));
      expect(recreated.estimatedFoodName, equals(result.estimatedFoodName));
      expect(recreated.source, equals(result.source));
    });

    test('toString metodu testi', () {
      final result = FoodSnapResult(
        calories: 180,
        proteinG: 12.5,
        carbsG: 22.0,
        fatG: 5.5,
        estimatedFoodName: 'Menemen',
        source: 'OpenFoodFacts',
      );

      final str = result.toString();
      expect(str, contains('Menemen'));
      expect(str, contains('180'));
      expect(str, contains('12.5'));
      expect(str, contains('22.0'));
      expect(str, contains('5.5'));
      expect(str, contains('OpenFoodFacts'));
    });
  });
}
