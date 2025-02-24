import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  String _selectedGoal = 'Lose Weight';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String uid = _auth.currentUser!.uid;
    UserProfile? user = await _firestoreService.getUserData(uid);

    if (user != null) {
      setState(() {
        _heightController.text = user.height.toString();
        _weightController.text = user.weight.toString();
        _ageController.text = user.age.toString();
        _selectedGoal = user.goal;
        _isLoading = false;
      });
    }
    else{
      UserProfile user = UserProfile(
        uid: uid,
        height: 160,
        weight: 60,
        age: 18,
        goal: _selectedGoal,
      );
      print("saving");
      await _firestoreService.saveUserData(user);
      print("saved");
      setState(() {
        _heightController.text = user.height.toString();
        _weightController.text = user.weight.toString();
        _ageController.text = user.age.toString();
        _selectedGoal = user.goal;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      String uid = _auth.currentUser!.uid;
      UserProfile updatedUser = UserProfile(
        uid: uid,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        age: int.parse(_ageController.text),
        goal: _selectedGoal,
      );

      await _firestoreService.saveUserData(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Saved!")));
      Navigator.pop(context);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Height (cm)"),
                validator: (value) => value!.isEmpty ? "Enter your height" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Weight (kg)"),
                validator: (value) => value!.isEmpty ? "Enter your weight" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Age"),
                validator: (value) => value!.isEmpty ? "Enter your age" : null,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGoal,
                items: ["Lose Weight", "Maintain Weight", "Gain Muscle", "Gain Weight"]
                    .map((goal) => DropdownMenuItem(value: goal, child: Text(goal)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGoal = value!),
                decoration: InputDecoration(labelText: "Goal"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserData,
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
