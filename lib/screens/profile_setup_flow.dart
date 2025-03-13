import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/nutrition_service.dart';
import 'main_screen.dart';

class ProfileSetupFlow extends StatefulWidget {
  @override
  _ProfileSetupFlowState createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends State<ProfileSetupFlow> {
  final NutritionService _nutritionService = NutritionService();
  int _currentStep = 0;

  String? _gender;
  double _height = 170;
  double _weight = 70;
  int _age = 30;
  String? _goal;
  String? _activityLevel;

  Widget _buildCustomSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Text(
          '$label: ${value.round()} $unit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.blue.shade100,
            thumbColor: Colors.blue,
            overlayColor: Colors.blue.withAlpha(32),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // Gender selection step
  Widget _buildGenderStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Select Your Gender',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGenderButton('Male', Icons.male, _gender == 'male'),
            SizedBox(width: 20),
            _buildGenderButton('Female', Icons.female, _gender == 'female'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String gender, IconData icon, bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _gender = gender.toLowerCase();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 60),
          SizedBox(height: 10),
          Text(gender, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Physical details step
  Widget _buildPhysicalDetailsStep() {
    return Column(
      children: [
        _buildCustomSlider(
          label: 'Height',
          value: _height,
          min: 50,
          max: 250,
          unit: 'cm',
          onChanged: (value) {
            setState(() {
              _height = value;
            });
          },
        ),
        SizedBox(height: 20),
        _buildCustomSlider(
          label: 'Weight',
          value: _weight,
          min: 20,
          max: 300,
          unit: 'kg',
          onChanged: (value) {
            setState(() {
              _weight = value;
            });
          },
        ),
        SizedBox(height: 20),
        _buildCustomSlider(
          label: 'Age',
          value: _age.toDouble(),
          min: 0,
          max: 120,
          unit: 'years',
          onChanged: (value) {
            setState(() {
              _age = value.round();
            });
          },
        ),
      ],
    );
  }

  // Goal selection step
  Widget _buildGoalStep() {
    final goals = [
      'Lose Weight',
      'Maintain Weight',
      'Gain Muscle',
      'Gain Weight'
    ];

    return Column(
      children: [
        Text(
          'Choose Your Goal',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: goals.map((goal) =>
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _goal = goal;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _goal == goal ? Colors.blue : Colors.grey.shade200,
                  foregroundColor: _goal == goal ? Colors.white : Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(goal),
              )
          ).toList(),
        ),
      ],
    );
  }

  // Activity level step
  Widget _buildActivityLevelStep() {
    final activityLevels = [
      'Sedentary',
      'Lightly Active',
      'Moderately Active',
      'Very Active',
      'Extra Active'
    ];

    return Column(
      children: [
        Text(
          'Select Activity Level',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: activityLevels.map((level) =>
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _activityLevel = level;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activityLevel == level ? Colors.blue : Colors.grey.shade200,
                  foregroundColor: _activityLevel == level ? Colors.white : Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(level),
              )
          ).toList(),
        ),
      ],
    );
  }

  // Save profile and complete setup
  Future<void> _saveProfile() async {
    if (_gender == null || _goal == null || _activityLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please complete all steps'))
      );
      return;
    }

    final profile = UserProfile(
      uid: FirebaseAuth.instance.currentUser!.uid,
      email: FirebaseAuth.instance.currentUser!.email ?? '',
      name: FirebaseAuth.instance.currentUser!.displayName ?? '',
      gender: _gender!,
      height: _height,
      weight: _weight,
      age: _age,
      goal: _goal!,
      activityLevel: _activityLevel!,
    );

    try {
      await _nutritionService.updateUserProfile(profile);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen())
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildGenderStep(),
      _buildPhysicalDetailsStep(),
      _buildGoalStep(),
      _buildActivityLevelStep(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your Profile'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / steps.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: steps[_currentStep],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    child: Text('Previous'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < steps.length - 1) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      _saveProfile();
                    }
                  },
                  child: Text(_currentStep < steps.length - 1 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}