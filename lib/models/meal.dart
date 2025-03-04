import 'food_item.dart';

class Meal {
  final String id;
  final String userId;
  final String name;
  final DateTime date;
  final List<MealEntry> entries;

  Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.entries,
  });

  double get totalCalories => entries.fold(0, (sum, entry) => sum + (entry.foodItem.calories * entry.servingSize));
  double get totalProtein => entries.fold(0, (sum, entry) => sum + (entry.foodItem.protein * entry.servingSize));
  double get totalCarbs => entries.fold(0, (sum, entry) => sum + (entry.foodItem.carbs * entry.servingSize));
  double get totalFat => entries.fold(0, (sum, entry) => sum + (entry.foodItem.fat * entry.servingSize));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'date': date.toIso8601String(),
      'entries': entries.map((entry) => entry.toMap()).toList(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      entries: List<MealEntry>.from(
        map['entries']?.map((entry) => MealEntry.fromMap(entry)) ?? [],
      ),
    );
  }
}

class MealEntry {
  final FoodItem foodItem;
  final double servingSize;
  final String? notes;

  MealEntry({
    required this.foodItem,
    this.servingSize = 1.0,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodItem': foodItem.toMap(),
      'servingSize': servingSize,
      'notes': notes,
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      foodItem: FoodItem.fromMap(map['foodItem']),
      servingSize: map['servingSize'] ?? 1.0,
      notes: map['notes'],
    );
  }
}