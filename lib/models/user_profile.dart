class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final String gender;
  final int age;
  final double height;
  final double weight;
  final double targetWeight;
  final String primaryGoal;
  final String workoutFrequency;
  final double weeklyGoal;
  final int dailyCalories;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;
  final int waterGoal;
  final DateTime createdAt;
  final DateTime lastUpdated;

  UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.targetWeight,
    required this.primaryGoal,
    required this.workoutFrequency,
    required this.weeklyGoal,
    required this.dailyCalories,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.waterGoal,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? '',
      height: (data['height'] ?? 0).toDouble(),
      weight: (data['weight'] ?? 0).toDouble(),
      targetWeight: (data['targetWeight'] ?? 0).toDouble(),
      primaryGoal: data['primaryGoal'] ?? '',
      workoutFrequency: data['workoutFrequency'] ?? '',
      weeklyGoal: (data['weeklyGoal'] ?? 0).toDouble(),
      dailyCalories: data['dailyCalories'] ?? 0,
      proteinGoal: data['proteinGoal'] ?? 0,
      carbsGoal: data['carbsGoal'] ?? 0,
      fatGoal: data['fatGoal'] ?? 0,
      waterGoal: data['waterGoal'] ?? 0,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'primaryGoal': primaryGoal,
      'workoutFrequency': workoutFrequency,
      'weeklyGoal': weeklyGoal,
      'dailyCalories': dailyCalories,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'waterGoal': waterGoal,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
    };
  }

  // Create a copy with updated values
  UserProfile copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? gender,
    int? age,
    double? height,
    double? weight,
    double? targetWeight,
    String? primaryGoal,
    String? workoutFrequency,
    double? weeklyGoal,
    int? dailyCalories,
    int? proteinGoal,
    int? carbsGoal,
    int? fatGoal,
    int? waterGoal,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      workoutFrequency: workoutFrequency ?? this.workoutFrequency,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      waterGoal: waterGoal ?? this.waterGoal,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

extension UserProfileCalculations on UserProfile {
  double calculateBMR() {
    if (gender.toLowerCase() == 'male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else if (gender.toLowerCase() == 'female') {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
    return 10 * weight + 6.25 * height - 5 * age;
  }

  double _getActivityMultiplier() {
    switch (workoutFrequency.toLowerCase()) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'very active':
        return 1.725;
      case 'extra active':
        return 1.9;
      default:
        return 1.375; // Default to light activity
    }
  }

  // Calculate Total Daily Energy Expenditure (TDEE)
  double calculateTDEE() {
    return calculateBMR() * _getActivityMultiplier();
  }

  // Calculate calorie adjustment based on weekly weight goal
  int calculateDailyCalories() {
    // Calories per kg of weight change
    const caloriesPerKg = 7700; // Approximately 7700 calories per kg

    // Calculate calorie adjustment based on weekly goal
    double calorieAdjustment = (weeklyGoal * caloriesPerKg) / 7;

    // Determine if user wants to lose or gain weight
    bool isLosingWeight = weeklyGoal < 0;

    // Calculate base calories
    double baseCal = calculateTDEE();

    // Adjust calories based on weight goal
    if (isLosingWeight) {
      // Calorie deficit for weight loss
      return (baseCal - calorieAdjustment).round();
    } else {
      // Calorie surplus for weight gain
      return (baseCal + calorieAdjustment).round();
    }
  }

  // Macronutrient Recommendations
  int calculateProteinGoal() {
    double proteinMultiplier = 1.6;
    return (weight * proteinMultiplier).round();
  }

  int calculateCarbGoal() {
    // Carb recommendation: 45-65% of total calories
    // Adjust based on activity level and goal
    int totalCalories = calculateDailyCalories();
    double carbPercentage = workoutFrequency.toLowerCase() == 'very active' ? 0.65 : 0.50;
    return ((totalCalories * carbPercentage) / 4).round(); // 4 calories per gram of carbs
  }

  int calculateFatGoal() {
    // Fat recommendation: 20-35% of total calories
    int totalCalories = calculateDailyCalories();
    double fatPercentage = 0.25; // Moderate fat intake
    return ((totalCalories * fatPercentage) / 9).round(); // 9 calories per gram of fat
  }

  int calculateWaterGoal() {
    // Water intake recommendation: 30-35 ml per kg of body weight
    // Adjust based on activity level
    double baseWaterIntake = weight * 35; // ml

    switch (workoutFrequency.toLowerCase()) {
      case 'very active':
        return (baseWaterIntake * 1.2).round();
      case 'extra active':
        return (baseWaterIntake * 1.5).round();
      default:
        return baseWaterIntake.round();
    }
  }

  // Method to update profile with calculated goals
  UserProfile updateNutritionGoals() {
    return copyWith(
      dailyCalories: calculateDailyCalories(),
      proteinGoal: calculateProteinGoal(),
      carbsGoal: calculateCarbGoal(),
      fatGoal: calculateFatGoal(),
      waterGoal: calculateWaterGoal(),
      lastUpdated: DateTime.now(),
    );
  }
}