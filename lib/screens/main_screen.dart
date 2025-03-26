import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/models/user_profile.dart';
import 'package:fitness_app/widgets/add_log_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/log_item.dart';
import '../models/macro_item.dart';
import '../services/logs_notifier.dart';
import '../widgets/calories_card.dart';
import '../widgets/date_selector.dart';
import '../widgets/log_list.dart';
import '../widgets/macro_breakdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  DateTime selectedDate = DateTime.now();
  final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    ref.read(logsProvider.notifier).loadLogsFromFirebase(selectedDate);
  }

  double calculateTotalCalories(List<LogItem> logs) {
    return logs.fold(0, (total, log) => total + log.calories);
  }

  List<MacroItem> calculateMacroBreakdown(List<LogItem> logs) {
    int protein = 0, carbs = 0, fat = 0;

    for (var log in logs) {
      if (log.macros != null) {
        for (var macro in log.macros!) {
          switch (macro.icon) {
            case '🍗':
              protein += macro.value;
              break;
            case '🍞':
              carbs += macro.value;
              break;
            case '🧀':
              fat += macro.value;
              break;
          }
        }
      }
    }
    return [
      MacroItem(
        name: "Protein",
        left:  - protein,
        total: 100,
        icon: Icons.fastfood,
        color: Colors.red,
      ),
      MacroItem(
        name: "Carbs",
        left: 300 - carbs,
        total: 300,
        icon: Icons.bakery_dining,
        color: Colors.green,
      ),
      MacroItem(
        name: "Fat",
        left: 50 - fat,
        total: 50,
        icon: Icons.cake,
        color: Colors.orange,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(logsProvider);

    final totalCalories = calculateTotalCalories(logs);
    final caloriesLeft = 2500 - totalCalories;
    final macros = calculateMacroBreakdown(logs);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5DC), Color(0xFFE5E5DB)], // Beige gradient
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar and Date Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dr. Cal',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to profile
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.person_outline, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              // Date Selector Widget
              DateSelector(
                selectedDate: selectedDate,
                weekdays: weekdays,
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                  ref.read(logsProvider.notifier).loadLogsFromFirebase(date);
                },
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()
                  ),
                  child: Column(
                    children: [
                      // Calories Card Widget
                      CaloriesCard(
                        caloriesLeft: caloriesLeft,
                        caloriesTotal: caloriesTotal,
                      ),

                      // Macro Breakdown Widget
                      MacroBreakdown(macros: macros),

                      // Meal Log List Widget
                      LogList(logs: logs),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, left: 30),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              isScrollControlled: false,
              builder: (context) => AddLogWidget(),
            );
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}