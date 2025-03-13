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

  Future<List<FoodItem>> searchFoods(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      // Search in both predefined foods and custom foods
      final predefinedFoodsQuery = await _firestore
          .collection('foods')
          .where('nameLower', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('nameLower', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
          .limit(10)
          .get();

      final customFoodsQuery = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('customFoods')
          .where('nameLower', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('nameLower', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
          .limit(10)
          .get();

      final predefinedFoods = predefinedFoodsQuery.docs
          .map((doc) => FoodItem.fromMap(doc.data()))
          .toList();

      final customFoods = customFoodsQuery.docs
          .map((doc) => FoodItem.fromMap(doc.data()))
          .toList();

      final combinedFoods = [
        ...predefinedFoods,
        ...customFoods.map((food) => food.copyWith(isCustom: true))
      ];

      for (var food in combinedFoods) {
        food = food.copyWith(isFavorite: food.isFavorite);
      }

      return combinedFoods;
    } catch (e) {
      print('Error searching foods: $e');
      return [];
    }
  }

  // Method to update a food item (us*ed in toggling favorite)
  Future<void> updateFoodItem(FoodItem foodItem) async {
    try {
      if (foodItem.isCustom ?? false) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('customFoods')
            .doc(foodItem.id)
            .set(foodItem.toMap());
      }

      foodItem = foodItem.copyWith(isFavorite: true);
    } catch (e) {
      print('Error updating food item: $e');
    }
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
          uid: _userId,
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
        uid: _userId,
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

        final updatedEntries = dailyLog.meals[mealIndex].entries;

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

  // This completes your truncated nutrition_service.dart file:

  Future<FoodItem> addCustomFoodItem(FoodItem foodItem) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('customFoods')
          .doc();

      final newFoodItem = foodItem.copyWith(
        id: docRef.id,
        isCustom: true,
        userId: _userId,
      );

      await docRef.set(newFoodItem.toMap());
      return newFoodItem;
    } catch (e) {
      print('Error adding custom food item: $e');
      throw e;
    }
  }

  Future<List<FoodItem>> getRecentFoods() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('recentFoods')
          .orderBy('lastUsed', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => FoodItem.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting recent foods: $e');
      return [];
    }
  }

  Future<void> addToRecentFoods(FoodItem foodItem) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('recentFoods')
          .doc(foodItem.id)
          .set({
        ...foodItem.toMap(),
        'lastUsed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding to recent foods: $e');
    }
  }

  Future<List<FoodItem>> getFavoriteFoods() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favoriteFoods')
          .get();

      return snapshot.docs.map((doc) => FoodItem.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting favorite foods: $e');
      return [];
    }
  }

  Future<void> toggleFavoriteFood(FoodItem foodItem) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('favoriteFoods')
          .doc(foodItem.id);

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set(foodItem.toMap());
      }
    } catch (e) {
      print('Error toggling favorite food: $e');
    }
  }

  Future<bool> isFoodFavorite(String foodId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favoriteFoods')
          .doc(foodId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking if food is favorite: $e');
      return false;
    }
  }

  Future<List<DailyLog>> getWeeklyLogs() async {
    try {
      final today = DateTime.now();
      final weekAgo = DateTime(today.year, today.month, today.day - 7);

      final startDate = _formatDateForDocId(weekAgo);
      final endDate = _formatDateForDocId(today);

      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('dailyLogs')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDate)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endDate)
          .get();

      return snapshot.docs
          .map((doc) => DailyLog.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting weekly logs: $e');
      return [];
    }
  }

  Future<Map<String, double>> getNutritionSummary(DateTime date) async {
    try {
      final dailyLog = await getDailyLog(date);
      if (dailyLog == null) {
        return {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          'fiber': 0,
          'sugar': 0,
        };
      }

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalFiber = 0;
      double totalSugar = 0;

      for (final meal in dailyLog.meals) {
        for (final entry in meal.entries) {
          final servingFactor = entry.servingSize;
          totalCalories += entry.foodItem.calories * servingFactor;
          totalProtein += entry.foodItem.protein * servingFactor;
          totalCarbs += entry.foodItem.carbs * servingFactor;
          totalFat += entry.foodItem.fat * servingFactor;
          totalFiber += (entry.foodItem.fiber ?? 0) * servingFactor;
          totalSugar += (entry.foodItem.sugar ?? 0) * servingFactor;
        }
      }

      return {
        'calories': totalCalories,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
        'fiber': totalFiber,
        'sugar': totalSugar,
      };
    } catch (e) {
      print('Error getting nutrition summary: $e');
      return {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'fiber': 0,
        'sugar': 0,
      };
    }
  }

  Future<Map<String, double>> calculateDailyGoals() async {
    try {
      final profile = await getUserProfile();

      // Calculate BMR using Harris-Benedict equation
      double bmr;
      if (profile.gender == 'male') {
        bmr = 88.362 + (13.397 * profile.weight) + (4.799 * profile.height) - (5.677 * profile.age);
      } else {
        bmr = 447.593 + (9.247 * profile.weight) + (3.098 * profile.height) - (4.330 * profile.age);
      }

      // Apply activity multiplier
      double activityMultiplier;
      switch (profile.activityLevel) {
        case 'Sedentary':
          activityMultiplier = 1.2;
          break;
        case 'Lightly Active':
          activityMultiplier = 1.375;
          break;
        case 'Moderately Active':
          activityMultiplier = 1.55;
          break;
        case 'Very Active':
          activityMultiplier = 1.725;
          break;
        case 'Extra Active':
          activityMultiplier = 1.9;
          break;
        default:
          activityMultiplier = 1.375;
      }

      double tdee = bmr * activityMultiplier;

      // Adjust based on goal
      double calorieGoal;
      switch (profile.goal) {
        case 'Lose Weight':
          calorieGoal = tdee - 500; // 500 calorie deficit
          break;
        case 'Gain Weight':
          calorieGoal = tdee + 500; // 500 calorie surplus
          break;
        default:
          calorieGoal = tdee; // Maintain weight
      }

      // Calculate macronutrient goals (example distribution)
      // Protein: 30%, Carbs: 40%, Fat: 30%
      double proteinGoal = (calorieGoal * 0.3) / 4; // 4 calories per gram of protein
      double carbsGoal = (calorieGoal * 0.4) / 4;   // 4 calories per gram of carbs
      double fatGoal = (calorieGoal * 0.3) / 9;     // 9 calories per gram of fat

      return {
        'calories': calorieGoal,
        'protein': proteinGoal,
        'carbs': carbsGoal,
        'fat': fatGoal,
        'fiber': 25, // General recommendation
        'sugar': 25, // General recommendation
      };
    } catch (e) {
      print('Error calculating daily goals: $e');
      return {
        'calories': 2000,
        'protein': 150,
        'carbs': 200,
        'fat': 67,
        'fiber': 25,
        'sugar': 25,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getWeightHistory() async {
    try {
      final logs = await getWeeklyLogs();

      return logs
          .where((log) => log.weight != null)
          .map((log) => {
        'date': log.date,
        'weight': log.weight,
      })
          .toList();
    } catch (e) {
      print('Error getting weight history: $e');
      return [];
    }
  }
}