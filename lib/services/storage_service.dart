import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart';
import '../models/meal.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // User operations
  Future<void> saveUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }
  
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return User.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
  
  // Meal operations
  Future<String> saveMeal(Meal meal) async {
    try {
      final docRef = await _firestore.collection('meals').add(meal.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save meal: $e');
    }
  }
  
  Future<List<Meal>> getUserMeals(String userId, {DateTime? date}) async {
    try {
      Query query = _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);
      
      // Filter by date if provided
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        query = query
            .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
            .where('createdAt', isLessThan: endOfDay);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Meal.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get meals: $e');
    }
  }
  
  // Photo upload
  Future<String> uploadPhoto(File photoFile, String userId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('photos/$userId/$fileName');
      
      final uploadTask = await ref.putFile(photoFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }
  
  // Delete meal
  Future<void> deleteMeal(String mealId) async {
    try {
      await _firestore.collection('meals').doc(mealId).delete();
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }
}