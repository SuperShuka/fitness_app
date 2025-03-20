import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _userStream;
  late Stream<QuerySnapshot> _mealsStream;

  DateTime selectedDate = DateTime.now();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _userStream = _firestore.collection('users').doc(userId).snapshots();
      _mealsStream = _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
          .snapshots();
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        _mealsStream = _firestore
            .collection('meals')
            .where('userId', isEqualTo: userId)
            .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
            .snapshots();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to different screens based on index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No user data found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            if (userData == null) {
              return const Center(child: Text('User data is empty'));
            }

            final userProfile = UserProfile.fromMap(userData);

            return Column(
              children: [
                _buildAppBar(userProfile),
                _buildDateSelector(),
                _buildCalorieCard(userProfile),
                _buildMacroCards(userProfile),
                _buildMealLogs(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add meal screen
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildAppBar(UserProfile userProfile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dr. Cal',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '1',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final DateTime today = DateTime.now();
    final DateTime startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final currentDate = startOfWeek.add(Duration(days: index));
          final isSelected = DateFormat('yyyy-MM-dd').format(currentDate) ==
              DateFormat('yyyy-MM-dd').format(selectedDate);
          final isToday = DateFormat('yyyy-MM-dd').format(currentDate) ==
              DateFormat('yyyy-MM-dd').format(today);

          return GestureDetector(
            onTap: () => _onDateChanged(currentDate),
            child: Container(
              width: 40,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdays[currentDate.weekday % 7],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    currentDate.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalorieCard(UserProfile userProfile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '1506',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: 0.75,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        strokeWidth: 8,
                      ),
                      Center(
                        child: Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              'Calories left',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCards(UserProfile userProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildMacroCard(
            title: 'Protein left',
            value: '90g',
            icon: '🍗',
            color: Colors.red,
            progress: 0.6,
          ),
          SizedBox(width: 8),
          _buildMacroCard(
            title: 'Carbs left',
            value: '180g',
            icon: '🍞',
            color: Colors.green,
            progress: 0.4,
          ),
          SizedBox(width: 8),
          _buildMacroCard(
            title: 'Fat left',
            value: '40g',
            icon: '🧀',
            color: Colors.orange,
            progress: 0.7,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
    required double progress,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 6,
                  ),
                  Center(
                    child: Text(
                      icon,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealLogs() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _mealsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No meals logged for today'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final mealData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              mealData['imageUrl'] ?? 'https://via.placeholder.com/60',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            mealData['name'] ?? 'Unnamed meal',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                              Text(' ${mealData['calories'] ?? 0}'),
                              SizedBox(width: 8),
                              Text('🍗 ${mealData['protein'] ?? 0}g'),
                              SizedBox(width: 8),
                              Text('🍞 ${mealData['carbs'] ?? 0}g'),
                              SizedBox(width: 8),
                              Text('🧀 ${mealData['fat'] ?? 0}g'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              // Show meal options
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}