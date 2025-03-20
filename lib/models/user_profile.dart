// lib/models/user_profile.dart

class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final String gender;
  final String birthYear;
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
    required this.birthYear,
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

  // Create from Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      gender: data['gender'] ?? '',
      birthYear: data['birthYear'] ?? '',
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
      'birthYear': birthYear,
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
    String? birthYear,
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
      birthYear: birthYear ?? this.birthYear,
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