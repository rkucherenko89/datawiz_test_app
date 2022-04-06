import 'package:datawiz_test_app/widgets/logged_in_widget.dart';
import 'package:datawiz_test_app/widgets/sign_up_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('something went wrong'));
          } else if (snapshot.hasData) {
            return const LoggedInWidget();
          } else {
            return const SignUpWidget();
          }
        },
      ),
    );
  }
}
