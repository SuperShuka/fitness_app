import 'package:fitness_app/screens/profile_setup_flow.dart';
import 'package:fitness_app/utils/debug_print.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          dPrint(user?.uid);
          if (user == null) {
            dPrint("Moved to login screen");
            return LoginScreen();
          } else {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data!.exists) {
                    return MainScreen();
                  } else {
                    dPrint("Moved to profile screen");
                    return ProfileSetupFlow();
                  }
                }
                return CircularProgressIndicator();
              },
            );
          }
        }
        return CircularProgressIndicator();
      },
    );
  }
}
