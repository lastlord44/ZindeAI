import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/meal_template_service.dart';

void main() {
  group('MealTemplateService Tests', () {
    late MealTemplateService service;

    setUp(() {
      service = MealTemplateService();
    });

    test('Kahvaltı önerisi - protein ağırlıklı', () {
      final recommendation = service.recommendMeal(
        mealType: 'kahvalti',
        targetKcal: 400,
        goalType: GoalType.kiloVerme,
        macroPriority: MacroPriority.highProtein,
        tags: ['tok-tutan'],
      );

      expect(
        recommendation.template.totalKcal,
        lessThanOrEqualTo(480),
      ); // ±20% tolerans
      expect(recommendation.template.totalKcal, greaterThanOrEqualTo(320));
      expect(recommendation.matchScore, greaterThan(0.0));
      expect(recommendation.suggestions, isNotEmpty);
      expect(recommendation.template.name, isNotEmpty);
    });

    test('Öğle yemeği - dengeli makro', () {
      final recommendation = service.recommendMeal(
        mealType: 'ogle',
        targetKcal: 500,
        goalType: GoalType.kiloKoruma,
        macroPriority: MacroPriority.balanced,
      );

      expect(recommendation.template.totalKcal, lessThanOrEqualTo(600));
      expect(recommendation.template.totalKcal, greaterThanOrEqualTo(400));
      expect(recommendation.template.items, isNotEmpty);
      expect(recommendation.alternatives, isNotEmpty);
    });

    test('Akşam yemeği - düşük karbonhidrat', () {
      final recommendation = service.recommendMeal(
        mealType: 'aksam',
        targetKcal: 350,
        goalType: GoalType.kiloVerme,
        macroPriority: MacroPriority.lowCarb,
      );

      expect(recommendation.template.totalKcal, lessThanOrEqualTo(420));
      expect(recommendation.template.totalKcal, greaterThanOrEqualTo(280));

      // Düşük karbonhidrat kontrolü
      final carbRatio =
          recommendation.template.totalCarbs *
          4 /
          recommendation.template.totalKcal;
      expect(carbRatio, lessThanOrEqualTo(0.25));
    });

    test('Ara öğün - protein atıştırması', () {
      final recommendation = service.recommendMeal(
        mealType: 'ara',
        targetKcal: 150,
        goalType: GoalType.kiloVerme,
        macroPriority: MacroPriority.highProtein,
        tags: ['tok-tutan'],
      );

      expect(recommendation.template.totalKcal, lessThanOrEqualTo(180));
      expect(recommendation.template.totalKcal, greaterThanOrEqualTo(120));

      // Yüksek protein kontrolü
      final proteinRatio =
          recommendation.template.totalProtein *
          4 /
          recommendation.template.totalKcal;
      expect(proteinRatio, greaterThanOrEqualTo(0.25));
    });

    test('Kilo alma hedefi - yüksek kalori', () {
      final recommendation = service.recommendMeal(
        mealType: 'ogle',
        targetKcal: 600,
        goalType: GoalType.kiloAlma,
        macroPriority: MacroPriority.balanced,
      );

      expect(recommendation.template.totalKcal, lessThanOrEqualTo(720));
      expect(recommendation.template.totalKcal, greaterThanOrEqualTo(480));

      // Kilo alma için yeterli karbonhidrat
      final carbRatio =
          recommendation.template.totalCarbs *
          4 /
          recommendation.template.totalKcal;
      expect(carbRatio, greaterThanOrEqualTo(0.35));
    });

    test('Özel öğün oluşturma - mevcut olmayan öğün tipi', () {
      final recommendation = service.recommendMeal(
        mealType: 'gece',
        targetKcal: 200,
        goalType: GoalType.kiloVerme,
        macroPriority: MacroPriority.lowFat,
      );

      expect(recommendation.template.name, contains('Özel'));
      expect(recommendation.matchScore, equals(0.75));
      expect(
        recommendation.suggestions,
        contains('Bu öğün sizin hedeflerinize özel olarak oluşturuldu'),
      );
    });

    test('Porsiyon ayarlama - hedef kaloriye uygun', () {
      final recommendation = service.recommendMeal(
        mealType: 'kahvalti',
        targetKcal: 300, // Düşük kalori
        goalType: GoalType.kiloVerme,
        macroPriority: MacroPriority.balanced,
      );

      expect(recommendation.template.totalKcal, lessThanOrEqualTo(360));
      expect(recommendation.template.totalKcal, greaterThanOrEqualTo(240));
    });

    test('Tag filtresi çalışıyor', () {
      final recommendation = service.recommendMeal(
        mealType: 'kahvalti',
        targetKcal: 400,
        goalType: GoalType.kiloVerme,
        tags: ['geleneksel'],
      );

      expect(recommendation.template.tags, contains('geleneksel'));
    });

    test('Randomize parametresi çalışıyor', () {
      final recommendation1 = service.recommendMeal(
        mealType: 'kahvalti',
        targetKcal: 400,
        goalType: GoalType.kiloVerme,
        randomize: true,
      );

      final recommendation2 = service.recommendMeal(
        mealType: 'kahvalti',
        targetKcal: 400,
        goalType: GoalType.kiloVerme,
        randomize: true,
      );

      // Randomize true olduğunda farklı sonuçlar gelebilir
      // En azından servis çalışıyor olmalı
      expect(recommendation1.template.name, isNotEmpty);
      expect(recommendation2.template.name, isNotEmpty);
    });

    test('Eşleşme skoru hesaplama', () {
      final recommendation = service.recommendMeal(
        mealType: 'ogle',
        targetKcal: 500,
        goalType: GoalType.kiloKoruma,
        macroPriority: MacroPriority.balanced,
      );

      expect(recommendation.matchScore, greaterThanOrEqualTo(0.0));
      expect(recommendation.matchScore, lessThanOrEqualTo(1.0));
    });

    test('Alternatif öğünler bulunuyor', () {
      final recommendation = service.recommendMeal(
        mealType: 'aksam',
        targetKcal: 400,
        goalType: GoalType.kiloVerme,
        macroPriority: MacroPriority.lowCarb,
      );

      expect(recommendation.alternatives, isA<List<String>>());
      // Alternatifler varsa 3'ten fazla olmamalı
      expect(recommendation.alternatives.length, lessThanOrEqualTo(3));
    });

    test('Öneriler üretiliyor', () {
      final recommendation = service.recommendMeal(
        mealType: 'kahvalti',
        targetKcal: 400,
        goalType: GoalType.kiloVerme,
        macroPriority: MacroPriority.highProtein,
      );

      expect(recommendation.suggestions, isA<List<String>>());
      expect(recommendation.suggestions, isNotEmpty);
    });

    test('Model sınıfları JSON dönüşümü', () {
      final recommendation = service.recommendMeal(
        mealType: 'ara',
        targetKcal: 200,
        goalType: GoalType.kiloVerme,
      );

      // MealItem JSON testi
      final firstItem = recommendation.template.items.first;
      final itemJson = firstItem.toJson();
      expect(itemJson['name'], isA<String>());
      expect(itemJson['kcal'], isA<double>());

      // MealTemplate JSON testi
      final templateJson = recommendation.template.toJson();
      expect(templateJson['id'], isA<String>());
      expect(templateJson['totalKcal'], isA<int>());

      // MealRecommendation JSON testi
      final recommendationJson = recommendation.toJson();
      expect(recommendationJson['matchScore'], isA<double>());
      expect(recommendationJson['suggestions'], isA<List>());
    });
  });
}
