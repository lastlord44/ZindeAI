import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'services/camera_service.dart';
import 'services/foodsnap_service.dart';
import 'services/meal_template_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZindeAI Services Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ServicesDemoPage(),
    );
  }
}

class ServicesDemoPage extends StatefulWidget {
  @override
  _ServicesDemoPageState createState() => _ServicesDemoPageState();
}

class _ServicesDemoPageState extends State<ServicesDemoPage> {
  final mealService = MealTemplateService();
  final foodSnapService = FoodSnapService(groqApiKey: 'test-key');

  String _result = 'Servisleri test etmek için butonlara tıklayın...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ZindeAI Services Demo'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ZindeAI Servisleri',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Meal Template Service Test
            ElevatedButton(
              onPressed: _testMealTemplateService,
              child: Text('🍽️ Meal Template Service Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 10),

            // FoodSnap Service Test
            ElevatedButton(
              onPressed: _testFoodSnapService,
              child: Text('📸 FoodSnap Service Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 10),

            // Camera Service Test
            ElevatedButton(
              onPressed: _testCameraService,
              child: Text('📷 Camera Service Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 20),

            // Result Display
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(_result, style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  void _testMealTemplateService() {
    setState(() {
      _result = 'Meal Template Service test ediliyor...';
    });

    try {
      // Protein ağırlıklı kahvaltı önerisi
      final recommendation = mealService.recommendMeal(
        mealType: 'kahvalti',
        targetKcal: 400,
        goalType: GoalType.kiloVerme,
        macroPriority: MacroPriority.highProtein,
        tags: ['tok-tutan'],
      );

      setState(() {
        _result =
            '''
✅ Meal Template Service Başarılı!

🍽️ Önerilen Öğün: ${recommendation.template.name}
📊 Kalori: ${recommendation.template.totalKcal} kcal
🥩 Protein: ${recommendation.template.totalProtein.toStringAsFixed(1)}g
🍞 Karbonhidrat: ${recommendation.template.totalCarbs.toStringAsFixed(1)}g
🥑 Yağ: ${recommendation.template.totalFat.toStringAsFixed(1)}g
⭐ Eşleşme Skoru: ${(recommendation.matchScore * 100).toStringAsFixed(1)}%

📝 Öneriler:
${recommendation.suggestions.map((s) => '• $s').join('\n')}

🔄 Alternatifler:
${recommendation.alternatives.map((a) => '• $a').join('\n')}
        ''';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Meal Template Service Hatası: $e';
      });
    }
  }

  void _testFoodSnapService() async {
    setState(() {
      _result = 'FoodSnap Service test ediliyor...';
    });

    try {
      // Mock image bytes (gerçek uygulamada kamera'dan gelecek)
      final mockImageBytes = Uint8List.fromList(
        List.generate(1000, (index) => index % 256),
      );

      final result = await foodSnapService.analyzeImageWithCaption(
        mockImageBytes,
        'ıspanaklı börek',
      );

      setState(() {
        _result =
            '''
✅ FoodSnap Service Başarılı!

🍽️ Tahmin Edilen Yemek: ${result.estimatedFoodName}
📊 Kalori: ${result.calories} kcal
🥩 Protein: ${result.proteinG}g
🍞 Karbonhidrat: ${result.carbsG}g
🥑 Yağ: ${result.fatG}g
        ''';
      });
    } catch (e) {
      setState(() {
        _result = '❌ FoodSnap Service Hatası: $e';
      });
    }
  }

  void _testCameraService() {
    setState(() {
      _result = 'Camera Service test ediliyor...';
    });

    try {
      final cameraService = CameraService();

      setState(() {
        _result = '''
✅ Camera Service Başarılı!

📷 Kamera Servisi Hazır
🎯 Desteklenen Özellikler:
• Fotoğraf çekme
• Galeri'den seçme
• Resim işleme
• Hash hesaplama
• Deduplication

📱 Kullanım:
cameraService.takePicture()
cameraService.pickFromGallery()
        ''';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Camera Service Hatası: $e';
      });
    }
  }
}
