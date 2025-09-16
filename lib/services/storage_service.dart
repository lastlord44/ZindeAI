import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Service for handling data storage with Firebase
class StorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Save user profile to Firestore
  static Future<bool> saveUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(profileData, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  /// Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Save meal data to Firestore
  static Future<String?> saveMeal({
    required String userId,
    required Map<String, dynamic> mealData,
  }) async {
    try {
      final docRef = await _firestore.collection('meals').add({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        ...mealData,
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error saving meal: $e');
      return null;
    }
  }

  /// Get meals for a user
  static Future<List<Map<String, dynamic>>> getUserMeals(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      debugPrint('Error getting meals: $e');
      return [];
    }
  }

  /// Upload image to Firebase Storage
  static Future<String?> uploadImage({
    required String userId,
    required String imagePath,
    String? customPath,
  }) async {
    try {
      final file = File(imagePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = customPath ?? 'photos/$userId/$timestamp.jpg';
      
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Delete meal from Firestore
  static Future<bool> deleteMeal(String mealId) async {
    try {
      await _firestore.collection('meals').doc(mealId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting meal: $e');
      return false;
    }
  }

  /// Get daily totals for a user
  static Future<Map<String, double>> getDailyTotals({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .get();

      double totalKcal = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalKcal += (data['kcal'] as num?)?.toDouble() ?? 0;
        totalProtein += (data['protein'] as num?)?.toDouble() ?? 0;
        totalCarbs += (data['carbs'] as num?)?.toDouble() ?? 0;
        totalFat += (data['fat'] as num?)?.toDouble() ?? 0;
      }

      return {
        'kcal': totalKcal,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
      };
    } catch (e) {
      debugPrint('Error getting daily totals: $e');
      return {
        'kcal': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
      };
    }
  }
}