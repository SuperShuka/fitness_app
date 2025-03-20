import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'nutrition_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  // Save user profile to Firestore
  Future<void> saveUserProfile(UserProfile userProfile) async {
    try {
      await _usersCollection
          .doc(userProfile.userId)
          .set(userProfile.toMap(), SetOptions(merge: true));

      print('User profile saved successfully');
    } catch (e) {
      print('Error saving user profile: $e');
      throw e;
    }
  }

  // Get user profile from Firestore
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      throw e;
    }
  }

  // Update specific fields in user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      // Add lastUpdated timestamp
      data['lastUpdated'] = DateTime.now();

      await _usersCollection
          .doc(userId)
          .update(data);

      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  // Update user weight and recalculate nutritional needs
  Future<void> updateUserWeight(String userId, double newWeight) async {
    try {
      // Get current user profile
      UserProfile? currentProfile = await getUserProfile(userId);

      if (currentProfile != null) {
        // Create nutrition service
        final nutritionService = NutritionService();

        // Calculate age
        final currentYear = DateTime.now().year;
        final age = currentYear - int.parse(currentProfile.birthYear);

        // Calculate new daily calorie needs
        final dailyCalories = nutritionService.calculateDailyCalories(
          gender: currentProfile.gender,
          age: age,
          height: currentProfile.height,
          weight: newWeight,
          activityLevel: currentProfile.workoutFrequency,
          goal: currentProfile.primaryGoal,
        );

        // Calculate new macro distribution
        final macros = nutritionService.calculateMacroDistribution(
          calories: dailyCalories,
          goal: currentProfile.primaryGoal,
        );

        // Update user profile with new weight and nutritional needs
        await _usersCollection.doc(userId).update({
          'weight': newWeight,
          'dailyCalories': dailyCalories,
          'proteinGoal': macros['protein'],
          'carbsGoal': macros['carbs'],
          'fatGoal': macros['fat'],
          'lastUpdated': DateTime.now(),
        });

        print('User weight updated and nutritional needs recalculated');
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      print('Error updating user weight: $e');
      throw e;
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      print('User profile deleted successfully');
    } catch (e) {
      print('Error deleting user profile: $e');
      throw e;
    }
  }
}