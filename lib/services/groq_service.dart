import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';

class GroqService {
  static GroqService? _instance;
  static GroqService get instance => _instance ??= GroqService._();
  GroqService._();
  
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'gemma2-9b-it';
  
  String? _apiKey;
  
  /// Initialize Groq service with API key from Firebase Remote Config
  Future<void> initialize() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
    try {
      await remoteConfig.fetchAndActivate();
      _apiKey = remoteConfig.getString('groq_api_key');
    } catch (e) {
      throw Exception('Failed to fetch Groq API key: $e');
    }
  }
  
  /// Estimate macros for food description
  Future<Map<String, dynamic>> estimateMacros(String foodDescription) async {
    if (_apiKey == null) {
      throw Exception('Groq API key not initialized');
    }
    
    final prompt = '''
User ate: $foodDescription
Estimate macros in JSON format for Turkish cuisine:
{"kcal": 0, "protein": 0, "carbs": 0, "fat": 0}
''';
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'response_format': {'type': 'json_object'},
          'max_tokens': 150,
          'temperature': 0.3,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw Exception('Groq API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to estimate macros: $e');
    }
  }
}