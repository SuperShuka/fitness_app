import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/models/daily_log.dart';
import 'package:fitness_app/models/food_item.dart';
import 'package:fitness_app/models/meal.dart';
import 'package:fitness_app/models/user_profile.dart';

class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  String _formatDateForDocId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<UserProfile> getUserProfile() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .get();

      if (snapshot.exists) {
        return UserProfile.fromMap(snapshot.data()!);
      } else {
        return UserProfile(
          id: _userId,
          name: '',
          email: _auth.currentUser?.email ?? '',
          age: 30,
          height: 170,
          weight: 70,
          goal: 'Maintain Weight',
          activityLevel: 'Moderate',
        );
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return UserProfile(
        id: _userId,
        name: '',
        email: _auth.currentUser?.email ?? '',
        age: 30,
        height: 170,
        weight: 70,
        goal: 'Maintain Weight',
        activityLevel: 'Moderate',
      );
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .set(profile.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  Future<DailyLog?> getDailyLog(DateTime date) async {
    try {
      final dateStr = _formatDateForDocId(date);
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('dailyLogs')
          .doc(dateStr)
          .get();

      if (snapshot.exists) {
        return DailyLog.fromMap(snapshot.data()!);
      } else {
        final newDailyLog = DailyLog(
          id: dateStr,
          userId: _userId,
          date: date,
          meals: [
            Meal(id: '${dateStr}_breakfast', userId: _userId, name: 'Breakfast', date: date, entries: []),
            Meal(id: '${dateStr}_lunch', userId: _userId, name: 'Lunch', date: date, entries: []),
            Meal(id: '${dateStr}_dinner', userId: _userId, name: 'Dinner', date: date, entries: []),
            Meal(id: '${dateStr}_snacks', userId: _userId, name: 'Snacks', date: date, entries: []),
          ],
          caloriesBurned: 0,
          weight: null,
        );

        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('dailyLogs')
            .doc(dateStr)
            .set(newDailyLog.toMap());

        return newDailyLog;
      }
    } catch (e) {
      print('Error getting daily log: $e');
      return null;
    }
  }

  Future<void> addFoodToMeal(String mealId, FoodItem foodItem, {double servingSize = 1.0}) async {
    try {
      final parts = mealId.split('_');
      final dateStr = parts[0];
      final dateParts = dateStr.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      final dailyLog = await getDailyLog(date);
      if (dailyLog == null) {
        throw Exception('Failed to get daily log');
      }

      final mealIndex = dailyLog.meals.indexWhere((meal) => meal.id == mealId);
      if (mealIndex >= 0) {
        final entry = FoodEntry(
          foodItem: foodItem,
          servingSize: servingSize,
          timestamp: DateTime.now(),
        );

        final updatedEntries = [...dailyLog.meals[mealIndex].entries, entry];

        final updatedMeal = Meal(
          id: dailyLog.meals[mealIndex].id,
          userId: dailyLog.meals[mealIndex].userId,
          name: dailyLog.meals[mealIndex].name,
          date: dailyLog.meals[mealIndex].date,
          entries: updatedEntries,
        );

        final updatedMeals = [...dailyLog.meals];
        updatedMeals[mealIndex] = updatedMeal;

        final updatedDailyLog = DailyLog(
          id: dailyLog.id,
          userId: dailyLog.userId,
          date: dailyLog.date,
          meals: updatedMeals,
          caloriesBurned: dailyLog.caloriesBurned,
          weight: dailyLog.weight,
        );

        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('dailyLogs')
            .doc(dateStr)
            .set(updatedDailyLog.toMap());
      }
    } catch (e) {
      print('Error adding food to meal: $e');
      throw e;
    }
  }

  Future<void> removeFoodFromMeal(String mealId, int foodIndex) async {
    try {
      final parts = mealId.split('_');
      final dateStr = parts[0];
      final dateParts = dateStr.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      final dailyLog = await getDailyLog(date);
      if (dailyLog == null) {
        throw Exception('Failed to get daily log');
      }

      final mealIndex = dailyLog.meals.indexWhere((meal) => meal.id == mealId);
      if (mealIndex >= 0 && foodIndex < dailyLog.meals[mealIndex].entries.length) {
        final updatedEntries = [...dailyLog.meals[mealIndex].entries];
        updatedEntries.removeAt(foodIndex);

        final updatedMeal = Meal(
          id: dailyLog.meals[mealIndex].id,
          userId: dailyLog.meals[mealIndex].userId,
          name: dailyLog.meals[mealIndex].name,
          date: dailyLog.meals[mealIndex].date,
          entries: updatedEntries,
        );

        final updatedMeals = [...dailyLog.meals];
        updatedMeals[mealIndex] = updatedMeal;

        final updatedDailyLog = DailyLog(
          id: dailyLog.id,
          userId: dailyLog.userId,
          date: dailyLog.date,
          meals: updatedMeals,
          caloriesBurned: dailyLog.caloriesBurned,
          weight: dailyLog.weight,
        );

        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('dailyLogs')
            .doc(dateStr)
            .set(updatedDailyLog.toMap());
      }
    } catch (e) {
      print('Error removing food from meal: $e');
      throw e;
    }
  }

  Future<void> updateCaloriesBurned(DateTime date, double calories) async {
    try {
      final dateStr = _formatDateForDocId(date);

      final dailyLog = await getDailyLog(date);
      if (dailyLog == null) {
        throw Exception('Failed to get daily log');
      }

      final updatedDailyLog = DailyLog(
        id: dailyLog.id,
        userId: dailyLog.userId,
        date: dailyLog.date,
        meals: dailyLog.meals,
        caloriesBurned: calories,
        weight: dailyLog.weight,
      );

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('dailyLogs')
          .doc(dateStr)
          .set(updatedDailyLog.toMap());
    } catch (e) {
      print('Error updating calories burned: $e');
      throw e;
    }
  }

  Future<void> updateWeight(DateTime date, double weight) async {
    try {
      final dateStr = _formatDateForDocId(date);

      final dailyLog = await getDailyLog(date);
      if (dailyLog == null) {
        throw Exception('Failed to get daily log');
      }

      final updatedDailyLog = DailyLog(
        id: dailyLog.id,
        userId: dailyLog.userId,
        date: dailyLog.date,
        meals: dailyLog.meals,
        caloriesBurned: dailyLog.caloriesBurned,
        weight: weight,
      );

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('dailyLogs')
          .doc(dateStr)
          .set(updatedDailyLog.toMap());
    } catch (e) {
      print('Error updating weight: $e');
      throw e;
    }
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final lowercaseQuery = query.toLowerCase();

      final snapshot = await _firestore
          .collection('foods')
          .where('nameLower', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('nameLower', isLessThanOrEqualTo: lowercaseQuery + '\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => FoodItem.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error searching food items: $e');
      return [];
    }
  }

  Future<FoodItem> addCustomFoodItem(FoodItem foodItem) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(_userI