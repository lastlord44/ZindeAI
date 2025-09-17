// lib/services/weekly_summary_service.dart
import 'dart:convert';
import 'package:intl/intl.dart';

/// Haftalık özet verisi için model sınıf
class WeeklySummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalDaysLogged;
  final int daysTargetMet;
  final double averageCalories;
  final double averageProtein;
  final double averageCarbs;
  final double averageFat;
  final DateTime? bestDay;
  final DateTime? worstDay;
  final String summaryText;
  final double targetAchievementRate;
  final Map<String, dynamic> detailedStats;

  WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.totalDaysLogged,
    required this.daysTargetMet,
    required this.averageCalories,
    required this.averageProtein,
    required this.averageCarbs,
    required this.averageFat,
    this.bestDay,
    this.worstDay,
    required this.summaryText,
    required this.targetAchievementRate,
    required this.detailedStats,
  });

  Map<String, dynamic> toJson() => {
    'week_start': DateFormat('yyyy-MM-dd').format(weekStart),
    'week_end': DateFormat('yyyy-MM-dd').format(weekEnd),
    'total_days_logged': totalDaysLogged,
    'days_target_met': daysTargetMet,
    'average_calories': averageCalories.toStringAsFixed(1),
    'average_protein': averageProtein.toStringAsFixed(1),
    'average_carbs': averageCarbs.toStringAsFixed(1),
    'average_fat': averageFat.toStringAsFixed(1),
    'best_day': bestDay != null
        ? DateFormat('yyyy-MM-dd').format(bestDay!)
        : null,
    'worst_day': worstDay != null
        ? DateFormat('yyyy-MM-dd').format(worstDay!)
        : null,
    'summary_text': summaryText,
    'target_achievement_rate': targetAchievementRate.toStringAsFixed(1),
    'detailed_stats': detailedStats,
  };

  String toJsonString() => jsonEncode(toJson());
}

/// Günlük beslenme verisi için model
class DailyNutrition {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final int mealsLogged;

  DailyNutrition({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.mealsLogged,
  });

  // Günlük hedef başarı oranını hesapla (0-100)
  double get achievementScore {
    // Her makro için skoru hesapla
    double calorieScore = _calculateMacroScore(calories, targetCalories);
    double proteinScore = _calculateMacroScore(protein, targetProtein);
    double carbScore = _calculateMacroScore(carbs, targetCarbs);
    double fatScore = _calculateMacroScore(fat, targetFat);

    // Ağırlıklı ortalama: Kalori %40, Protein %30, Karbonhidrat %20, Yağ %10
    double weightedScore =
        (calorieScore * 0.4 +
        proteinScore * 0.3 +
        carbScore * 0.2 +
        fatScore * 0.1);

    // 0-100 arasında sınırla
    return weightedScore.clamp(0, 100);
  }

  // Makro hedef skorunu hesapla (±%10 tolerans ile)
  double _calculateMacroScore(double actual, double target) {
    if (target == 0) return 0;
    if (actual == 0) return 0; // Hiç tüketilmemiş = 0 puan

    double ratio = actual / target;

    // %90-110 arası tam puan (±%10 tolerans)
    if (ratio >= 0.9 && ratio <= 1.1) {
      return 100;
    }

    // Eksik tüketim (<%90)
    if (ratio < 0.9) {
      // Linear azalma: 0.9'da 100 puan, 0'da 0 puan
      return (ratio / 0.9) * 100;
    }

    // Fazla tüketim (>%110)
    // 1.1'de 100 puan, 2.0'de 0 puan
    if (ratio > 2.0) return 0;

    // Linear azalma formülü
    return 100 * ((2.0 - ratio) / 0.9);
  }

  bool get isTargetMet =>
      achievementScore >= 80; // %80 ve üzeri başarılı sayılır
}

/// Haftalık özet motoru servisi
class WeeklySummaryService {
  // Singleton pattern
  static final WeeklySummaryService _instance =
      WeeklySummaryService._internal();
  factory WeeklySummaryService() => _instance;
  WeeklySummaryService._internal();

