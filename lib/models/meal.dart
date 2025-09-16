class Meal {
  final String id;
  final String userId;
  final String photoUrl;
  final String description;
  final int kcal;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
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
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'photoUrl': photoUrl,
      'description': description,
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      description: json['description'] ?? '',
      kcal: json['kcal'] ?? 0,
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}