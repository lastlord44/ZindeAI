import 'dart:math';

/// ZindeAI Meal Templates Engine
/// Kullanıcı hedeflerine göre dinamik öğün önerileri üretir
/// Hem şablon tabanlı hem de algoritmik eşleştirme destekler
class MealTemplateService {
  static final MealTemplateService _instance = MealTemplateService._internal();
  factory MealTemplateService() => _instance;
  MealTemplateService._internal();

  final Random _random = Random();

  /// Öğün şablonları - Türk mutfağına özel
  final Map<String, List<MealTemplate>> _mealTemplates = {
    'kahvalti': [
      // Protein ağırlıklı kahvaltılar
      MealTemplate(
        id: 'kahvalti_protein_1',
        name: 'Güçlü Başlangıç',
        items: [
          MealItem('Yumurta', 2, 'adet', 140, 12, 1, 10),
          MealItem('Beyaz peynir', 60, 'gram', 160, 12, 2, 12),
          MealItem('Domates', 100, 'gram', 20, 1, 4, 0),
          MealItem('Salatalık', 100, 'gram', 15, 1, 3, 0),
          MealItem('Tam buğday ekmeği', 30, 'gram', 75, 3, 14, 1),
        ],
        totalKcal: 410,
        totalProtein: 29,
        totalCarbs: 24,
        totalFat: 23,
        tags: ['protein-yuksek', 'tok-tutan', 'geleneksel'],
      ),
      MealTemplate(
        id: 'kahvalti_protein_2',
        name: 'Sporcu Kahvaltısı',
        items: [
          MealItem('Omlet (3 yumurta)', 1, 'porsiyon', 210, 18, 2, 15),
          MealItem('Lor peyniri', 100, 'gram', 90, 14, 3, 2),
          MealItem('Avokado', 50, 'gram', 80, 1, 4, 7),
          MealItem('Çavdar ekmeği', 40, 'gram', 95, 3, 18, 1),
        ],
        totalKcal: 475,
        totalProtein: 36,
        totalCarbs: 27,
        totalFat: 25,
        tags: ['protein-yuksek', 'sporcu', 'modern'],
      ),
      // Dengeli kahvaltılar
      MealTemplate(
        id: 'kahvalti_dengeli_1',
        name: 'Klasik Türk Kahvaltısı',
        items: [
          MealItem('Haşlanmış yumurta', 1, 'adet', 70, 6, 1, 5),
          MealItem('Beyaz peynir', 40, 'gram', 105, 8, 1, 8),
          MealItem('Siyah zeytin', 30, 'gram', 35, 0, 1, 3),
          MealItem('Domates', 100, 'gram', 20, 1, 4, 0),
          MealItem('Salatalık', 100, 'gram', 15, 1, 3, 0),
          MealItem('Bal', 15, 'gram', 45, 0, 11, 0),
          MealItem('Simit', 0.5, 'adet', 140, 4, 26, 2),
        ],
        totalKcal: 430,
        totalProtein: 20,
        totalCarbs: 47,
        totalFat: 18,
        tags: ['dengeli', 'geleneksel', 'doyurucu'],
      ),
      // Hafif kahvaltılar
      MealTemplate(
        id: 'kahvalti_hafif_1',
        name: 'Hafif Başlangıç',
        items: [
          MealItem('Yoğurt', 150, 'gram', 90, 5, 7, 4),
          MealItem('Müsli', 30, 'gram', 110, 3, 20, 2),
          MealItem('Muz', 0.5, 'adet', 45, 1, 11, 0),
          MealItem('Ceviz', 10, 'gram', 65, 2, 1, 6),
        ],
        totalKcal: 310,
        totalProtein: 11,
        totalCarbs: 39,
        totalFat: 12,
        tags: ['hafif', 'pratik', 'sağlıklı'],
      ),
    ],
    'ogle': [
      // Protein ağırlıklı öğle yemekleri
      MealTemplate(
        id: 'ogle_protein_1',
        name: 'Izgara Tavuk Menü',
        items: [
          MealItem('Izgara tavuk göğsü', 150, 'gram', 245, 46, 0, 6),
          MealItem('Bulgur pilavı', 100, 'gram', 85, 3, 17, 0.5),
          MealItem('Yeşil salata', 150, 'gram', 25, 2, 4, 0),
          MealItem('Ayran', 200, 'ml', 60, 4, 8, 1.5),
        ],
        totalKcal: 415,
        totalProtein: 55,
        totalCarbs: 29,
        totalFat: 8,
        tags: ['protein-yuksek', 'izgara', 'doyurucu'],
      ),
      MealTemplate(
        id: 'ogle_protein_2',
        name: 'Köfte Menü',
        items: [
          MealItem('Izgara köfte', 120, 'gram', 290, 24, 8, 18),
          MealItem('Pilav', 100, 'gram', 130, 2, 28, 1),
          MealItem('Cacık', 100, 'gram', 50, 3, 4, 2),
          MealItem('Karışık salata', 150, 'gram', 30, 2, 5, 0.5),
        ],
        totalKcal: 500,
        totalProtein: 31,
        totalCarbs: 45,
        totalFat: 21.5,
        tags: ['protein-yuksek', 'geleneksel', 'doyurucu'],
      ),
      // Sebze ağırlıklı
      MealTemplate(
        id: 'ogle_sebze_1',
        name: 'Zeytinyağlı Menü',
        items: [
          MealItem('Zeytinyağlı taze fasulye', 200, 'gram', 120, 3, 12, 7),
          MealItem('Pilav', 100, 'gram', 130, 2, 28, 1),
          MealItem('Yoğurt', 100, 'gram', 60, 3, 5, 3),
          MealItem('Tam buğday ekmeği', 30, 'gram', 75, 3, 14, 1),
        ],
        totalKcal: 385,
        totalProtein: 11,
        totalCarbs: 59,
        totalFat: 12,
        tags: ['sebze-ağırlıklı', 'zeytinyağlı', 'hafif'],
      ),
      // Balık menüleri
      MealTemplate(
        id: 'ogle_balik_1',
        name: 'Somon Menü',
        items: [
          MealItem('Izgara somon', 120, 'gram', 250, 30, 0, 15),
          MealItem('Haşlanmış sebze', 150, 'gram', 45, 3, 8, 0.5),
          MealItem('Kinoa salatası', 100, 'gram', 120, 4, 20, 3),
        ],
        totalKcal: 415,
        totalProtein: 37,
        totalCarbs: 28,
        totalFat: 18.5,
        tags: ['balık', 'omega3', 'sağlıklı'],
      ),
    ],
    'aksam': [
      // Hafif akşam yemekleri
      MealTemplate(
        id: 'aksam_hafif_1',
        name: 'Çorba ve Salata',
        items: [
          MealItem('Mercimek çorbası', 250, 'ml', 140, 8, 20, 3),
          MealItem('Çoban salatası', 200, 'gram', 60, 2, 10, 2),
          MealItem('Tam buğday ekmeği', 30, 'gram', 75, 3, 14, 1),
        ],
        totalKcal: 275,
        totalProtein: 13,
        totalCarbs: 44,
        totalFat: 6,
        tags: ['hafif', 'çorba', 'düşük-kalori'],
      ),
      // Protein ağırlıklı akşam
      MealTemplate(
        id: 'aksam_protein_1',
        name: 'Et Sote Menü',
        items: [
          MealItem('Dana eti sote', 120, 'gram', 220, 28, 5, 10),
          MealItem('Haşlanmış brokoli', 150, 'gram', 40, 4, 6, 0.5),
          MealItem('Yoğurt', 100, 'gram', 60, 3, 5, 3),
        ],
        totalKcal: 320,
        totalProtein: 35,
        totalCarbs: 16,
        totalFat: 13.5,
        tags: ['protein-yuksek', 'düşük-karb', 'tok-tutan'],
      ),
      // Düşük karbonhidrat
      MealTemplate(
        id: 'aksam_lowcarb_1',
        name: 'Keto Dostu Menü',
        items: [
          MealItem('Izgara hellim', 100, 'gram', 320, 22, 2, 25),
          MealItem('Avokado salatası', 150, 'gram', 160, 2, 8, 14),
          MealItem('Ceviz', 20, 'gram', 130, 3, 2, 13),
        ],
        totalKcal: 610,
        totalProtein: 27,
        totalCarbs: 12,
        totalFat: 52,
        tags: ['düşük-karb', 'keto', 'yüksek-yağ'],
      ),
    ],
    'ara': [
      // Protein ara öğünler
      MealTemplate(
        id: 'ara_protein_1',
        name: 'Protein Atıştırması',
        items: [
          MealItem('Süzme yoğurt', 100, 'gram', 60, 10, 4, 0),
          MealItem('Badem', 15, 'gram', 90, 3, 2, 8),
        ],
        totalKcal: 150,
        totalProtein: 13,
        totalCarbs: 6,
        totalFat: 8,
        tags: ['protein', 'tok-tutan', 'düşük-kalori'],
      ),
      // Meyve ara öğünler
      MealTemplate(
        id: 'ara_meyve_1',
        name: 'Meyve Tabağı',
        items: [
          MealItem('Elma', 1, 'adet', 80, 0, 20, 0),
          MealItem('Ceviz', 10, 'gram', 65, 2, 1, 6),
        ],
        totalKcal: 145,
        totalProtein: 2,
        totalCarbs: 21,
        totalFat: 6,
        tags: ['meyve', 'hafif', 'doğal'],
      ),
      // Smoothie
      MealTemplate(
        id: 'ara_smoothie_1',
        name: 'Protein Smoothie',
        items: [
          MealItem('Muz', 0.5, 'adet', 45, 1, 11, 0),
          MealItem('Süt', 200, 'ml', 90, 7, 10, 3),
          MealItem('Yulaf', 20, 'gram', 75, 2, 13, 1.5),
          MealItem('Fıstık ezmesi', 10, 'gram', 60, 2, 2, 5),
        ],
        totalKcal: 270,
        totalProtein: 12,
        totalCarbs: 36,
        totalFat: 9.5,
        tags: ['smoothie', 'pratik', 'tok-tutan'],
      ),
    ],
  };

