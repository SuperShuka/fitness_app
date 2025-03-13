import 'package:fitness_app/screens/profile_setup_flow.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    setState(() { _isLoading = true; });
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileSetupFlow()),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Google Sign-In failed');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _handleEmailSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        User? user = await _authService.signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text
        );
        if (user != null) {
          // Navigate to main screen or onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileSetupFlow()),
          );
        }
      } catch (e) {
        _showErrorSnackBar('Sign-in failed. Please check your credentials.');
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _handleEmailSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        User? user = await _authService.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text
        );
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileSetupFlow()),
          );
        }
      } catch (e) {
        _showErrorSnackBar('Sign-up failed. Please try again.');
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo or Title
                Center(
                  child: Text(
                    'NutriTrack',
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email validation
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                      'Sign In',
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      )
                  ),
                ),
                SizedBox(height: 16),

                // Sign Up Button
                OutlinedButton(
                  onPressed: _isLoading ? null : _handleEmailSignUp,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green[700]!),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                      'Sign Up',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      )
                  ),
                ),
                SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'or continue with',
                        style: GoogleFonts.montserrat(color: Colors.grey),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 24),

                // Google Sign In Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: SvgPicture.asset(
                      'assets/icons/google_logo.svg',
                      height: 24
                  ),
                  label: Text(
                    'Sign in with Google',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}