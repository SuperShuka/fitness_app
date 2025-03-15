import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Save user profile to Firestore
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.uid).set(profile.toMap());
    } catch (e) {
      print('Error saving user profile: $e');
      throw e;
    }
  }

  // Get user profile from Firestore
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      throw e;
    }
  }

  // Calculate nutrition targets based on user profile
  Future<UserProfile> calculateNutritionTargets(UserProfile profile) async {
    // Calculate age from birth year
    int currentYear = DateTime.now().year;
    int age = currentYear - int.parse(profile.birthYear ?? '2000');

    // Base metabolic rate (BMR) using Mifflin-St Jeor Equation
    double bmr;
    if (profile.gender == 'male') {
      bmr = 10 * profile.weight + 6.25 * profile.height - 5 * age + 5;
    } else {
      bmr = 10 * profile.weight + 6.25 * profile.height - 5 * age - 161;
    }

    // Activity factor
    double activityFactor;
    switch (profile.activityLevel) {
      case 'beginner':
        activityFactor = 1.2; // Sedentary
        break;
      case 'intermediate':
        activityFactor = 1.55; // Moderate activity
        break;
      case 'advanced':
        activityFactor = 1.725; // Very active
        break;
      default:
        activityFactor = 1.2;
    }

    // Total Daily Energy Expenditure (TDEE)
    double tdee = bmr * activityFactor;

    // Adjust calories based on goal
    int dailyCalories;
    switch (profile.goal) {
      case 'lose_weight':
        dailyCalories = (tdee - 500).round(); // 500 calorie deficit
        break;
      case 'gain_weight':
        dailyCalories = (tdee + 500).round(); // 500 calorie surplus
        break;
      default: // maintain_weight
        dailyCalories = tdee.round();
    }

    int dailyProtein = (profile.weight * 2).round();
    int dailyFat = ((dailyCalories * 0.25) / 9).round();
    int dailyCarbsCals = dailyCalories - (dailyProtein * 4) - (dailyFat * 9);
    int dailyCarbs = (dailyCarbsCals / 4).round();

    int dailyWater = (profile.weight * 30).round();

    return profile.copyWith(
      age: age,
      dailyCalorieTarget: dailyCalories,
      dailyProteinTarget: dailyProtein,
      dailyCarbsTarget: dailyCarbs,
      dailyFatTarget: dailyFat,
      dailyWaterTarget: dailyWater,
    );
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.uid).update(profile.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }
}