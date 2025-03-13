import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String gender;
  final double height;
  final double weight;
  final int age;
  final String goal;
  final String activityLevel;
  final int dailyCalorieTarget;
  final int dailyProteinTarget;
  final int dailyCarbsTarget;
  final int dailyFatTarget;
  final int dailyWaterTarget;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.goal,
    required this.activityLevel,
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
      'age': age,
      'goal': goal,
      'activityLevel': activityLevel,
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
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      age: map['age'] ?? 0,
      goal: map['goal'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
      dailyCalorieTarget: map['dailyCalorieTarget'] ?? 0,
      dailyProteinTarget: map['dailyProteinTarget'] ?? 0,
      dailyCarbsTarget: map['dailyCarbsTarget'] ?? 0,
      dailyFatTarget: map['dailyFatTarget'] ?? 0,
      dailyWaterTarget: map['dailyWaterTarget'] ?? 0,
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
    int? age,
    String? goal,
    String? activityLevel,
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
      age: age ?? this.age,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
      dailyCarbsTarget: dailyCarbsTarget ?? this.dailyCarbsTarget,
      dailyFatTarget: dailyFatTarget ?? this.dailyFatTarget,
      dailyWaterTarget: dailyWaterTarget ?? this.dailyWaterTarget,
    );
  }
}