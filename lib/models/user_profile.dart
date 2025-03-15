import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? email;
  final String? name;
  final String? gender;
  final double height;
  final double weight;
  final double? targetWeight;
  final String? birthYear;
  final int? age;
  final String? goal;
  final String? activityLevel;
  final double? weeklyGoal;
  final int? dailyCalorieTarget;
  final int? dailyProteinTarget;
  final int? dailyCarbsTarget;
  final int? dailyFatTarget;
  final int? dailyWaterTarget;

  UserProfile({
    required this.uid,
    this.email,
    this.name,
    this.gender,
    required this.height,
    required this.weight,
    this.targetWeight,
    this.birthYear,
    this.age,
    this.goal,
    this.activityLevel,
    this.weeklyGoal,
    this.dailyCalorieTarget = 0,
    this.dailyProteinTarget = 0,
    this.dailyCarbsTarget = 0,
    this.dailyFatTarget = 0,
    this.dailyWaterTarget = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'gender': gender,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'birthYear': birthYear,
      'age': age,
      'goal': goal,
      'activityLevel': activityLevel,
      'weeklyGoal': weeklyGoal,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyProteinTarget': dailyProteinTarget,
      'dailyCarbsTarget': dailyCarbsTarget,
      'dailyFatTarget': dailyFatTarget,
      'dailyWaterTarget': dailyWaterTarget,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'],
      name: map['name'],
      gender: map['gender'],
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      targetWeight: map['targetWeight']?.toDouble(),
      birthYear: map['birthYear'],
      age: map['age'],
      goal: map['goal'],
      activityLevel: map['activityLevel'],
      weeklyGoal: map['weeklyGoal']?.toDouble(),
      dailyCalorieTarget: map['dailyCalorieTarget'],
      dailyProteinTarget: map['dailyProteinTarget'],
      dailyCarbsTarget: map['dailyCarbsTarget'],
      dailyFatTarget: map['dailyFatTarget'],
      dailyWaterTarget: map['dailyWaterTarget'],
    );
  }

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? gender,
    double? height,
    double? weight,
    double? targetWeight,
    String? birthYear,
    int? age,
    String? goal,
    String? activityLevel,
    double? weeklyGoal,
    int? dailyCalorieTarget,
    int? dailyProteinTarget,
    int? dailyCarbsTarget,
    int? dailyFatTarget,
    int? dailyWaterTarget,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      birthYear: birthYear ?? this.birthYear,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
      dailyCarbsTarget: dailyCarbsTarget ?? this.dailyCarbsTarget,
      dailyFatTarget: dailyFatTarget ?? this.dailyFatTarget,
      dailyWaterTarget: dailyWaterTarget ?? this.dailyWaterTarget,
    );
  }
}