import 'package:flutter/material.dart';
import 'package:fitness_app/models/meal.dart';

class MealCard extends StatelessWidget {
  final String mealName;
  final IconData icon;
  final Meal? meal;
  final Function() onTap;

  const MealCard({
    Key? key,
    required this.mealName,
    required this.icon,
    required this.meal,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final caloriesConsumed = meal?.totalCalories.toInt() ?? 0;

    return GestureDetector(
      onTap: onTap,
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