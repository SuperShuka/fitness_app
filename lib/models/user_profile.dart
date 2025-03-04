class UserProfile {
  final String uid;
  final double height;
  final double weight;
  final int age;
  final String goal;

  UserProfile({
    required this.uid,
    required this.height,
    required this.weight,
    required this.age,
    required this.goal,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'height': height,
      'weight': weight,
      'age': age,
      'goal': goal,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: map['uid'],
      height: map['height'],
      weight: map['weight'],
      age: map['age'],
      goal: map['goal'],
    );
  }
}
