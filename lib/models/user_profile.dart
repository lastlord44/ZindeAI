/// Model representing a user profile with basic health and nutrition data
class UserProfile {
  final String? id;
  final String? name;
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final String? gender; // 'male', 'female', 'other'
  final String? activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final double? targetKcal;
  final double? targetProtein;
  final double? targetCarbs;
  final double? targetFat;
  final List<String>? dietaryRestrictions;
  final List<String>? allergies;
  final String? goal; // 'lose_weight', 'maintain_weight', 'gain_weight', 'gain_muscle'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.id,
    this.name,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.activityLevel,
    this.targetKcal,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    this.dietaryRestrictions,
    this.allergies,
    this.goal,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a UserProfile from JSON data
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      name: json['name'] as String?,
      age: json['age'] as int?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      activityLevel: json['activityLevel'] as String?,
      targetKcal: (json['targetKcal'] as num?)?.toDouble(),
      targetProtein: (json['targetProtein'] as num?)?.toDouble(),
      targetCarbs: (json['targetCarbs'] as num?)?.toDouble(),
      targetFat: (json['targetFat'] as num?)?.toDouble(),
      dietaryRestrictions: (json['dietaryRestrictions'] as List?)?.cast<String>(),
      allergies: (json['allergies'] as List?)?.cast<String>(),
      goal: json['goal'] as String?,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is DateTime
              ? json['updatedAt'] as DateTime
              : DateTime.parse(json['updatedAt'] as String))
          : null,
    );
  }

  /// Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (gender != null) 'gender': gender,
      if (activityLevel != null) 'activityLevel': activityLevel,
      if (targetKcal != null) 'targetKcal': targetKcal,
      if (targetProtein != null) 'targetProtein': targetProtein,
      if (targetCarbs != null) 'targetCarbs': targetCarbs,
      if (targetFat != null) 'targetFat': targetFat,
      if (dietaryRestrictions != null) 'dietaryRestrictions': dietaryRestrictions,
      if (allergies != null) 'allergies': allergies,
      if (goal != null) 'goal': goal,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Calculate BMI if height and weight are available
  double? get bmi {
    if (height == null || weight == null || height == 0) return null;
    return weight! / ((height! / 100) * (height! / 100));
  }

  /// Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal weight';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Calculate estimated daily calories using Mifflin-St Jeor equation
  double? get estimatedDailyCalories {
    if (age == null || height == null || weight == null || gender == null) {
      return null;
    }

    // Base metabolic rate (BMR)
    double bmr;
    if (gender == 'male') {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! + 5;
    } else {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! - 161;
    }

    // Activity factor
    double activityFactor;
    switch (activityLevel) {
      case 'sedentary':
        activityFactor = 1.2;
        break;
      case 'light':
        activityFactor = 1.375;
        break;
      case 'moderate':
        activityFactor = 1.55;
        break;
      case 'active':
        activityFactor = 1.725;
        break;
      case 'very_active':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2;
    }

    return bmr * activityFactor;
  }

  /// Create a copy of this profile with updated values
  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? activityLevel,
    double? targetKcal,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    String? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      targetKcal: targetKcal ?? this.targetKcal,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, targetKcal: $targetKcal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}