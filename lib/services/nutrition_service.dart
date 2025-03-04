import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/models/daily_log.dart';
import 'package:fitness_app/models/food_item.dart';
import 'package:fitness_app/models/meal.dart';
import 'package:uuid/uuid.dart';

class NutritionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  String get _userId => _auth.currentUser!.uid;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<DailyLog?> getDailyLog(DateTime date) async {
    final dateString = DateTime(date.year, date.month, date.day).toIso8601String();

    final snapshot = await _db
        .collection('dailyLogs')
        .where('userId', isEqualTo: _userId)
        .where('date', isEqualTo: dateString)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return DailyLog.fromMap(snapshot.docs.first.data());
    }

    final newLog = DailyLog(
      id: _uuid.v4(),
      userId: _userId,
      date: date,
      meals: [
        Meal(id: _uuid.v4(), userId: _userId, name: 'Breakfast', date: date, entries: []),
        Meal(id: _uuid.v4(), userId: _userId, name: 'Lunch', date: date, entries: []),
        Meal(id: _uuid.v4(), userId: _userId, name: 'Dinner', date: date, entries: []),
        Meal(id: _uuid.v4(), userId: _userId, name: 'Snacks', date: date, entries: []),
      ],
    );

    await saveDailyLog(newLog);
    return newLog;
  }

  Future<void> saveDailyLog(DailyLog log) async {
    await _db.collection('dailyLogs').doc(log.id).set(log.toMap());
  }

  Future<void> addFoodToMeal(String mealId, FoodItem food, {double servingSize = 1.0, String? notes}) async {
    final logSnapshot = await _db
        .collection('dailyLogs')
        .where('userId', isEqualTo: _userId)
        .where('meals', arrayContains: {'id': mealId})
        .limit(1)
        .get();

    if (logSnapshot.docs.isNotEmpty) {
      final log = DailyLog.fromMap(logSnapshot.docs.first.data());
      final updatedMeals = log.meals.map((meal) {
        if (meal.id == mealId) {
          final updatedEntries = [
            ...meal.entries,
            MealEntry(
              foodItem: food,
              servingSize: servingSize,
              notes: notes,
            ),
          ];

          return Meal(
            id: meal.id,
            userId: meal.userId,
            name: meal.name,
            date: meal.date,
            entries: updatedEntries,
          );
        }
        return meal;
      }).toList();

      final updatedLog = DailyLog(
        id: log.id,
        userId: log.userId,
        date: log.date,
        meals: updatedMeals,
        caloriesBurned: log.caloriesBurned,
        stepsCount: log.stepsCount,
        weight: log.weight,
        notes: log.notes,
      );

      await saveDailyLog(updatedLog);
    }
  }

  Future<void> updateCaloriesBurned(double calories) async {
    final log = await getDailyLog(_today);
    if (log != null) {
      final updatedLog = DailyLog(
        id: log.id,
        userId: log.userId,
        date: log.date,
        meals: log.meals,
        caloriesBurned: calories,
        stepsCount: log.stepsCount,
        weight: log.weight,
        notes: log.notes,
      );

      await saveDailyLog(updatedLog);
    }
  }

  Future<void> logWeight(double weight) async {
    final log = await getDailyLog(_today);
    if (log != null) {
      final updatedLog = DailyLog(
        id: log.id,
        userId: log.userId,
        date: log.date,
        meals: log.meals,
        caloriesBurned: log.caloriesBurned,
        stepsCount: log.stepsCount,
        weight: weight,
        notes: log.notes,
      );

      await saveDailyLog(updatedLog);
    }
  }

  Future<List<Map<String, dynamic>>> getWeightHistory(int days) async {
    final endDate = _today;
    final startDate = endDate.subtract(Duration(days: days));

    final snapshot = await _db
        .collection('dailyLogs')
        .where('userId', isEqualTo: _userId)
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .where('weight', isNull: false)
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((doc) {
      final data = doc.data();
      return {
        'date': DateTime.parse(data['date']),
        'weight': data['weight'],
      };
    })
        .toList();
  }

  Future<List<FoodItem>> searchFood(String query) async {
    if (query.length < 3) return [];

    final snapshot = await _db
        .collection('foods')
        .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('name', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.data()))
        .toList();
  }

  Future<FoodItem> saveFood(FoodItem food) async {
    final foodId = food.id.isEmpty ? _uuid.v4() : food.id;
    final newFood = FoodItem(
      id: foodId,
      name: food.name,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      imageUrl: food.imageUrl,
      isFavorite: food.isFavorite,
      barcode: food.barcode,
    );

    await _db.collection('foods').doc(foodId).set(newFood.toMap());

    await _db.collection('users')
        .doc(_userId)
        .collection('myFoods')
        .doc(foodId)
        .set(newFood.toMap());

    return newFood;
  }

  Future<List<FoodItem>> getFavoriteFoods() async {
    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('myFoods')
        .where('isFavorite', isEqualTo: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.data()))
        .toList();
  }

  Future<List<FoodItem>> getRecentFoods() async {
    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('myFoods')
        .orderBy('name')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.data()))
        .toList();
  }
}