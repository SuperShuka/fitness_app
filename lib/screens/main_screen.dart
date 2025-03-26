import 'package:fitness_app/widgets/add_log_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/log_item.dart';
import '../models/macro_item.dart';
import '../widgets/calories_card.dart';
import '../widgets/date_selector.dart';
import '../widgets/log_list.dart';
import '../widgets/macro_breakdown.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime selectedDate = DateTime.now();
  final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // Sample data
  final double caloriesLeft = 1907;
  final double caloriesTotal = 2500;
  final List<MacroItem> macros = [
    MacroItem(
      name: "Protein",
      left: 80,
      total: 100,
      icon: Icons.fastfood,
      color: Colors.red,
    ),
    MacroItem(
      name: "Carbs",
      left: 242,
      total: 300,
      icon: Icons.bakery_dining,
      color: Colors.green,
    ),
    MacroItem(
      name: "Fat",
      left: 38,
      total: 50,
      icon: Icons.cake,
      color: Colors.orange,
    ),
  ];

  final List<LogItem> logs = [
    LogItem(
      name: "Chicken Salad",
      calories: 400,
      image: "assets/chicken_salad.jpg",
      timestamp: DateTime(2024, 3, 25, 3, 26),
      type: LogItemType.meal,
      macros: [
        MacroDetail(icon: '🍗', value: 40),
        MacroDetail(icon: '🍞', value: 20),
        MacroDetail(icon: '🧀', value: 15),
      ],
    ),
    LogItem(
      name: "Soccer",
      calories: -460,
      timestamp: DateTime(2024, 3, 25, 22, 42),
      type: LogItemType.training,
    ),
    LogItem(
      name: "Lait Sirop Fraise",
      calories: 150,
      timestamp: DateTime(2024, 3, 25, 22, 20),
      type: LogItemType.meal,
      macros: [
        MacroDetail(icon: '🍗', value: 6),
        MacroDetail(icon: '🍞', value: 22),
        MacroDetail(icon: '🧀', value: 5),
      ],
    ),
    LogItem(
      name: "Patate et Choux Fleur",
      calories: 102,
      timestamp: DateTime(2024, 3, 25, 22, 20),
      type: LogItemType.meal,
      macros: [
        MacroDetail(icon: '🍗', value: 3),
        MacroDetail(icon: '🍞', value: 22),
        MacroDetail(icon: '🧀', value: 0),
      ],
    ),
    LogItem(
      name: "Frites Poulet",
      calories: 650,
      timestamp: DateTime(2024, 3, 25, 22, 20),
      type: LogItemType.meal,
      macros: [
        MacroDetail(icon: '🍗', value: 35),
        MacroDetail(icon: '🍞', value: 55),
        MacroDetail(icon: '🧀', value: 35),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                },
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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