  /// Dinamik öğün önerisi üret
  MealRecommendation recommendMeal({
    required String mealType, // kahvalti, ogle, aksam, ara
    required int targetKcal,
    required GoalType goalType, // kiloVerme, kiloAlma, kiloKoruma
    MacroPriority? macroPriority,
    List<String>? tags,
    bool randomize = true,
  }) {
    // Öğün tipine göre şablonları al
    final templates = _mealTemplates[mealType] ?? [];
    if (templates.isEmpty) {
      return _createCustomMeal(mealType, targetKcal, goalType, macroPriority);
    }

    // Filtreleme
    var filteredTemplates = templates.where((template) {
      // Kalori filtresi (±%20 tolerans)
      final lowerBound = targetKcal * 0.8;
      final upperBound = targetKcal * 1.2;
      if (template.totalKcal < lowerBound || template.totalKcal > upperBound) {
        return false;
      }

      // Makro önceliği filtresi
      if (macroPriority != null) {
        switch (macroPriority) {
          case MacroPriority.highProtein:
            if (template.totalProtein < targetKcal * 0.25 / 4) return false;
            break;
          case MacroPriority.lowCarb:
            if (template.totalCarbs > targetKcal * 0.25 / 4) return false;
            break;
          case MacroPriority.lowFat:
            if (template.totalFat > targetKcal * 0.20 / 9) return false;
            break;
          case MacroPriority.balanced:
            // Dengeli için özel filtre yok
            break;
        }
      }

      // Tag filtresi
      if (tags != null && tags.isNotEmpty) {
        final hasTag = tags.any((tag) => template.tags.contains(tag));
        if (!hasTag) return false;
      }

      return true;
    }).toList();

    // Eğer filtreden geçen şablon yoksa özel üret
    if (filteredTemplates.isEmpty) {
      return _createCustomMeal(mealType, targetKcal, goalType, macroPriority);
    }

    // Seçim yap
    final selectedTemplate = randomize && filteredTemplates.length > 1
        ? filteredTemplates[_random.nextInt(filteredTemplates.length)]
        : filteredTemplates.first;

    // Porsiyon ayarlaması yap
    final adjustedTemplate = _adjustPortions(selectedTemplate, targetKcal);

    return MealRecommendation(
      template: adjustedTemplate,
      matchScore: _calculateMatchScore(
        adjustedTemplate,
        targetKcal,
        goalType,
        macroPriority,
      ),
      suggestions: _generateSuggestions(adjustedTemplate, goalType),
      alternatives: _findAlternatives(mealType, targetKcal, macroPriority),
    );
  }

