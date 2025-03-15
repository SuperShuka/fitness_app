import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/nutrition_service.dart';
import 'package:fitness_app/services/firestore_service.dart';
import 'main_screen.dart';

class ProfileSetupFlow extends StatefulWidget {
  @override
  _ProfileSetupFlowState createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends State<ProfileSetupFlow> {
  final FirestoreService _firestoreService = FirestoreService();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  int _totalSteps = 8;

  String? _gender;
  String? _primaryGoal;
  String? _workoutFrequency;
  String? _birthYear;
  double _height = 177;
  double _weight = 60;
  double _targetWeight = 60;
  double _weeklyGoal = 1.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _saveUserDataAndNavigate();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _previousStep,
        )
            : null,
        title: Text(
          'Step ${_currentStep + 1} of $_totalSteps',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: _buildCurrentStep(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildGenderStep();
      case 1:
        return _buildPrimaryGoalStep();
      case 2:
        return _buildWorkoutFrequencyStep();
      case 3:
        return _buildBirthYearStep();
      case 4:
        return _buildHeightStep();
      case 5:
        return _buildWeightStep();
      case 6:
        if (_primaryGoal == 'maintain_weight') {
          _currentStep++;
          return _buildWeeklyGoalStep();
        } else {
          return _buildTargetWeightStep();
        }
      case 7:
          return _buildWeeklyGoalStep();
      default:
        return _buildLoadingScreen();
    }
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select your gender",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          _buildGenderOption('Male', '👨', _gender == 'male'),
          SizedBox(height: 16),
          _buildGenderOption('Female', '👩', _gender == 'female'),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, String emoji, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = gender.toLowerCase();
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(width: 16),
            Text(
              gender,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your primary goal?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          _buildGoalOption('Lose Weight', '🔥', 'lose_weight'),
          SizedBox(height: 16),
          _buildGoalOption('Maintain Weight', '⚖️', 'maintain_weight'),
          SizedBox(height: 16),
          _buildGoalOption('Gain Weight', '💪', 'gain_weight'),
        ],
      ),
    );
  }

  Widget _buildGoalOption(String title, String emoji, String value) {
    final isSelected = _primaryGoal == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _primaryGoal = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutFrequencyStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How often do you workout?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          _buildFrequencyOption('0-2 workouts now and then', '😌', 'beginner'),
          SizedBox(height: 16),
          _buildFrequencyOption('3-5 a few workouts per week', '💪', 'intermediate'),
          SizedBox(height: 16),
          _buildFrequencyOption('6+ dedicated athlete', '🗿', 'advanced'),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String title, String emoji, String value) {
    final isSelected = _workoutFrequency == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _workoutFrequency = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthYearStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your Birth Year?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final year = 2005 - index + 2;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _birthYear = year.toString();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _birthYear == year.toString() ? Colors.grey.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: _birthYear == year.toString() ? FontWeight.bold : FontWeight.normal,
                          color: _birthYear == year.toString() ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your Height?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                ),
                child: Text(
                  'CM',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Center(
            child: Text(
              '${_height.toInt()} cm',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 200,
                    child: Slider(
                      value: _height,
                      min: 140,
                      max: 220,
                      divisions: 160,
                      activeColor: Colors.black,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setState(() {
                          _height = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your current Weight?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                ),
                child: Text(
                  'KG',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                ),
                child: Text(
                  'LB',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Center(
            child: Text(
              '${_weight.toInt()} kg',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                height: 80,
                child: Slider(
                  value: _weight,
                  min: 40,
                  max: 120,
                  divisions: 160,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (value) {
                    setState(() {
                      _weight = value;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
  Widget _buildTargetWeightStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your target Weight?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                ),
                child: Text(
                  'KG',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                ),
                child: Text(
                  'LB',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Center(
            child: Text(
              '${_targetWeight.toInt()} kg',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                height: 80,
                child: Slider(
                  value: _targetWeight,
                  min: 40,
                  max: 120,
                  divisions: 160,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (value) {
                    setState(() {
                      _targetWeight = value;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildWeeklyGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is your weekly goal?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Text(
              '${_weeklyGoal.toStringAsFixed(1)} kg/week',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                height: 80,
                child: Slider(
                  value: _weeklyGoal,
                  min: 0.1,
                  max: 2.0,
                  divisions: 19,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (value) {
                    setState(() {
                      _weeklyGoal = value;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLoadingScreen() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Building your personal program",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserDataAndNavigate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create initial user profile
        UserProfile userProfile = UserProfile(
          uid: user.uid,
          email: user.email,
          gender: _gender,
          height: _height,
          weight: _weight,
          targetWeight: _primaryGoal == 'maintain_weight' ? _weight : _targetWeight,
          birthYear: _birthYear,
          goal: _primaryGoal,
          activityLevel: _workoutFrequency,
          weeklyGoal: _weeklyGoal,
        );

        // Calculate nutrition targets
        userProfile = await _firestoreService.calculateNutritionTargets(userProfile);

        // Save to Firestore
        await _firestoreService.saveUserProfile(userProfile);

        // Show success dialog after a short delay to simulate processing
        await Future.delayed(Duration(seconds: 2));
        _showSuccessAndNavigate(userProfile);
      }
    } catch (e) {
      print('Error saving user data: $e');
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save your profile. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessAndNavigate(UserProfile userProfile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 16),
              Text(
                "Your program is ready!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    });
  }
}