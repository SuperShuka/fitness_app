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
  final String? barcode;

  FoodItem({
  required this.id,
  required this.name,
  required this.calories,
  required this.protein,
  required this.carbs,
  required this.fat,
  this