  /// Özel öğün oluştur (şablon bulunamadığında)
  MealRecommendation _createCustomMeal(
    String mealType,
    int targetKcal,
    GoalType goalType,
    MacroPriority? macroPriority,
  ) {
    // Makro hedeflerini hesapla
    final macros = _calculateMacroTargets(targetKcal, goalType, macroPriority);

    // Dinamik olarak besinleri kombine et
    final items = <MealItem>[];
    var remainingKcal = targetKcal.toDouble();
    var currentProtein = 0.0;
    var currentCarbs = 0.0;
    var currentFat = 0.0;

    // Ana protein kaynağı ekle
    if (macros['protein']! > 0) {
      final proteinItem = _selectProteinSource(mealType, macros['protein']!);
      items.add(proteinItem);
      remainingKcal -= proteinItem.kcal;
      currentProtein += proteinItem.protein;
      currentCarbs += proteinItem.carbs;
      currentFat += proteinItem.fat;
    }

    // Karbonhidrat kaynağı ekle
    if (macros['carbs']! > 0 && remainingKcal > 50) {
      final carbItem = _selectCarbSource(
        mealType,
        min(macros['carbs']!, remainingKcal * 0.5),
      );
      items.add(carbItem);
      remainingKcal -= carbItem.kcal;
      currentCarbs += carbItem.carbs;
    }

    // Sebze/salata ekle
    if (remainingKcal > 30) {
      final veggieItem = _selectVegetable(mealType);
      items.add(veggieItem);
      remainingKcal -= veggieItem.kcal;
    }

    // Yağ kaynağı ekle (gerekirse)
    if (currentFat < macros['fat']! * 0.7 && remainingKcal > 40) {
      final fatItem = _selectFatSource(mealType);
      items.add(fatItem);
      currentFat += fatItem.fat;
    }

    final customTemplate = MealTemplate(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Özel ${_getMealTypeName(mealType)}',
      items: items,
      totalKcal: items.fold(0, (sum, item) => sum + item.kcal.toInt()),
      totalProtein: items.fold(0.0, (sum, item) => sum + item.protein),
      totalCarbs: items.fold(0.0, (sum, item) => sum + item.carbs),
      totalFat: items.fold(0.0, (sum, item) => sum + item.fat),
      tags: ['özel', 'dinamik'],
    );

    return MealRecommendation(
      template: customTemplate,
      matchScore: 0.75, // Özel üretimler için varsayılan skor
      suggestions: ['Bu öğün sizin hedeflerinize özel olarak oluşturuldu'],
      alternatives: [],
    );
  }

