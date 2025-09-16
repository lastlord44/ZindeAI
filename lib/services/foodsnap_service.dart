import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Besin değerleri sonuç modeli
class FoodSnapResult {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String estimatedFoodName;
  final String source; // 'OpenFoodFacts' veya 'LLM'

  FoodSnapResult({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.estimatedFoodName,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein_g': proteinG,
    'carbs_g': carbsG,
    'fat_g': fatG,
    'estimated_food_name': estimatedFoodName,
    'source': source,
  };

  factory FoodSnapResult.fromJson(Map<String, dynamic> json) {
    return FoodSnapResult(
      calories: (json['calories'] ?? 0).toDouble(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      estimatedFoodName: json['estimated_food_name'] ?? '',
      source: json['source'] ?? '',
    );
  }

  @override
  String toString() =>
      'FoodSnapResult($estimatedFoodName: ${calories}kcal, '
      'P:${proteinG}g, C:${carbsG}g, F:${fatG}g from $source)';
}

/// FoodSnap servis sınıfı - Yemek analizi için
class FoodSnapService {
  // API endpoint'leri
  static const String _openFoodFactsSearchUrl =
      'https://world.openfoodfacts.org/cgi/search.pl';
  static const String _groqApiUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // Groq API key (constructor'dan alınacak)
  final String groqApiKey;

  // HTTP client (test için mock'lanabilir)
  final http.Client httpClient;

  // Cache mekanizması - key: hash(imageBytes + caption)
  final Map<String, FoodSnapResult> _cache = {};

  FoodSnapService({required this.groqApiKey, http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  /// Ana analiz fonksiyonu
  Future<FoodSnapResult> analyzeImageWithCaption(
    Uint8List imageBytes,
    String caption,
  ) async {
    // 1. Cache key oluştur
    final cacheKey = _generateCacheKey(imageBytes, caption);

    // 2. Cache'te var mı kontrol et
    if (_cache.containsKey(cacheKey)) {
      print('[FoodSnap] Cache hit for: $caption');
      return _cache[cacheKey]!;
    }

    // 3. Önce OpenFoodFacts'te ara
    try {
      final openFoodResult = await _searchOpenFoodFacts(caption);
      if (openFoodResult != null) {
        _cache[cacheKey] = openFoodResult;
        return openFoodResult;
      }
    } catch (e) {
      print('[FoodSnap] OpenFoodFacts error: $e');
    }

    // 4. Fallback: Groq LLM kullan
    try {
      final groqResult = await _analyzeWithGroq(caption);
      _cache[cacheKey] = groqResult;
      return groqResult;
    } catch (e) {
      print('[FoodSnap] Groq error: $e');
      // Default değerler dön
      return FoodSnapResult(
        calories: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
        estimatedFoodName: caption,
        source: 'Error',
      );
    }
  }

  /// Cache key üretici
  String _generateCacheKey(Uint8List imageBytes, String caption) {
    final bytes = utf8.encode(caption) + imageBytes.take(100).toList();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// OpenFoodFacts'te arama yap
  Future<FoodSnapResult?> _searchOpenFoodFacts(String caption) async {
    // Türkçe ürün adını İngilizce'ye basit çeviri (geliştirilmeli)
    final searchTerm = _simplifySearchTerm(caption);

    final response = await httpClient.get(
      Uri.parse(
        '$_openFoodFactsSearchUrl?'
        'search_terms=$searchTerm&'
        'search_simple=1&'
        'action=process&'
        'json=1&'
        'page_size=5&'
        'page=1',
      ),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body);
    final products = data['products'] as List?;

    if (products == null || products.isEmpty) {
      return null;
    }

    // İlk ürünü al ve besin değerlerini parse et
    final product = products.first;
    final nutriments = product['nutriments'] ?? {};

    // 100g başına değerler
    final energyKcal = (nutriments['energy-kcal_100g'] ?? 0).toDouble();
    final proteins = (nutriments['proteins_100g'] ?? 0).toDouble();
    final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
    final fat = (nutriments['fat_100g'] ?? 0).toDouble();

    // Eğer değerler 0 ise null dön (geçersiz veri)
    if (energyKcal == 0 && proteins == 0 && carbs == 0 && fat == 0) {
      return null;
    }

    return FoodSnapResult(
      calories: energyKcal,
      proteinG: proteins,
      carbsG: carbs,
      fatG: fat,
      estimatedFoodName: product['product_name'] ?? caption,
      source: 'OpenFoodFacts',
    );
  }

  /// Groq LLM ile analiz yap
  Future<FoodSnapResult> _analyzeWithGroq(String caption) async {
    final systemPrompt = '''
Sen bir beslenme uzmanısın. Verilen yemek açıklamasına göre 100 gram için 
yaklaşık besin değerlerini tahmin et. Cevabını sadece ve sadece şu JSON 
formatında ver, başka hiçbir açıklama ekleme:

{
  "calories": <number>,
  "protein_g": <number>,
  "carbs_g": <number>,
  "fat_g": <number>,
  "estimated_food_name": "<string>"
}

Türk yemeklerini iyi biliyorsun. Değerler 100 gram için olmalı.
''';

    final userPrompt = 'Yemek: $caption';

    final requestBody = {
      'model': 'llama-3.1-8b-instant',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': 0.3,
      'max_tokens': 150,
      'response_format': {'type': 'json_object'},
    };

    final response = await httpClient.post(
      Uri.parse(_groqApiUrl),
      headers: {
        'Authorization': 'Bearer $groqApiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final content = data['choices'][0]['message']['content'];
    final nutritionData = json.decode(content);

    return FoodSnapResult(
      calories: (nutritionData['calories'] ?? 0).toDouble(),
      proteinG: (nutritionData['protein_g'] ?? 0).toDouble(),
      carbsG: (nutritionData['carbs_g'] ?? 0).toDouble(),
      fatG: (nutritionData['fat_g'] ?? 0).toDouble(),
      estimatedFoodName: nutritionData['estimated_food_name'] ?? caption,
      source: 'LLM',
    );
  }

  /// Basit arama terimi sadeleştirici
  String _simplifySearchTerm(String caption) {
    // Türkçe -> İngilizce bazı yaygın yemekler (genişletilebilir)
    final Map<String, String> translations = {
      'pilav': 'rice',
      'köfte': 'meatball',
      'kebap': 'kebab',
      'çorba': 'soup',
      'salata': 'salad',
      'ekmek': 'bread',
      'tavuk': 'chicken',
      'et': 'meat',
      'balık': 'fish',
      'makarna': 'pasta',
      'börek': 'borek',
      'kuru fasulye': 'white beans',
      'mercimek': 'lentil',
      'yoğurt': 'yogurt',
      'ayran': 'ayran yogurt drink',
    };

    String result = caption.toLowerCase();
    translations.forEach((tr, en) {
      result = result.replaceAll(tr, en);
    });

    // URL encode için temizle
    return Uri.encodeComponent(result.trim());
  }

  /// Cache'i temizle
  void clearCache() {
    _cache.clear();
  }

  /// Cache boyutunu öğren
  int getCacheSize() => _cache.length;
}