  /// Ana metod: Haftalık özet üret
  Future<WeeklySummary> generateWeeklySummary({
    DateTime? weekEndDate,
    required Future<List<DailyNutrition>> Function(DateTime start, DateTime end)
    dataFetcher,
  }) async {
    // Hafta sonu tarihini belirle (varsayılan: bugün)
    weekEndDate ??= DateTime.now();

    // Haftanın Pazar gününü bul
    DateTime weekEnd;
    if (weekEndDate.weekday == DateTime.sunday) {
      weekEnd = weekEndDate;
    } else {
      // Gelecek Pazar'ı bul
      int daysUntilSunday = DateTime.sunday - weekEndDate.weekday;
      if (daysUntilSunday < 0) daysUntilSunday += 7;
      weekEnd = weekEndDate.add(Duration(days: daysUntilSunday));
    }

    // Hafta başını hesapla (Pazartesi) - 6 gün geri git
    DateTime weekStart = weekEnd.subtract(Duration(days: 6));

    // Verileri çek
    List<DailyNutrition> weeklyData = await dataFetcher(weekStart, weekEnd);

    // Analiz et
    return _analyzeWeeklyData(weekStart, weekEnd, weeklyData);
  }

  /// Haftalık verileri analiz et ve özet oluştur
  WeeklySummary _analyzeWeeklyData(
    DateTime weekStart,
    DateTime weekEnd,
    List<DailyNutrition> weeklyData,
  ) {
    if (weeklyData.isEmpty) {
      return _createEmptySummary(weekStart, weekEnd);
    }

    // Temel istatistikler
    int totalDaysLogged = weeklyData.where((d) => d.mealsLogged > 0).length;
    int daysTargetMet = weeklyData.where((d) => d.isTargetMet).length;

    // Ortalamalar
    double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
    for (var day in weeklyData) {
      totalCalories += day.calories;
      totalProtein += day.protein;
      totalCarbs += day.carbs;
      totalFat += day.fat;
    }

    double avgCalories = totalDaysLogged > 0
        ? totalCalories / totalDaysLogged
        : 0;
    double avgProtein = totalDaysLogged > 0
        ? totalProtein / totalDaysLogged
        : 0;
    double avgCarbs = totalDaysLogged > 0 ? totalCarbs / totalDaysLogged : 0;
    double avgFat = totalDaysLogged > 0 ? totalFat / totalDaysLogged : 0;

    // En iyi ve en kötü günler
    DailyNutrition? bestDayData;
    DailyNutrition? worstDayData;
    double bestScore = 0;
    double worstScore = 100;

    for (var day in weeklyData.where((d) => d.mealsLogged > 0)) {
      double score = day.achievementScore;
      if (score > bestScore) {
        bestScore = score;
        bestDayData = day;
      }
      if (score < worstScore) {
        worstScore = score;
        worstDayData = day;
      }
    }

    // Hedef başarı oranı
    double targetAchievementRate = totalDaysLogged > 0
        ? (daysTargetMet / totalDaysLogged) * 100
        : 0;

    // Detaylı istatistikler
    Map<String, dynamic> detailedStats = _generateDetailedStats(weeklyData);

    // Motivasyon metni oluştur
    String summaryText = _generateSummaryText(
      totalDaysLogged: totalDaysLogged,
      daysTargetMet: daysTargetMet,
      targetAchievementRate: targetAchievementRate,
      bestDay: bestDayData?.date,
      worstDay: worstDayData?.date,
      detailedStats: detailedStats,
    );

    return WeeklySummary(
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalDaysLogged: totalDaysLogged,
      daysTargetMet: daysTargetMet,
      averageCalories: avgCalories,
      averageProtein: avgProtein,
      averageCarbs: avgCarbs,
      averageFat: avgFat,
      bestDay: bestDayData?.date,
      worstDay: worstDayData?.date,
      summaryText: summaryText,
      targetAchievementRate: targetAchievementRate,
      detailedStats: detailedStats,
    );
  }