  /// Makro hedeflerini hesapla
  Map<String, double> _calculateMacroTargets(
    int targetKcal,
    GoalType goalType,
    MacroPriority? macroPriority,
  ) {
    double proteinRatio, carbRatio, fatRatio;

    // Hedef tipine göre temel oranlar
    switch (goalType) {
      case GoalType.kiloVerme:
        proteinRatio = 0.35; // Yüksek protein
        carbRatio = 0.35;
        fatRatio = 0.30;
        break;
      case GoalType.kiloAlma:
        proteinRatio = 0.25;
        carbRatio = 0.45; // Yüksek karbonhidrat
        fatRatio = 0.30;
        break;
      case GoalType.kiloKoruma:
        proteinRatio = 0.30;
        carbRatio = 0.40;
        fatRatio = 0.30;
        break;
    }

    // Makro önceliğine göre ayarlama
    if (macroPriority != null) {
      switch (macroPriority) {
        case MacroPriority.highProtein:
          proteinRatio = 0.40;
          carbRatio = 0.35;
          fatRatio = 0.25;
          break;
        case MacroPriority.lowCarb:
          proteinRatio = 0.35;
          carbRatio = 0.20;
          fatRatio = 0.45;
          break;
        case MacroPriority.lowFat:
          proteinRatio = 0.30;
          carbRatio = 0.50;
          fatRatio = 0.20;
          break;
        case MacroPriority.balanced:
          // Zaten dengeli
          break;
      }
    }

    return {
      'protein': targetKcal * proteinRatio / 4, // gram
      'carbs': targetKcal * carbRatio / 4, // gram
      'fat': targetKcal * fatRatio / 9, // gram
    };
  }

