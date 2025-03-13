import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitness_app/models/daily_log.dart';
import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/services/nutrition_service.dart';
import 'package:fitness_app/widgets/nutrient_progress_bar.dart';
import 'package:fitness_app/widgets/meal_card.dart';

import '../models/meal.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Center(child: Text('Hello World')),
    );
  }
}