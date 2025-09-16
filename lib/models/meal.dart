// meal.dart - Yemek modeli
// TODO: Foto path + makrolar

class Meal {
  final String id;
  final String userId;
  final String photoUrl;
  final String description;
  final int kcal;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime createdAt;

  const Meal({
    required this.id,
    required this.userId,
    required this.photoUrl,
    required this.description,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdAt,
  });

  // TODO: fromJson ve toJson metodları eklenecek
  // TODO: Firebase Firestore entegrasyonu
}