  /// Detaylı istatistikler üret
  Map<String, dynamic> _generateDetailedStats(List<DailyNutrition> weeklyData) {
    Map<String, dynamic> stats = {
      'daily_breakdown': [],
      'macro_distribution': {},
      'missed_days': 0,
      'streak_days': 0,
      'improvement_areas': [],
    };

    // Günlük detaylar
    int currentStreak = 0;
    int maxStreak = 0;

    for (var day in weeklyData) {
      Map<String, dynamic> dayStats = {
        'date': DateFormat('yyyy-MM-dd').format(day.date),
        'day_name': _getDayNameTurkish(day.date.weekday),
        'calories': day.calories,
        'protein': day.protein,
        'carbs': day.carbs,
        'fat': day.fat,
        'achievement_score': day.achievementScore.toStringAsFixed(1),
        'target_met': day.isTargetMet,
        'meals_logged': day.mealsLogged,
      };
      stats['daily_breakdown'].add(dayStats);

      // Streak hesaplama
      if (day.mealsLogged > 0) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
        stats['missed_days'] = (stats['missed_days'] as int) + 1;
      }
    }

    stats['streak_days'] = maxStreak;

    // Makro dağılımı
    double totalCals = weeklyData.fold(0, (sum, d) => sum + d.calories);
    double totalProt = weeklyData.fold(
      0,
      (sum, d) => sum + d.protein * 4,
    ); // kalori
    double totalCarb = weeklyData.fold(0, (sum, d) => sum + d.carbs * 4);
    double totalFats = weeklyData.fold(0, (sum, d) => sum + d.fat * 9);

    if (totalCals > 0) {
      stats['macro_distribution'] = {
        'protein_percent': ((totalProt / totalCals) * 100).toStringAsFixed(1),
        'carbs_percent': ((totalCarb / totalCals) * 100).toStringAsFixed(1),
        'fat_percent': ((totalFats / totalCals) * 100).toStringAsFixed(1),
      };
    }

    // Gelişim alanları
    List<String> improvements = [];

    // Protein eksikliği kontrolü
    double avgProteinDeficit = 0;
    int proteinDeficitDays = 0;
    for (var day in weeklyData.where((d) => d.mealsLogged > 0)) {
      if (day.protein < day.targetProtein * 0.9) {
        avgProteinDeficit += (day.targetProtein - day.protein);
        proteinDeficitDays++;
      }
    }
    if (proteinDeficitDays > 3) {
      improvements.add(
        'Protein alımını artır (${proteinDeficitDays} gün eksik)',
      );
    }

    // Kalori dengesi
    double avgCalorieDeficit = 0;
    int calorieDeficitDays = 0;
    for (var day in weeklyData.where((d) => d.mealsLogged > 0)) {
      if (day.calories < day.targetCalories * 0.85) {
        avgCalorieDeficit += (day.targetCalories - day.calories);
        calorieDeficitDays++;
      }
    }
    if (calorieDeficitDays > 3) {
      improvements.add('Kalori hedefine daha yakın beslen');
    }

    // Düzenlilik
    if (stats['missed_days'] > 2) {
      improvements.add('Öğün girişlerinde daha düzenli ol');
    }

    stats['improvement_areas'] = improvements;

