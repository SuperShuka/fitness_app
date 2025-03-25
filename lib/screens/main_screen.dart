import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

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

  final List<MealLog> meals = [
    MealLog(
      name: "Fried Chicken Cutlet",
      calories: 920,
      protein: 60,
      carbs: 40,
      fat: 56,
      image: "assets/fried_chicken.jpg", // You'll need to add this asset
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

              // Date Selection Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final date = selectedDate.subtract(Duration(days: selectedDate.weekday - index));
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: date.day == selectedDate.day
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              weekdays[index],
                              style: TextStyle(
                                color: date.day == selectedDate.day
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: date.day == selectedDate.day
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Calories Left Card
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      caloriesLeft.toInt().toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Calories left',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              CircularPercentIndicator(
                                radius: 50,
                                lineWidth: 10,
                                percent: (caloriesTotal - caloriesLeft) / caloriesTotal,
                                center: Icon(Icons.local_fire_department, color: Colors.orange),
                                progressColor: Colors.green,
                                backgroundColor: Colors.green.shade100,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Macros Breakdown
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: macros.map((macro) =>
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      CircularPercentIndicator(
                                        radius: 35,
                                        lineWidth: 8,
                                        percent: 1 - (macro.left / macro.total),
                                        center: Icon(macro.icon, color: macro.color, size: 20),
                                        progressColor: macro.color,
                                        backgroundColor: macro.color.withOpacity(0.2),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '${macro.left}g',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${macro.name} left',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ).toList(),
                        ),
                      ),

                      // Meals Log
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logs',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: meals.length + 1,
                              itemBuilder: (context, index) {
                                if (index == meals.length) {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.add, color: Colors.black87),
                                      onPressed: () {
                                        // Add meal functionality
                                      },
                                    ),
                                  );
                                }

                                final meal = meals[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.asset(
                                          meal.image,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              meal.name,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                _buildMacroIcon(Icons.fastfood, Colors.red, meal.protein),
                                                _buildMacroIcon(Icons.bakery_dining, Colors.green, meal.carbs),
                                                _buildMacroIcon(Icons.cake, Colors.orange, meal.fat),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${meal.calories}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
            // Add functionality
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMacroIcon(IconData icon, Color color, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Data Models remain the same
class MacroItem {
  final String name;
  final int left;
  final int total;
  final IconData icon;
  final Color color;

  MacroItem({
    required this.name,
    required this.left,
    required this.total,
    required this.icon,
    required this.color,
  });
}

class MealLog {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String image;

  MealLog({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.image,
  });
}