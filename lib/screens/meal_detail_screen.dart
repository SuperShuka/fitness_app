import 'package:flutter/material.dart';
import 'package:fitness_app/models/meal.dart';
import 'package:fitness_app/models/food_item.dart';
import 'package:fitness_app/services/nutrition_service.dart';
import 'package:fitness_app/screens/food_search_screen.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  final String mealName;
  final DateTime date;

  MealDetailScreen({
    required this.mealId,
    required this.mealName,
    required this.date,
  });

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final NutritionService _nutritionService = NutritionService();
  Meal? _meal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeal();
  }

  Future<void> _loadMeal() async {
    setState(() {
      _isLoading = true;
    });

    final dailyLog = await _nutritionService.getDailyLog(widget.date);
    if (dailyLog != null) {
      final meal = dailyLog.meals.firstWhere(
            (meal) => meal.id == widget.mealId,
        orElse: () => Meal(
          id: widget.mealId,
          userId: '',
          name: widget.mealName,
          date: widget.date,
          entries: [],
        ),
      );

      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchScreen(),
      ),
    );

    if (result != null && result is FoodItem) {
      await _nutritionService.addFoodToMeal(widget.mealId, result);
      await _loadMeal();
    }
  }

  Future<void> _removeFoodEntry(int index) async {
    if (_meal != null) {
      await _nutritionService.removeFoodFromMeal(widget.mealId, index);
      await _loadMeal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealName),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Meal summary card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutrientColumn('Calories',
                      '${_meal?.totalCalories.toInt() ?? 0}', 'kcal'),
                  _buildNutrientColumn('Protein',
                      '${_meal?.totalProtein.toInt() ?? 0}', 'g'),
                  _buildNutrientColumn('Carbs',
                      '${_meal?.totalCarbs.toInt() ?? 0}', 'g'),
                  _buildNutrientColumn('Fat',
                      '${_meal?.totalFat.toInt() ?? 0}', 'g'),
                ],
              ),
            ),
          ),

          // Food items list
          Expanded(
            child: _meal?.entries.isEmpty ?? true
                ? Center(
              child: Text(
                'No food items added yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            )
                : ListView.builder(
              itemCount: _meal!.entries.length,
              itemBuilder: (context, index) {
                final entry = _meal!.entries[index];
                final foodItem = entry.foodItem;
                final servingSize = entry.servingSize;

                return Dismissible(
                  key: Key(foodItem.id + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    _removeFoodEntry(index);
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: foodItem.imageUrl != null
                          ? ClipOval(
                        child: Image.network(
                          foodItem.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.restaurant);
                          },
                        ),
                      )
                          : Icon(Icons.restaurant),
                    ),
                    title: Text(foodItem.name),
                    subtitle: Text(
                      'Serving size: ${servingSize.toStringAsFixed(1)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(foodItem.calories * servingSize).toInt()} kcal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'P: ${(foodItem.protein * servingSize).toStringAsFixed(1)}g  '
                              'C: ${(foodItem.carbs * servingSize).toStringAsFixed(1)}g  '
                              'F: ${(foodItem.fat * servingSize).toStringAsFixed(1)}g',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFood,
        child: Icon(Icons.add),
        tooltip: 'Add Food',
      ),
    );
  }

  Widget _buildNutrientColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}