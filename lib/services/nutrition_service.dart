import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      return UserProfile.fromDocument(docSnapshot);
    }

    return null;
  }

  Stream<UserProfile> userProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => UserProfile.fromDocument(snapshot));
  }

  Future<void> updateUserWeight(String uid, double weight) async {
    await _firestore.collection('users').doc(uid).update({
      'weight': weight,
    });
  }

  Future<void> updateUserGoal(String uid, String goal) async {
    await _firestore.collection('users').doc(uid).update({
      'goal': goal,
    });
  }

  Future<void> updateDailyTargets(String uid, {
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required int water,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'dailyCalorieTarget': calories,
      'dailyProteinTarget': protein,
      'dailyCarbsTarget': carbs,
      'dailyFatTarget': fat,
      'dailyWaterTarget': water,
    });
  }
}