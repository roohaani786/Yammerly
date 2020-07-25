import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool loginfail = false;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,

        body: Container(
            height: height,

            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(

                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                    height: 50.0,
                                    width: 50.0,
                                    child: Image.asset("assets/google-logo.png",
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(60.0),
                                      ),
                                      height: 44.0,
                                      width: 50.0,
                                      child: Image.asset("assets/fb-logo.png",)),
                                ),
                                Container(
                                    height: 50.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(60.0),
                                    ),
                                    child: Image.asset("assets/phone-icon.png")),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 60.0,top: 140.0),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Container(
                                  height: 120.0,

                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text("LOGIN",
                                        style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.bold,

                                        ),)),
//                                Image.asset("assets/flashu.png",
//                                ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),





                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          height: 50.0,
                          child: new Theme(
                            data: new ThemeData(
                              primaryColor: Colors.deepPurple,
                            ),
                            child: TextFormField(

                              decoration: InputDecoration(
//                                  border: new OutlineInputBorder(
//                                    borderRadius: const BorderRadius.all(
//                                      const Radius.circular(60.0),
//
//                                    ),
//                                  ),
                                  fillColor: Colors.white70,
                                  filled: true,
                                  hintText: "email"),
                              controller: emailInputController,
                              keyboardType: TextInputType.emailAddress,
                              validator: emailValidator,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          height: 50.0,
                          child: new Theme(
                            data: new ThemeData(
                              primaryColor: Colors.deepPurple,
                            ),
                            child: TextFormField(
                              decoration: InputDecoration(
//                                  border: new OutlineInputBorder(
//                                    borderRadius: const BorderRadius.all(
//                                      const Radius.circular(60.0),
//
//                                    ),
//                                  ),
                                  fillColor: Colors.white70,
                                  errorText: loginfail ? 'password not match' : null,
                                  filled: true,
                                  hintText: "password"),
                              controller: pwdInputController,
                              obscureText: true,
                              validator: pwdValidator,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Container(
                          width: 250.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),

                          ),
                          child: RaisedButton(
                            shape:  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            child: Text("LOGIN"),
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () {
                              if (_loginFormKey.currentState.validate()) {

                                FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                    email: emailInputController.text,
                                    password: pwdInputController.text)
                                    .then((authResult) => Firestore.instance
                                    .collection("users")
                                    .document(authResult.user.uid)
                                    .get()
                                    .then((DocumentSnapshot result) =>
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage(
                                              title: result["fname"] +
                                                  "'s Tasks",
                                              uid: authResult.user.uid,
                                            ))))
                                    .catchError((err) => print(err)))
                                    .catchError((err) => print(err));

                                  }
                                }




                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text("Don't have an account yet?",style:
                          TextStyle(
                            color: Colors.black,
                          ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          height: 40.0,
                          width: 160.0,
                          child: FlatButton(
                            shape:  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: Colors.purple,
                            child: Text("SIGNUP",style:
                              TextStyle(
                                color: Colors.white
                              ),),
                            onPressed: () {
                              Navigator.pushNamed(context, "/Signup");
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text("Forgot Password?",
                          style: TextStyle(
                              color: Colors.black,
                              fontStyle: FontStyle.italic
                          ),),
                      ),
                    ],
                  ),
                ))));
  }
}

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }