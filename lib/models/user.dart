// user.dart - Kullanıcı profil modeli
// TODO: Boy, kilo, hedef kalori

class User {
  final String id;
  final int height; // cm
  final double weight; // kg
  final int targetKcal;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.height,
    required this.weight,
    required this.targetKcal,
    required this.createdAt,
  });

  // TODO: fromJson ve toJson metodları eklenecek
  // TODO: BMR hesaplama metodları
  // TODO: Firebase Firestore entegrasyonu
}