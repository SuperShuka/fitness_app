class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final String? servingUnit; // e.g., "g", "ml", "oz", "piece"
  final double? servingSize; // Amount in the above unit for one serving
  final String? userId; // If it's a custom food item, store the creator's ID
  final bool isCustom;
  final bool isFavorite;
  final String? barcode;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.servingUnit,
    this.servingSize,
    this.userId,
    this.isCustom = false,
    this.isFavorite = false,
    this.barcode,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    String? servingUnit,
    double? servingSize,
    String? userId,
    bool? isCustom,
    bool? isFavorite,
    String? barcode,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      servingUnit: servingUnit ?? this.servingUnit,
      servingSize: servingSize ?? this.servingSize,
      userId: userId ?? this.userId,
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
      barcode: barcode ?? this.barcode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameLower': name.toLowerCase(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'servingUnit': servingUnit,
      'servingSize': servingSize,
      'userId': userId,
      'isCustom': isCustom,
      'isFavorite': isFavorite,
      'barcode': barcode,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      calories: (map['calories'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
      fiber: map['fiber']?.toDouble(),
      sugar: map['sugar']?.toDouble(),
      servingUnit: map['servingUnit'],
      servingSize: map['servingSize']?.toDouble(),
      userId: map['userId'],
      isCustom: map['isCustom'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      barcode: map['barcode'],
    );
  }

  Map<String, double> getNutritionForServing(double servings) {
    return {
      'calories': calories * servings,
      'protein': protein * servings,
      'carbs': carbs * servings,
      'fat': fat * servings,
      'fiber': (fiber ?? 0) * servings,
      'sugar': (sugar ?? 0) * servings,
    };
  }
}

class FoodEntry {
  final FoodItem foodItem;
  final double servingSize;
  final DateTime timestamp;

  FoodEntry({
    required this.foodItem,
    required this.servingSize,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodItem': foodItem.toMap(),
      'servingSize': servingSize,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      foodItem: FoodItem.fromMap(map['foodItem']),
      servingSize: (map['servingSize'] ?? 1.0).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}