    return stats;
  }

  /// Motivasyon ve özet metni oluştur
  String _generateSummaryText({
    required int totalDaysLogged,
    required int daysTargetMet,
    required double targetAchievementRate,
    DateTime? bestDay,
    DateTime? worstDay,
    required Map<String, dynamic> detailedStats,
  }) {
    if (totalDaysLogged == 0) {
      return 'Bu hafta henüz veri girişi yapılmamış. Hadi başlayalım! 💪';
    }

    String text = '';

    // Giriş
    text += 'Bu hafta $totalDaysLogged gün veri girdin';

    // Başarı durumu
    if (daysTargetMet > 0) {
      text += ', $daysTargetMet gün hedefini tutturdun';

      // Motivasyon eklentisi
      if (targetAchievementRate >= 80) {
        text += '. Muhteşem performans! 🌟';
      } else if (targetAchievementRate >= 60) {
        text += '. İyi gidiyorsun! 👍';
      } else if (targetAchievementRate >= 40) {
        text += '. Gelişme var, devam et! 💪';
      } else {
        text += '. Hedeflerine odaklanmaya devam! 🎯';
      }
    } else {
      text += '. Hedeflerine ulaşmak için biraz daha çaba göster! 💪';
    }

    // En iyi gün
    if (bestDay != null && daysTargetMet > 0) {
      String dayName = _getDayNameTurkish(bestDay.weekday);
      text += ' En başarılı günün $dayName oldu.';
    }

    // Streak bilgisi
    int streak = detailedStats['streak_days'] ?? 0;
    if (streak >= 7) {
      text += ' Tüm hafta boyunca düzenli veri girişi yaptın, harika! 🔥';
    } else if (streak >= 3) {
      text += ' $streak gün üst üste veri girdin, güzel tempo!';
    }

    // Gelişim önerileri
    List improvements = detailedStats['improvement_areas'] ?? [];
    if (improvements.isNotEmpty && totalDaysLogged >= 3) {
      text += ' Öneri: ${improvements.first}';
    }

    return text;
  }

  /// Boş haftalık özet oluştur
  WeeklySummary _createEmptySummary(DateTime weekStart, DateTime weekEnd) {
    return WeeklySummary(
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalDaysLogged: 0,
      daysTargetMet: 0,
      averageCalories: 0,
      averageProtein: 0,
      averageCarbs: 0,
      averageFat: 0,
      bestDay: null,
      worstDay: null,
      summaryText: 'Bu hafta henüz veri girişi yapılmamış. Hadi başlayalım! 💪',
      targetAchievementRate: 0,
      detailedStats: {
        'daily_breakdown': [],
        'macro_distribution': {},
        'missed_days': 7,
        'streak_days': 0,
        'improvement_areas': ['Öğün girişlerine başla'],
      },
    );
  }

  /// Türkçe gün adı
  String _getDayNameTurkish(int weekday) {
    const days = {
      1: 'Pazartesi',
      2: 'Salı',
      3: 'Çarşamba',
      4: 'Perşembe',
      5: 'Cuma',
      6: 'Cumartesi',
      7: 'Pazar',
    };
    return days[weekday] ?? '';
  }
}

// ============= KULLANIM ÖRNEĞİ VE TEST =============

/// Test için yardımcı sınıf - MockDataProvider ile test uyumluluğu sağlar
class TestDataProvider {
  /// Test senaryoları için özelleştirilmiş veri sağlayıcı
  static Future<List<DailyNutrition>> fetchTestData(
    DateTime start,
    DateTime end,
  ) async {
    // Test için Cuma gününün kötü performans göstermesi gerekiyor
    return [
      DailyNutrition(
        date: start.add(Duration(days: 4)), // Cuma - Düşük performans
        calories: 800, // Hedefin %44'ü
        protein: 35, // Hedefin %35'i
        carbs: 70, // Hedefin %35'i
        fat: 20, // Hedefin %28'i
        targetCalories: 1800,
        targetProtein: 100,
        targetCarbs: 200,
        targetFat: 70,
        mealsLogged: 1,
      ),
    ];
  }
}

