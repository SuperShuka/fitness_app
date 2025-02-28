import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  Future<void> signIn() async {
    _authService.signIn(email: _emailController.text, password: _passwordController.text);
  }

  Future<void> signUp() async {
    _authService.signUp(email: _emailController.text, password: _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Mail"),
                validator: (value) => value!.isEmpty ? "Enter your mail" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) =>
                    value!.isEmpty ? "Enter your password" : null,
              ),
              ElevatedButton(
                onPressed: () async {
                  _authService.signUp(email: _emailController.text, password: _passwordController.text);
                },
                child: Text("Sign up"),
              ),
              ElevatedButton(
                onPressed: () async {
                  _authService.signIn(email: _emailController.text, password: _passwordController.text);
                },
                child: Text("Sign in"),
              ),
              ElevatedButton(
                onPressed: () async {
                  User? user = await _authService.signInWithGoogle();
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  } else {
                    print("Error");
                  }
                },
                child: Text("Sign in with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