  /// Protein kaynağı seç
  MealItem _selectProteinSource(String mealType, double targetProtein) {
    final proteinSources = {
      'kahvalti': [
        MealItem('Yumurta', 2, 'adet', 140, 12, 1, 10),
        MealItem('Beyaz peynir', 80, 'gram', 210, 16, 2, 16),
        MealItem('Lor peyniri', 100, 'gram', 90, 14, 3, 2),
      ],
      'ogle': [
        MealItem('Tavuk göğsü', 120, 'gram', 195, 37, 0, 5),
        MealItem('Dana eti', 100, 'gram', 180, 26, 0, 8),
        MealItem('Somon', 100, 'gram', 210, 25, 0, 13),
      ],
      'aksam': [
        MealItem('Izgara köfte', 100, 'gram', 240, 20, 6, 15),
        MealItem('Hindi göğsü', 100, 'gram', 160, 30, 0, 4),
        MealItem('Ton balığı', 100, 'gram', 130, 28, 0, 2),
      ],
      'ara': [
        MealItem('Protein yoğurt', 150, 'gram', 90, 15, 6, 0),
        MealItem('Haşlanmış yumurta', 1, 'adet', 70, 6, 1, 5),
        MealItem('Peynir', 30, 'gram', 80, 6, 1, 6),
      ],
    };

    final sources = proteinSources[mealType] ?? proteinSources['ara']!;
    return sources[_random.nextInt(sources.length)];
  }

  /// Karbonhidrat kaynağı seç
  MealItem _selectCarbSource(String mealType, double maxKcal) {
    final carbSources = {
      'kahvalti': [
        MealItem('Tam buğday ekmeği', 40, 'gram', 100, 4, 19, 1),
        MealItem('Yulaf', 30, 'gram', 110, 3, 20, 2),
        MealItem('Simit', 0.5, 'adet', 140, 4, 26, 2),
      ],
      'ogle': [
        MealItem('Bulgur pilavı', 100, 'gram', 85, 3, 17, 0.5),
        MealItem('Pilav', 100, 'gram', 130, 2, 28, 1),
        MealItem('Makarna', 80, 'gram', 110, 4, 22, 0.5),
      ],
      'aksam': [
        MealItem('Kinoa', 80, 'gram', 95, 3, 17, 2),
        MealItem('Mercimek', 80, 'gram', 90, 6, 15, 0.5),
        MealItem('Tam buğday makarna', 60, 'gram', 85, 3, 17, 0.5),
      ],
      'ara': [
        MealItem('Muz', 1, 'adet', 90, 1, 22, 0),
        MealItem('Grissini', 20, 'gram', 80, 2, 16, 1),
        MealItem('Kuru üzüm', 20, 'gram', 60, 1, 15, 0),
      ],
    };

    final sources = carbSources[mealType] ?? carbSources['ara']!;
    return sources[_random.nextInt(sources.length)];
  }

  /// Sebze seç
  MealItem _selectVegetable(String mealType) {
    final veggies = [
      MealItem('Salata', 150, 'gram', 25, 2, 4, 0),
      MealItem('Domates', 100, 'gram', 20, 1, 4, 0),
      MealItem('Salatalık', 100, 'gram', 15, 1, 3, 0),
      MealItem('Haşlanmış brokoli', 100, 'gram', 30, 3, 5, 0),
      MealItem('Izgara sebze', 150, 'gram', 45, 2, 8, 1),
    ];

    return veggies[_random.nextInt(veggies.length)];
  }

  /// Yağ kaynağı seç
  MealItem _selectFatSource(String mealType) {
    final fats = [
      MealItem('Zeytinyağı', 10, 'ml', 90, 0, 0, 10),
      MealItem('Ceviz', 15, 'gram', 100, 2, 2, 9),
      MealItem('Badem', 15, 'gram', 90, 3, 2, 8),
      MealItem('Avokado', 50, 'gram', 80, 1, 4, 7),
      MealItem('Tahin', 10, 'gram', 60, 2, 2, 5),
    ];

    return fats[_random.nextInt(fats.length)];
  }

  /// Porsiyon ayarlama
  MealTemplate _adjustPortions(MealTemplate template, int targetKcal) {
    final ratio = targetKcal / template.totalKcal;

    // Eğer oran 0.8-1.2 arasındaysa ayarlama yapma
    if (ratio >= 0.8 && ratio <= 1.2) {
      return template;
    }

    // Porsiyonları ayarla
    final adjustedItems = template.items.map((item) {
      final newAmount = item.amount * ratio;
      final newKcal = item.kcal * ratio;
      final newProtein = item.protein * ratio;
      final newCarbs = item.carbs * ratio;
      final newFat = item.fat * ratio;

      return MealItem(
        item.name,
        newAmount,
        item.unit,
        newKcal,
        newProtein,
        newCarbs,
        newFat,
      );
    }).toList();

    return MealTemplate(
      id: '${template.id}_adjusted',
      name: '${template.name} (Ayarlanmış)',
      items: adjustedItems,
      totalKcal: targetKcal,
      totalProtein: template.totalProtein * ratio,
      totalCarbs: template.totalCarbs * ratio,
      totalFat: template.totalFat * ratio,
      tags: [...template.tags, 'ayarlanmış'],
    );
  }

