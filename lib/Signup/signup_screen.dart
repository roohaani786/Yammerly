import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/Signup/components/body.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // ignore: missing_return
              print('something went wrong');
            }

            // Once complete, show your application
            if (snapshot.connectionState == ConnectionState.done) {
              return Body();
            }


            return null;

          }),
    );
  }
}
