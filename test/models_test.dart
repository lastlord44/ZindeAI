import 'package:flutter_test/flutter_test.dart';
import 'package:zindeai/models/user.dart';
import 'package:zindeai/models/meal.dart';

void main() {
  group('User Model Tests', () {
    test('User toJson and fromJson work correctly', () {
      final user = User(
        id: 'test123',
        height: 175.0,
        weight: 70.0,
        targetKcal: 2000,
        createdAt: DateTime(2024, 9, 16),
      );

      final json = user.toJson();
      final userFromJson = User.fromJson(json);

      expect(userFromJson.id, equals(user.id));
      expect(userFromJson.height, equals(user.height));
      expect(userFromJson.weight, equals(user.weight));
      expect(userFromJson.targetKcal, equals(user.targetKcal));
    });
  });

  group('Meal Model Tests', () {
    test('Meal toJson and fromJson work correctly', () {
      final meal = Meal(
        id: 'meal123',
        userId: 'user123',
        photoUrl: 'https://example.com/photo.jpg',
        description: 'Menemen with bread',
        kcal: 350,
        protein: 15.5,
        carbs: 30.0,
        fat: 20.0,
        createdAt: DateTime(2024, 9, 16),
      );

      final json = meal.toJson();
      final mealFromJson = Meal.fromJson(json);

      expect(mealFromJson.id, equals(meal.id));
      expect(mealFromJson.userId, equals(meal.userId));
      expect(mealFromJson.description, equals(meal.description));
      expect(mealFromJson.kcal, equals(meal.kcal));
      expect(mealFromJson.protein, equals(meal.protein));
      expect(mealFromJson.carbs, equals(meal.carbs));
      expect(mealFromJson.fat, equals(meal.fat));
    });
  });
}