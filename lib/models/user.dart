class User {
  final String id;
  final double height; // cm
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
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'height': height,
      'weight': weight,
      'targetKcal': targetKcal,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      targetKcal: json['targetKcal'] ?? 2000,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}