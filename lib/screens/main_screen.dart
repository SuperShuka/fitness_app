import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitness_app/models/daily_log.dart';
import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/screens/meal_detail_screen.dart';
import 'package:fitness_app/services/nutrition_service.dart';
import 'package:fitness_app/services/fitness_service.dart';
import 'package:fitness_app/widgets/nutrient_progress_bar.dart';
import 'package:fitness_app/widgets/meal_card.dart';

import '../models/meal.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final NutritionService _nutritionService = NutritionService();
  final FitnessService _fitnessService = FitnessService();

  DailyLog? _dailyLog;
  UserProfile? _userProfile;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final dailyLog = await _nutritionService.getDailyLog(_selectedDate);

    final userProfile = await _nutritionService.getUserProfile();

    try {
      await _fitnessService.syncFitnessData();
    } catch (e) {
      print('Error syncing fitness data: $e');
    }

    setState(() {
      _dailyLog = dailyLog;
      _userProfile = userProfile;
      _isLoading = false;
    });
  }

  double get _calorieTarget {
    if (_userProfile == null) return 2000;

    double bmr;
    if (_userProfile!.age > 0 && _userProfile!.height > 0 && _userProfile!.weight > 0) {
      bmr = 88.362 + (13.397 * _userProfile!.weight) +
          (4.799 * _userProfile!.height) - (5.677 * _userProfile!.age);

      bmr *= 1.55;

      if (_userProfile!.goal == 'Lose Weight') {
        bmr -= 500;
      } else if (_userProfile!.goal == 'Gain Weight' || _userProfile!.goal == 'Gain Muscle') {
        bmr += 500;
      }

      return bmr;
    }

    return 2000;
  }

  double get _remainingCalories {
    if (_dailyLog == null) return _calorieTarget;

    return _calorieTarget - _dailyLog!.totalCaloriesConsumed + (_dailyLog!.caloriesBurned ?? 0);
  }

  Map<String, double> get _macroTargets {

    double proteinTarget = (_calorieTarget * 0.3) / 4;
    double carbsTarget = (_calorieTarget * 0.4) / 4;
    double fatTarget = (_calorieTarget * 0.3) / 9;

    return {
      'protein': proteinTarget,
      'carbs': carbsTarget,
      'fat': fatTarget,
    };
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  void _openMealDetail(String mealName) {
    final mealId = _dailyLog?.meals.firstWhere((meal) => meal.name == mealName).id;
    if (mealId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealDetailScreen(
            mealId: mealId,
            mealName: mealName,
            date: _selectedDate,
          ),
        ),
      ).then((_) => _loadData());
    }
  }

  Future<void> _syncFitnessData() async {
    final granted = await _fitnessService.requestPermissions();
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Syncing fitness data...'))
      );

      await _fitnessService.syncFitnessData();
      await _fitnessService.syncLatestWeight();
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fitness data updated!'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied. Cannot sync fitness data.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _selectDate(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat('EEEE, MMM d').format(_selectedDate)),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: _syncFitnessData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Calories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCalorieCounter(
                            'Consumed',
                            _dailyLog?.totalCaloriesConsumed.toInt() ?? 0,
                            Colors.blue,
                          ),
                          _buildCalorieCounter(
                            'Burned',
                            _dailyLog?.caloriesBurned?.toInt() ?? 0,
                            Colors.orange,
                          ),
                          _buildCalorieCounter(
                            'Remaining',
                            _remainingCalories.toInt(),
                            Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (_dailyLog?.totalCaloriesConsumed ?? 0) / _calorieTarget,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _remainingCalories < 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Macronutrients',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      NutrientProgressBar(
                        label: 'Protein',
                        value: _dailyLog?.totalProtein ?? 0,
                        target: _macroTargets['protein'] ?? 0,
                        color: Colors.red,
                      ),
                      SizedBox(height: 8),
                      NutrientProgressBar(
                        label: 'Carbs',
                        value: _dailyLog?.totalCarbs ?? 0,
                        target: _macroTargets['carbs'] ?? 0,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8),
                      NutrientProgressBar(
                        label: 'Fat',
                        value: _dailyLog?.totalFat ?? 0,
                        target: _macroTargets['fat'] ?? 0,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              Text(
                'Meals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),

              _buildMealCard(
                'Breakfast',
                Icons.wb_sunny,
                _dailyLog?.meals.firstWhere((meal) => meal.name == 'Breakfast', orElse: () =>
                    Meal(id: '', userId: '', name: 'Breakfast', date: DateTime.now(), entries: [])),
              ),

              _buildMealCard(
                'Lunch',
                Icons.restaurant,
                _dailyLog?.meals.firstWhere((meal) => meal.name == 'Lunch', orElse: () =>
                    Meal(id: '', userId: '', name: 'Lunch', date: DateTime.now(), entries: [])),
              ),

              _buildMealCard(
                'Dinner',
                Icons.dinner_dining,
                _dailyLog?.meals.firstWhere((meal) => meal.name == 'Dinner', orElse: () =>
                    Meal(id: '', userId: '', name: 'Dinner', date: DateTime.now(), entries: [])),
              ),

              _buildMealCard(
                'Snacks',
                Icons.cake,
                _dailyLog?.meals.firstWhere((meal) => meal.name == 'Snacks', orElse: () =>
                    Meal(id: '', userId: '', name: 'Snacks', date: DateTime.now(), entries: [])),
              ),

              SizedBox(height: 16),

              if (_dailyLog?.weight != null)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_dailyLog!.weight!.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieCounter(String label, int value, Color color) {
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
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(String mealName, IconData icon, Meal? meal) {
    final caloriesConsumed = meal?.totalCalories.toInt() ?? 0;

    return GestureDetector(
      onTap: () => _openMealDetail(mealName),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      meal?.entries.isEmpty ?? true
                          ? 'Tap to add food'
                          : '${meal!.entries.length} items',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$caloriesConsumed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}