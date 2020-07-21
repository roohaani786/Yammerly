import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techstagram/Widget/bezierContainer.dart';

import 'HomePage.dart';


class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;

  @override
  initState() {
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
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
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.grey.shade900,

        body: Container(
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/sd.png"),
                fit: BoxFit.cover,
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 150.0),
                        child: Container(
                          height: 200.0,
                          child: Image.asset("assets/flash.png",
                          height: 300.0,
                          width: 300.0,),
                        ),
                      ),
                      Container(
                        height: 50.0,
                        child: new Theme(
                          data: new ThemeData(
                            primaryColor: Colors.blueAccent,
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                                border: new OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(60.0),

                                  ),
                                ),

                                fillColor: Color(0xfff3f3f4),

                                filled: true,
                                hintText: "first name",),
                            controller: firstNameInputController,
                            validator: (value) {
                              if (value.length < 3) {
                                return "Please enter a valid first name";
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          height: 50.0,
                          child: new Theme(
                            data: new ThemeData(
                              primaryColor: Colors.blueAccent,
                            ),
                            child: TextFormField(
                                decoration: InputDecoration(
                                    border: new OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(60.0),

                                      ),
                                    ),
                                    fillColor: Color(0xfff3f3f4),
                                    filled: true,
                                     hintText: "last name"),
                                controller: lastNameInputController,
                                validator: (value) {
                                  if (value.length < 3) {
                                    return "Please enter a valid last name.";
                                  }
                                }),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          height: 50.0,
                          child: new Theme(
                            data: new ThemeData(
                              primaryColor: Colors.blueAccent,
                            ),
                            child: TextFormField(

                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(60.0),

                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
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
                              primaryColor: Colors.blueAccent,
                            ),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(60.0),

                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                   hintText: "create password"),
                              controller: pwdInputController,
                              obscureText: true,
                              validator: pwdValidator,
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
                              primaryColor: Colors.blueAccent,
                            ),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(80.0),

                                    ),
                                  ),
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true,
                                   hintText: "confirm password",
                              labelStyle: TextStyle(color: Colors.grey.shade200,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold)),
                              controller: confirmPwdInputController,
                              obscureText: true,
                              validator: pwdValidator,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          width: 250.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),

                          ),
                          child: RaisedButton(


                            child: Text("Register"),
//                            color: Theme.of(context).primaryColor,
                          color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () {
                              if (_registerFormKey.currentState.validate()) {
                                if (pwdInputController.text ==
                                    confirmPwdInputController.text) {
                                  FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                      email: emailInputController.text,
                                      password: pwdInputController.text)
                                      .then((authResult) => Firestore.instance
                                      .collection("users")
                                      .document(authResult.user.uid)
                                      .setData({
                                    "uid": authResult.user.uid,
                                    "fname": firstNameInputController.text,
                                    "surname": lastNameInputController.text,
                                    "email": emailInputController.text,
                                  })
                                      .then((result) => {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage(
                                              title:
                                              firstNameInputController
                                                  .text +
                                                  "'s Tasks",
                                              uid: authResult.user.uid,
                                            )),
                                            (_) => false),
                                    firstNameInputController.clear(),
                                    lastNameInputController.clear(),
                                    emailInputController.clear(),
                                    pwdInputController.clear(),
                                    confirmPwdInputController.clear()
                                  })
                                      .catchError((err) => print(err)))
                                      .catchError((err) => print(err));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Error"),
                                          content: Text("The passwords do not match"),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("Close"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Already have an account?",
                        style: TextStyle(
                          color: Colors.white,
                        ),),
                      ),
                      FlatButton(
                        child: Text("Login here!",
                        style: TextStyle(
                          color: Colors.white,
                        ),),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/Login");
                        },
                      )
                    ],
                  ),
                ))));
  }
}