  /// Eşleşme skoru hesapla
  double _calculateMatchScore(
    MealTemplate template,
    int targetKcal,
    GoalType goalType,
    MacroPriority? macroPriority,
  ) {
    double score = 1.0;

    // Kalori uyumu
    final kcalDiff = (template.totalKcal - targetKcal).abs() / targetKcal;
    score -= kcalDiff * 0.3;

    // Makro uyumu
    if (macroPriority != null) {
      switch (macroPriority) {
        case MacroPriority.highProtein:
          final proteinRatio = template.totalProtein * 4 / template.totalKcal;
          if (proteinRatio < 0.25) score -= 0.2;
          break;
        case MacroPriority.lowCarb:
          final carbRatio = template.totalCarbs * 4 / template.totalKcal;
          if (carbRatio > 0.25) score -= 0.2;
          break;
        case MacroPriority.lowFat:
          final fatRatio = template.totalFat * 9 / template.totalKcal;
          if (fatRatio > 0.25) score -= 0.2;
          break;
        case MacroPriority.balanced:
          // Dengeli için ekstra ceza yok
          break;
      }
    }

    // Hedef tipine göre makro uyumu
    switch (goalType) {
      case GoalType.kiloVerme:
        // Kilo verme için yüksek protein bonus
        final proteinRatio = template.totalProtein * 4 / template.totalKcal;
        if (proteinRatio >= 0.30) score += 0.1;
        break;
      case GoalType.kiloAlma:
        // Kilo alma için yeterli karbonhidrat bonus
        final carbRatio = template.totalCarbs * 4 / template.totalKcal;
        if (carbRatio >= 0.40) score += 0.1;
        break;
      case GoalType.kiloKoruma:
        // Koruma için dengeli makro bonus
        final proteinRatio = template.totalProtein * 4 / template.totalKcal;
        final carbRatio = template.totalCarbs * 4 / template.totalKcal;
        final fatRatio = template.totalFat * 9 / template.totalKcal;

        if (proteinRatio >= 0.25 &&
            proteinRatio <= 0.35 &&
            carbRatio >= 0.35 &&
            carbRatio <= 0.45 &&
            fatRatio >= 0.25 &&
            fatRatio <= 0.35) {
          score += 0.15;
        }
        break;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Öneriler üret
  List<String> _generateSuggestions(MealTemplate template, GoalType goalType) {
    final suggestions = <String>[];

    // Protein değerlendirmesi
    final proteinRatio = template.totalProtein * 4 / template.totalKcal;
    if (proteinRatio >= 0.30) {
      suggestions.add('✅ Yüksek protein içeriği kas koruması sağlar');
    } else if (proteinRatio < 0.20) {
      suggestions.add('💡 Protein miktarını artırmayı düşünebilirsiniz');
    }

    // Hedef tipine göre öneriler
    switch (goalType) {
      case GoalType.kiloVerme:
        if (template.totalKcal < 400) {
          suggestions.add('✅ Düşük kalori hedefi ile uyumlu');
        }
        if (template.totalCarbs < 30) {
          suggestions.add('✅ Düşük karbonhidrat, yağ yakımını destekler');
        }
        break;
      case GoalType.kiloAlma:
        if (template.totalKcal > 500) {
          suggestions.add('✅ Kalori fazlası hedefine uygun');
        }
        if (template.totalCarbs > 40) {
          suggestions.add('✅ Yeterli karbonhidrat, enerji deposu için ideal');
        }
        break;
      case GoalType.kiloKoruma:
        suggestions.add('✅ Dengeli makro dağılımı');
        break;
    }

    // Genel öneriler
    if (template.tags.contains('tok-tutan')) {
      suggestions.add('👍 Uzun süre tok tutar');
    }
    if (template.tags.contains('pratik')) {
      suggestions.add('⏱️ Hızlı hazırlanabilir');
    }
    if (template.tags.contains('omega3')) {
      suggestions.add('🐟 Omega-3 açısından zengin');
    }

    return suggestions;
  }

  /// Alternatif öğünleri bul
  List<String> _findAlternatives(
    String mealType,
    int targetKcal,
    MacroPriority? macroPriority,
  ) {
    final alternatives = <String>[];
    final templates = _mealTemplates[mealType] ?? [];

    for (final template in templates) {
      // Kalori uyumu kontrolü
      final kcalDiff = (template.totalKcal - targetKcal).abs() / targetKcal;
      if (kcalDiff > 0.3) continue;

      // Makro uyumu kontrolü
      bool macroMatch = true;
      if (macroPriority != null) {
        switch (macroPriority) {
          case MacroPriority.highProtein:
            if (template.totalProtein < targetKcal * 0.25 / 4)
              macroMatch = false;
            break;
          case MacroPriority.lowCarb:
            if (template.totalCarbs > targetKcal * 0.30 / 4) macroMatch = false;
            break;
          case MacroPriority.lowFat:
            if (template.totalFat > targetKcal * 0.25 / 9) macroMatch = false;
            break;
          case MacroPriority.balanced:
            // Her zaman uygun
            break;
        }
      }

      if (macroMatch) {
        alternatives.add('${template.name} (${template.totalKcal} kcal)');
      }

      if (alternatives.length >= 3) break;
    }

    return alternatives;
  }

  /// Öğün tipi ismini getir
  String _getMealTypeName(String mealType) {
    switch (mealType) {
      case 'kahvalti':
        return 'Kahvaltı';
      case 'ogle':
        return 'Öğle Yemeği';
      case 'aksam':
        return 'Akşam Yemeği';
      case 'ara':
        return 'Ara Öğün';
      default:
        return 'Öğün';
    }
  }
}

// ============= MODEL SINIFLARI =============

/// Besin öğesi
class MealItem {
  final String name;
  final double amount;
  final String unit;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  MealItem(
    this.name,
    this.amount,
    this.unit,
    this.kcal,
    this.protein,
    this.carbs,
    this.fat,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'unit': unit,
    'kcal': kcal,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };
}

/// Öğün şablonu
class MealTemplate {
  final String id;
  final String name;
  final List<MealItem> items;
  final int totalKcal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<String> tags;

  MealTemplate({
    required this.id,
    required this.name,
    required this.items,
    required this.totalKcal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((e) => e.toJson()).toList(),
    'totalKcal': totalKcal,
    'totalProtein': totalProtein,
    'totalCarbs': totalCarbs,
    'totalFat': totalFat,
    'tags': tags,
  };
}

/// Öğün önerisi
class MealRecommendation {
  final MealTemplate template;
  final double matchScore; // 0-1 arası eşleşme skoru
  final List<String> suggestions; // Kullanıcıya öneriler
  final List<String> alternatives; // Alternatif öğünler

  MealRecommendation({
    required this.template,
    required this.matchScore,
    required this.suggestions,
    required this.alternatives,
  });

  Map<String, dynamic> toJson() => {
    'template': template.toJson(),
    'matchScore': matchScore,
    'suggestions': suggestions,
    'alternatives': alternatives,
  };
}

/// Hedef tipi
enum GoalType { kiloVerme, kiloAlma, kiloKoruma }

/// Makro önceliği
enum MacroPriority { highProtein, lowCarb, lowFat, balanced }

/// Kullanım Örneği:
/// 
/// final mealService = MealTemplateService();
/// 
/// // Protein ağırlıklı kahvaltı önerisi
/// final kahvalti = mealService.recommendMeal(
///   mealType: 'kahvalti',
///   targetKcal: 400,
///   goalType: GoalType.kiloVerme,
///   macroPriority: MacroPriority.highProtein,
///   tags: ['tok-tutan'],
/// );
/// 
/// // Düşük karbonhidratlı akşam yemeği
/// final aksam = mealService.recommendMeal(
///   mealType: 'aksam',
///   targetKcal: 350,
///   goalType: GoalType.kiloVerme,
///   macroPriority: MacroPriority.lowCarb,
/// );
/// 
/// // Kilo alma için yüksek kalorili öğle yemeği
/// final ogle = mealService.recommendMeal(
///   mealType: 'ogle',
///   targetKcal: 600,
///   goalType: GoalType.kiloAlma,
///   macroPriority: MacroPriority.balanced,
///   tags: ['doyurucu'],
/// );
