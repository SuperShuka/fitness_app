import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Sample data
  final double caloriesConsumed = 300;
  final double caloriesTarget = 1481;
  final List<Macro> macros = [
    Macro(name: "Protein", consumed: 50, target: 100, color: Colors.orangeAccent),
    Macro(name: "Carbs", consumed: 15, target: 181, color: Colors.pinkAccent),
    Macro(name: "Fat", consumed: 10, target: 32, color: Colors.tealAccent),
  ];
  final List<Meal> meals = [
    Meal(name: "Lunch", details: "Grilled Chicken", calories: 350),
    Meal(name: "Snack", details: "Almonds", calories: 150),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5DC), Color(0xFFE5E5DB)], // Beige gradient
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Profile Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '08 Dec',
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.black87),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Add navigation to profile screen here
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Calorie Summary
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.black54),
                                const SizedBox(width: 10),
                                Text(
                                  'Calories',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            CircularPercentIndicator(
                              radius: 80.0,
                              lineWidth: 12.0,
                              percent: caloriesConsumed / caloriesTarget,
                              center: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    caloriesConsumed.toInt().toString(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '/ ${caloriesTarget.toInt()} kcal',
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                              progressColor: Colors.black87,
                              backgroundColor: Colors.black.withOpacity(0.1),
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Macronutrient Summaries
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: macros.map((macro) {
                        return ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            children: [
                              CircularPercentIndicator(
                                radius: 45.0,
                                lineWidth: 8.0,
                                percent: macro.consumed / macro.target,
                                center: Text(
                                  '${macro.consumed.toInt()}g',
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                progressColor: macro.color,
                                backgroundColor: Colors.black.withOpacity(0.1),
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                macro.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // Today's Meal Section
                    Text(
                      'Today\'s Meal',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: meals.map((meal) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.black.withOpacity(0.1),
                                  child: const Icon(Icons.fastfood, color: Colors.black54),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.name,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        meal.details,
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${meal.calories} kcal',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.blueGrey, Colors.teal],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}

// Data Models
class Macro {
  final String name;
  final double consumed;
  final double target;
  final Color color;

  Macro({required this.name, required this.consumed, required this.target, required this.color});
}

class Meal {
  final String name;
  final String details;
  final int calories;

  Meal({required this.name, required this.details, required this.calories});
}