/// Mock veri sağlayıcı (gerçek uygulamada SQLite/Hive'dan gelecek)
class MockDataProvider {
  static Future<List<DailyNutrition>> fetchWeeklyData(
    DateTime start,
    DateTime end,
  ) async {
    // Start tarihini Pazartesi'ye normalize et (test uyumluluğu için)
    while (start.weekday != DateTime.monday) {
      start = start.subtract(Duration(days: 1));
    }

    // Simüle edilmiş haftalık veri
    return [
      DailyNutrition(
        date: start, // Pazartesi
        calories: 1750,
        protein: 95,
        carbs: 180,
        fat: 65,
        targetCalories: 1800,
        targetProtein: 100,
        targetCarbs: 200,
        targetFat: 70,
        mealsLogged: 3,
      ),
      DailyNutrition(
        date: start.add(Duration(days: 1)), // Salı
        calories: 1820,
        protein: 105,
        carbs: 195,
        fat: 68,
        targetCalories: 1800,
        targetProtein: 100,
        targetCarbs: 200,
        targetFat: 70,
        mealsLogged: 4,
      ),
      DailyNutrition(
        date: start.add(Duration(days: 2)), // Çarşamba - Boş gün
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        targetCalories: 1800,
        targetProtein: 100,
        targetCarbs: 200,
        targetFat: 70,
        mealsLogged: 0,
      ),
      DailyNutrition(
        date: start.add(Duration(days: 3)), // Perşembe
        calories: 1900,
        protein: 110,
        carbs: 210,
        fat: 72,
        targetCalories: 1800,
        targetProtein: 100,
        targetCarbs: 200,
        targetFat: 70,
        mealsLogged: 3,
      ),
      DailyNutrition(
        date: start.add(Duration(days: 4)), // Cuma - En kötü performans günü
        calories: 900, // Hedefin %50'si
        protein: 40, // Hedefin %40'ı
        carbs: 80, // Hedefin %40'ı
        fat: 25, // Hedefin %35'i
        targetCalories: 1800,
        targetProtein: 100,
        targetCarbs: 200,
        targetFat: 70,
        mealsLogged: 2, // Az öğün
      ),
      DailyNutrition(
        date: start.add(Duration(days: 5)), // Cumartesi
        calories: 1780,
        protein: 98,
        carbs: 190,
        fat: 67,
        targetCalories: 1800,
        targetProtein: 100,
        targetCarbs: 200,
        targetFat: 70,
        mealsLogged: 4,
      ),
      DailyNutrition(
        date: start.add(Duration(days: 6)), // Pazar
        calories: 2100,
        protein: 120,
        carbs: 230,
        fat: 80,
        targetCalories: 1800,
        targetProtein: 100,
        targetCarbs: 200,
        targetFat: 70,
        mealsLogged: 5,
      ),
    ];
  }
}

/// Kullanım örneği
void main() async {
  final summaryService = WeeklySummaryService();

  // Haftalık özet üret (bu haftanın özeti)
  WeeklySummary summary = await summaryService.generateWeeklySummary(
    dataFetcher: MockDataProvider.fetchWeeklyData,
  );

  // JSON çıktısı
  print('=== HAFTALIK ÖZET JSON ===');
  print(summary.toJsonString());

  // Detaylı istatistikler
  print('\n=== DETAYLI İSTATİSTİKLER ===');
  print(
    'Hafta: ${DateFormat('dd.MM.yyyy').format(summary.weekStart)} - ${DateFormat('dd.MM.yyyy').format(summary.weekEnd)}',
  );
  print('Veri girilen günler: ${summary.totalDaysLogged}');
  print('Hedef tutulan günler: ${summary.daysTargetMet}');
  print('Başarı oranı: %${summary.targetAchievementRate.toStringAsFixed(0)}');
  print('Ortalama kalori: ${summary.averageCalories.toStringAsFixed(0)} kcal');
  print('Ortalama protein: ${summary.averageProtein.toStringAsFixed(0)}g');
  print('Ortalama karb: ${summary.averageCarbs.toStringAsFixed(0)}g');
  print('Ortalama yağ: ${summary.averageFat.toStringAsFixed(0)}g');

  if (summary.bestDay != null) {
    print(
      'En iyi gün: ${DateFormat('EEEE', 'tr_TR').format(summary.bestDay!)}',
    );
  }
  if (summary.worstDay != null) {
    print(
      'En zayıf gün: ${DateFormat('EEEE', 'tr_TR').format(summary.worstDay!)}',
    );
  }

  print('\n📊 ÖZET: ${summary.summaryText}');

  // Detaylı stats
  var stats = summary.detailedStats;
  print('\n=== EK BİLGİLER ===');
  print('Ardışık gün rekoru: ${stats['streak_days']} gün');
  print('Atlanan günler: ${stats['missed_days']} gün');

  if (stats['improvement_areas'] != null &&
      (stats['improvement_areas'] as List).isNotEmpty) {
    print('\n📌 Gelişim Önerileri:');
    for (var improvement in stats['improvement_areas']) {
      print('  • $improvement');
    }
  }
}
