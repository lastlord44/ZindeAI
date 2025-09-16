import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Service for integrating with Groq API for food analysis
class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static String? _apiKey;

  /// Initialize the service with API key (to be loaded from Firebase Remote Config)
  static void initialize(String apiKey) {
    _apiKey = apiKey;
  }

  /// Analyze food description and estimate macros
  static Future<Map<String, dynamic>?> analyzeFoodDescription(
    String description,
  ) async {
    if (_apiKey == null) {
      debugPrint('Groq API key not initialized');
      return null;
    }

    final prompt = '''
User ate: $description
Estimate macros for Turkish cuisine in JSON format:
{"kcal": 0, "protein": 0, "carbs": 0, "fat": 0, "confidence": 0.8}
Return only valid JSON, no other text.
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gemma2-9b-it',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'response_format': {'type': 'json_object'},
          'max_tokens': 1000,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        debugPrint('Groq API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error calling Groq API: $e');
      return null;
    }
  }

  /// Analyze food image with description (future feature)
  static Future<Map<String, dynamic>?> analyzeFoodImage(
    String imagePath,
    String description,
  ) async {
    // TODO: Implement image analysis when vision models are available
    // For now, fallback to text analysis
    return analyzeFoodDescription(description);
  }

  /// Get available models
  static Future<List<String>?> getAvailableModels() async {
    if (_apiKey == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.groq.com/openai/v1/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((model) => model['id'] as String)
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting models: $e');
    }
    return null;
  }
}