/// Model representing a meal entry with photo and nutrition data
class Meal {
  final String? id;
  final String userId;
  final String? photoUrl;
  final String? photoPath;
  final String description;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double? confidence;
  final DateTime createdAt;

  const Meal({
    this.id,
    required this.userId,
    this.photoUrl,
    this.photoPath,
    required this.description,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.confidence,
    required this.createdAt,
  });

  /// Create a Meal from JSON data
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      photoUrl: json['photoUrl'] as String?,
      photoPath: json['photoPath'] as String?,
      description: json['description'] as String,
      kcal: (json['kcal'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert Meal to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (photoPath != null) 'photoPath': photoPath,
      'description': description,
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      if (confidence != null) 'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy of this meal with updated values
  Meal copyWith({
    String? id,
    String? userId,
    String? photoUrl,
    String? photoPath,
    String? description,
    double? kcal,
    double? protein,
    double? carbs,
    double? fat,
    double? confidence,
    DateTime? createdAt,
  }) {
    return Meal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      photoUrl: photoUrl ?? this.photoUrl,
      photoPath: photoPath ?? this.photoPath,
      description: description ?? this.description,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Meal(id: $id, description: $description, kcal: $kcal, protein: $protein, carbs: $carbs, fat: $fat)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Meal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}