import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../core/const/color_constants.dart';
import '../core/const/data_constants.dart';
import '../core/const/text_constants.dart';

class MainScreen extends StatelessWidget {
  // Sample data - in a real app, this would come from state management
  final int caloriesConsumed = 1250;
  final int caloriesGoal = DataConstants.defaultCalorieGoal;
  final int caloriesRemaining = 750; // Calculated as goal - consumed
  final double proteinProgress = 0.7;
  final double carbsProgress = 0.5;
  final double fatProgress = 0.3;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? ColorConstants.backgroundDark
        : ColorConstants.backgroundLight;
    final cardColor = isDarkMode
        ? ColorConstants.cardDark
        : ColorConstants.cardLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          TextConstants.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () {},
                  ),
                  Text(
                    'Today, March 24',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Calorie summary card
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Circular progress indicator
                          CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 12.0,
                            animation: true,
                            percent: caloriesConsumed / caloriesGoal,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  caloriesRemaining.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  'remaining',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: ColorConstants.caloriesRemaining,
                            backgroundColor: ColorConstants.caloriesRemaining.withOpacity(0.2),
                          ),

                          // Calories breakdown
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCalorieItem(
                                    'Goal',
                                    caloriesGoal.toString(),
                                    Icons.flag_outlined,
                                    ColorConstants.textPrimary,
                                    context,
                                  ),
                                  SizedBox(height: 12),
                                  _buildCalorieItem(
                                    'Consumed',
                                    caloriesConsumed.toString(),
                                    Icons.restaurant_outlined,
                                    ColorConstants.caloriesConsumed,
                                    context,
                                  ),
                                  SizedBox(height: 12),
                                  _buildCalorieItem(
                                    'Burned',
                                    '0',
                                    Icons.local_fire_department_outlined,
                                    ColorConstants.caloriesBurned,
                                    context,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Nutrition progress
              Text(
                'Nutrition',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildNutrientProgress(
                        'Protein',
                        '${(proteinProgress * DataConstants.defaultProteinGoal).round()}g / ${DataConstants.defaultProteinGoal}g',
                        proteinProgress,
                        ColorConstants.protein,
                      ),
                      SizedBox(height: 16),
                      _buildNutrientProgress(
                        'Carbs',
                        '${(carbsProgress * DataConstants.defaultCarbsGoal).round()}g / ${DataConstants.defaultCarbsGoal}g',
                        carbsProgress,
                        ColorConstants.caloriesConsumed,
                      ),
                      SizedBox(height: 16),
                      _buildNutrientProgress(
                        'Fat',
                        '${(fatProgress * DataConstants.defaultFatGoal).round()}g / ${DataConstants.defaultFatGoal}g',
                        fatProgress,
                        ColorConstants.caloriesBurned,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Today's meals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Meals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All'),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Meal cards
              _buildMealCard(
                TextConstants.breakfast,
                'Eggs & Toast',
                '350 kcal',
                Icons.breakfast_dining_outlined,
                context,
                cardColor,
              ),
              SizedBox(height: 12),
              _buildMealCard(
                TextConstants.lunch,
                'Chicken Salad',
                '450 kcal',
                Icons.lunch_dining_outlined,
                context,
                cardColor,
              ),
              SizedBox(height: 12),
              _buildMealCard(
                TextConstants.dinner,
                'Grilled Salmon',
                '450 kcal',
                Icons.dinner_dining_outlined,
                context,
                cardColor,
              ),
              SizedBox(height: 12),
              _buildMealCard(
                TextConstants.snacks,
                'Yogurt & Apple',
                '0 kcal',
                Icons.apple_outlined,
                context,
                cardColor,
                isEmpty: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardColor,
        selectedItemColor: ColorConstants.primaryColor,
        unselectedItemColor: ColorConstants.textSecondary,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: TextConstants.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: TextConstants.diary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: TextConstants.recipes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: TextConstants.profile,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: ColorConstants.primaryColor,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCalorieItem(String label, String value, IconData icon, Color color, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientProgress(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMealCard(String mealType, String mealName, String calories, IconData icon, BuildContext context, Color cardColor, {bool isEmpty = false}) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorConstants.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: ColorConstants.primaryColor,
          ),
        ),
        title: Text(
          mealType,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: isEmpty
            ? Text('Tap to add ${mealType.toLowerCase()}')
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(mealName),
            SizedBox(height: 2),
            Text(calories),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
