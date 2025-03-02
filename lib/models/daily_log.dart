import 'package:fitness_app/models/meal.dart';

class DailyLog {
  final String id;
  final String userId;
  final DateTime date;
  final List<Meal> meals;
  final double? caloriesBurned;
  final double? stepsCount;
  final double? weight;
  final String? notes;

  DailyLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.meals,
    this.caloriesBurned,
    this.stepsCount,
    this.weight,
    this.notes,
  });

  // Calculate daily totals
  double get totalCaloriesConsumed => meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  double get totalProtein => meals.fold(0, (sum, meal) => sum + meal.totalProtein);
  double get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.totalCarbs);
  double get totalFat => meals.fold(0, (sum, meal) => sum + meal.totalFat);
  double get netCalories => totalCaloriesConsumed - (caloriesBurned ?? 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'caloriesBurned': caloriesBurned,
      'stepsCount': stepsCount,
      'weight': weight,
      'notes': notes,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date']),
      meals: List<Meal>.from(
        map['meals']?.map((meal) => Meal.fromMap(meal)) ?? [],
      ),
      caloriesBurned: map['caloriesBurned'],
      stepsCount: map['stepsCount'],
      weight: map['weight'],
      notes: map['notes'],
    );
  }
}