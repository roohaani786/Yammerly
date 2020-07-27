import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/resources/fbsignin.dart';


class Fblogin extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FbLoginPage(),
    );
  }
}