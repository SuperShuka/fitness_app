import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/nutrition_service.dart';
import 'package:fitness_app/services/firestore_service.dart';
import 'main_screen.dart';
import 'package:lottie/lottie.dart';

// App theme colors
class AppColors {
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFF4A90E2);
  static const Color background = Color(0xFFFAFAFA);
  static const Color card = Colors.white;
  static const Color text = Color(0xFF333333);
  static const Color textLight = Color(0xFF777777);
  static const Color success = Color(0xFF4CD964);
}

class ProfileSetupFlow extends StatefulWidget {
  @override
  _ProfileSetupFlowState createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends State<ProfileSetupFlow> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final PageController _pageController = PageController();
  late AnimationController _animationController;
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

  bool get _currentPageHasSelection {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _gender != null;
      case 2:
        return _primaryGoal != null;
      case 3:
        return _workoutFrequency != null;
      case 4:
        return _birthYear != null;
      case 5:
      case 6:
      case 7:
      case 8:
        return true;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_currentPageHasSelection) {
      // Provide haptic feedback and visual indication that a selection is required
      HapticFeedback.mediumImpact();
      _animationController.forward().then((_) =>
          _animationController.reverse());
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _saveUserDataAndNavigate();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.background, Colors.white],
              stops: [0.0, 0.4],
            ),
          ),
          child: Column(
            children: [
              // Custom app bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _currentStep > 0
                        ? IconButton(
                      icon: Icon(
                          Icons.arrow_back_ios_new, color: AppColors.text),
                      onPressed: _previousStep,
                    )
                        : SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: _buildProgressIndicator(),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildGenderStep(),
                    _buildPrimaryGoalStep(),
                    _buildWorkoutFrequencyStep(),
                    _buildBirthYearStep(),
                    _buildHeightStep(),
                    _buildWeightStep(),
                    _buildTargetWeightStep(),
                    _buildWeeklyGoalStep(),
                    _buildLoadingScreen(),
                  ],
                ),
              ),

              // Bottom navigation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        _animationController.value * 10 * ((_animationController
                            .value * 10).floor() % 2 == 0 ? 1 : -1), 0),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'Finish' : 'Continue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_totalSteps, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentStep ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index <= _currentStep ? AppColors.primary : Colors.grey
                .shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "Tell us about yourself",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Select your gender",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          _buildGenderOption('Male', Icons.male, _gender == 'male'),
          SizedBox(height: 20),
          _buildGenderOption('Female', Icons.female, _gender == 'female'),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ]
            : [],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _gender = gender.toLowerCase();
          });
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                gender,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryGoalStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "Your fitness journey",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "What's your primary goal?",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          _buildGoalOption(
              'Lose Weight', Icons.trending_down, '🔥', 'lose_weight'),
          SizedBox(height: 20),
          _buildGoalOption(
              'Maintain Weight', Icons.balance, '⚖️', 'maintain_weight'),
          SizedBox(height: 20),
          _buildGoalOption(
              'Gain Weight', Icons.trending_up, '💪', 'gain_weight'),
        ],
      ),
    );
  }

  Widget _buildGoalOption(String title, IconData icon, String emoji,
      String value) {
    final isSelected = _primaryGoal == value;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ]
            : [],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _primaryGoal = value;
          });
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight
                          .w500,
                      color: isSelected ? AppColors.primary : AppColors.text,
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _getGoalDescription(value),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              emoji,
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'lose_weight':
        return "We'll help you burn calories and track progress";
      case 'maintain_weight':
        return "We'll help you balance nutrition and fitness";
      case 'gain_weight':
        return "We'll help you build muscle and strength";
      default:
        return "";
    }
  }

  Widget _buildWorkoutFrequencyStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "Your activity level",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "How often do you workout?",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          _buildFrequencyOption(
              'Beginner',
              '0-2 workouts a week',
              Icons.directions_walk,
              '😌',
              'beginner'
          ),
          SizedBox(height: 20),
          _buildFrequencyOption(
              'Intermediate',
              '3-5 workouts a week',
              Icons.directions_run,
              '💪',
              'intermediate'
          ),
          SizedBox(height: 20),
          _buildFrequencyOption(
              'Advanced',
              '6+ workouts a week',
              Icons.fitness_center,
              '🔥',
              'advanced'
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String title, String subtitle, IconData icon,
      String emoji, String value) {
    final isSelected = _workoutFrequency == value;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ]
            : [],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _workoutFrequency = value;
          });
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight
                          .w500,
                      color: isSelected ? AppColors.primary : AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              emoji,
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthYearStep() {
    // Current year
    final int currentYear = DateTime
        .now()
        .year;
    // Create a list of years from (currentYear - 80) to (currentYear - 14)
    final List<int> years = List.generate(
      67,
          (index) => currentYear - 14 - index,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "About you",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "What is your birth year?",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center highlight for selected year
                  Positioned(
                    top: (MediaQuery
                        .of(context)
                        .size
                        .height / 2) - 100,
                    child: Container(
                      height: 60,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width - 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ListWheelScrollView.useDelegate(
                    itemExtent: 60,
                    perspective: 0.005,
                    diameterRatio: 1.5,
                    physics: FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _birthYear = years[index].toString();
                      });
                      HapticFeedback.selectionClick();
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final year = years[index];
                        final isSelected = _birthYear == year.toString();
                        return Center(
                          child: Text(
                            year.toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 24 : 20,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors
                                  .textLight,
                            ),
                          ),
                        );
                      },
                      childCount: years.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightStep() {
    // Set height ranges based on unit system
    final double minHeight = _useMetric ? 140.0; // 55 inches = ~4'7"
    final double maxHeight = _useMetric ? 220.0 : 87.0; // 87 inches = 7'3"
    final int divisions = _useMetric ? 80 : 32;

    // Ensure height is within valid range for current unit system
    if (_height < minHeight) _height = minHeight;
    if (_height > maxHeight) _height = maxHeight;

    // Height display format and unit text
    String displayHeight;
    String unitText;

    if (_useMetric) {
      displayHeight = '${_height.toInt()}';
      unitText = 'cm';
    } else {
      // Convert height to feet and inches display
      int feet = (_height / 12).floor();
      int inches = (_height % 12).round();
      displayHeight = '$feet\'$inches\"';
      unitText = '';
    }

    // Calculate position for person icon on height visualization
    double personPosition = 180 - (((_height - minHeight) / (maxHeight - minHeight)) * 180);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            "Body measurements",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "What is your height?",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),

          // Height display - Modern design
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayHeight,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (unitText.isNotEmpty) const SizedBox(width: 8),
                  if (unitText.isNotEmpty)
                    Text(
                      unitText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Custom height visualization with slider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left side - visualization
              SizedBox(
                width: 100,
                height: 220,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Height visualization bar
                    Container(
                      width: 24,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),

                    // Height markers
                    ...List.generate(6, (index) {
                      return Positioned(
                        left: 30,
                        bottom: (180 / 5) * index,
                        child: Text(
                          _useMetric
                              ? '${(minHeight + ((maxHeight - minHeight) / 5) * (5 - index)).toInt()}'
                              : '${((minHeight + ((maxHeight - minHeight) / 5) * (5 - index)) / 12).floor()}\'',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                      );
                    }),

                    // Person icon with indicator line
                    Positioned(
                      bottom: personPosition.clamp(0.0, 180.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 2,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // Right side - vertical slider
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.grey.shade200,
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14,
                    elevation: 6,
                  ),
                  overlayColor: AppColors.primary.withOpacity(0.2),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                ),
                child: SizedBox(
                  height: 220,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SizedBox(
                      width: 180,
                      child: Slider(
                        value: _height.clamp(minHeight, maxHeight),
                        min: minHeight,
                        max: maxHeight,
                        divisions: divisions,
                        onChanged: (value) {
                          setState(() {
                            _height = value;
                          });
                          if ((value * 10) % 10 == 0) {
                            HapticFeedback.selectionClick();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Fine tune controls for height
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAdjustButton(Icons.remove, () {
                if (_height > minHeight) {
                  setState(() {
                    _height = _useMetric
                        ? _height - 1.0  // Decrement by 1 cm
                        : _height - 0.5; // Decrement by 0.5 inch
                  });
                  HapticFeedback.lightImpact();
                }
              }),
              const SizedBox(width: 16),
              Container(
                width: 200,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade300,
                      AppColors.primary,
                      Colors.orange.shade300,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              _buildAdjustButton(Icons.add, () {
                if (_height < maxHeight) {
                  setState(() {
                    _height = _useMetric
                        ? _height + 1.0  // Increment by 1 cm
                        : _height + 0.5; // Increment by 0.5 inch
                  });
                  HapticFeedback.lightImpact();
                }
              }),
            ],
          ),

          const SizedBox(height: 30),

          // Height range indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _useMetric
                      ? '${minHeight.toInt()} cm'
                      : '${(minHeight / 12).floor()}\'${(minHeight % 12).round()}\"',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _useMetric
                      ? '${maxHeight.toInt()} cm'
                      : '${(maxHeight / 12).floor()}\'${(maxHeight % 12).round()}\"',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper widget for height/weight adjustment buttons - same as in weight step
  Widget _buildAdjustButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildWeightStep() {
    // Set weight ranges based on unit system
    final double minWeight = _useMetric ? 30.0 : 66.0;
    final double maxWeight = _useMetric ? 150.0 : 330.0;
    final int divisions = _useMetric ? 120 : 264;

    // Ensure weight is within valid range for current unit system
    if (_weight < minWeight) _weight = minWeight;
    if (_weight > maxWeight) _weight = maxWeight;

    // Weight display format
    String displayWeight = '${_weight.toInt()}';

    // Unit text
    String unitText = _useMetric ? 'kg' : 'lb';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            "Body measurements",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "What is your current weight?",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),

          // Weight display - Modern design
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayWeight,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    unitText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Fine tune controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAdjustButton(Icons.remove, () {
                if (_weight > minWeight) {
                  setState(() {
                    _weight = _weight - 1.0;
                  });
                  HapticFeedback.lightImpact();
                }
              }),
              const SizedBox(width: 16),
              Container(
                width: 200,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade300,
                      AppColors.primary,
                      Colors.orange.shade300,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              _buildAdjustButton(Icons.add, () {
                if (_weight < maxWeight) {
                  setState(() {
                    _weight = _weight + 1.0;
                  });
                  HapticFeedback.lightImpact();
                }
              }),
            ],
          ),

          const SizedBox(height: 40),

          // Weight slider - Enhanced design
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 6,
              ),
              overlayColor: AppColors.primary.withOpacity(0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
            ),
            child: Slider(
              value: _weight.clamp(minWeight, maxWeight), // Ensure the value is in valid range
              min: minWeight,
              max: maxWeight,
              divisions: divisions,
              onChanged: (value) {
                setState(() {
                  _weight = value;
                });
                if ((value * 10) % 10 == 0) {
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),

          const SizedBox(height: 30),

          // Weight range indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${minWeight.toInt()} $unitText',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${maxWeight.toInt()} $unitText',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Helpful weight context
          _buildWeightContext(),
        ],
      ),
    );
  }

// Helper widget for weight context information
  Widget _buildWeightContext() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Weight data helps us personalize your calorie goals. "
                  "You'll be able to track your progress over time.",
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetWeightStep() {
    // Skip this step if maintaining weight
    if (_primaryGoal == 'maintain_weight') {
      _targetWeight = _weight;
      return _buildWeeklyGoalStep();
    }

    IconData trendIcon = Icons.trending_flat;
    Color trendColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "Your goal weight",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "What weight would you like to reach?",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_targetWeight.toInt()}',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),

          // Weight comparison
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Current',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_weight.toInt()} kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    trendIcon,
                    size: 32,
                    color: trendColor,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Target',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: trendColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_targetWeight.toInt()} kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: trendColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 40),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: trendColor,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 4,
              ),
              overlayColor: trendColor.withOpacity(0.2),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _targetWeight,
              min: 40,
              max: 120,
              divisions: 80,
              onChanged: (value) {
                setState(() {
                  _targetWeight = value;
                });
                if ((value * 10) % 10 == 0) {
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),

          // Unit toggle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'KG',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Text(
                      'LB',
                      style: TextStyle(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalStep() {
    // Determine the goal type text and color
    String goalTypeText = "";
    Color goalColor = AppColors.primary;

    if (_primaryGoal == 'lose_weight') {
      goalTypeText = "Weekly weight loss";
      goalColor = Colors.red;
    } else if (_primaryGoal == 'gain_weight') {
      goalTypeText = "Weekly weight gain";
      goalColor = Colors.green;
    } else {
      goalTypeText = "Weekly activity goal";
      goalColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "Set your pace",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Text(
            goalTypeText,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: goalColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _weeklyGoal.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: goalColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'kg/week',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40),

          // Weekly goal visualization
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: goalColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'What this means',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  _getWeeklyGoalDescription(),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Custom segmented selector for weekly goal
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeeklyGoalOption(0.5, goalColor),
                _buildWeeklyGoalOption(1.0, goalColor),
                _buildWeeklyGoalOption(1.5, goalColor),
                _buildWeeklyGoalOption(2.0, goalColor),
              ],
            ),
          ),

          // Slider for fine-tuning
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: goalColor,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 4,
              ),
              overlayColor: goalColor.withOpacity(0.2),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _weeklyGoal,
              min: 0.1,
              max: 2.0,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _weeklyGoal = value;
                });
                if ((value * 10) % 5 == 0) {
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalOption(double value, Color goalColor) {
    final isSelected = (_weeklyGoal * 10).round() == (value * 10).round();

    return GestureDetector(
      onTap: () {
        setState(() {
          _weeklyGoal = value;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? goalColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${value.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }

  String _getWeeklyGoalDescription() {
    if (_primaryGoal == 'lose_weight') {
      if (_weeklyGoal <= 0.5) {
        return "A gentle approach. This may take longer but is easier to maintain.";
      } else if (_weeklyGoal <= 1.0) {
        return "A balanced approach. This is recommended for sustainable weight loss.";
      } else {
        return "An ambitious goal. This requires strict adherence to diet and exercise.";
      }
    } else if (_primaryGoal == 'gain_weight') {
      if (_weeklyGoal <= 0.5) {
        return "A gradual approach focused on quality muscle gain with minimal fat.";
      } else if (_weeklyGoal <= 1.0) {
        return "A balanced approach for both muscle gain and strength increases.";
      } else {
        return "A bulking phase. This may include some fat gain along with muscle.";
      }
    } else {
      return "This helps us set appropriate activity and nutrition goals to maintain your current weight.";
    }
  }

  Widget _buildLoadingScreen() {
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add Lottie animation
          Lottie.asset(
            'assets/animations/loading.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 40),
          Text(
            "Setting up your personalized plan",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "We're calculating your nutrition needs and preparing your fitness journey",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 6,
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserDataAndNavigate() async {
    setState(() {
      _isLoading = true;
      _pageController.animateToPage(
        _totalSteps,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });

    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("No authenticated user found");
      }

      // Calculate age from birth year
      final currentYear = DateTime
          .now()
          .year;
      final age = currentYear - int.parse(_birthYear!);

      // Calculate BMR and daily calorie needs using the NutritionService
      final nutritionService = NutritionService();
      final dailyCalories = nutritionService.calculateDailyCalories(
        gender: _gender!,
        age: age,
        height: _height,
        weight: _weight,
        activityLevel: _workoutFrequency!,
        goal: _primaryGoal!,
      );

      // Calculate macro distribution
      final macros = nutritionService.calculateMacroDistribution(
        calories: dailyCalories,
        goal: _primaryGoal!,
      );

      // Create user profile object
      final userProfile = UserProfile(
        userId: currentUser.uid,
        email: currentUser.email ?? '',
        displayName: currentUser.displayName ?? '',
        gender: _gender!,
        birthYear: _birthYear!,
        height: _height,
        weight: _weight,
        targetWeight: _targetWeight,
        primaryGoal: _primaryGoal!,
        workoutFrequency: _workoutFrequency!,
        weeklyGoal: _weeklyGoal,
        dailyCalories: dailyCalories,
        proteinGoal: macros['protein']!,
        carbsGoal: macros['carbs']!,
        fatGoal: macros['fat']!,
        waterGoal: 2000,
        // Default water goal in ml
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // Save user profile to Firestore
      await _firestoreService.saveUserProfile(userProfile);

      // Add a slight delay for better UX
      await Future.delayed(Duration(seconds: 2));

      // Navigate to main screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
    } catch (e) {
      // Handle errors
      setState(() {
        _isLoading = false;
        _currentStep = _totalSteps - 1; // Go back to the last input screen
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}