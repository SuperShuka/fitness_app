class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String goal; // 'Lose Weight', 'Maintain Weight', 'Gain Weight'
  final String activityLevel; // 'Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Extra Active'
  final String gender; // 'male' or 'female'

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    required this.activityLevel,
    this.gender = 'male'
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 30,
      height: (map['height'] ?? 170).toDouble(),
      weight: (map['weight'] ?? 70).toDouble(),
      goal: map['goal'] ?? 'Maintain Weight',
      activityLevel: map['activityLevel'] ?? 'Moderately Active',
      gender: map['gender'] ?? 'male'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
      'activityLevel': activityLevel,
      'gender': gender,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    double? height,
    double? weight,
    String? goal,
    String? activityLevel,
    String? gender,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: id ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      gender: gender ?? this.gender,
    );
  }

  // Helper methods for daily calorie targets based on profile data
  double get bmr {
    if (gender == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  double get activityMultiplier {
    switch (activityLevel) {
      case 'Sedentary':
        return 1.2;
      case 'Lightly Active':
        return 1.375;
      case 'Moderately Active':
        return 1.55;
      case 'Very Active':
        return 1.725;
      case 'Extra Active':
        return 1.9;
      default:
        return 1.375;
    }
  }

  double get dailyCalories {
    final tdee = bmr * activityMultiplier;

    switch (goal) {
      case 'Lose Weight':
        return tdee - 500;
      case 'Gain Weight':
        return tdee + 500;
      default:
        return tdee;
    }
  }

  double get proteinTarget => (dailyCalories * 0.3) / 4;
  double get carbsTarget => (dailyCalories * 0.4) / 4;
  double get fatTarget => (dailyCalories * 0.3) / 9;
}