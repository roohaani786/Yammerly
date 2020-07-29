import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/Signup/components/background.dart';
import 'package:techstagram/Signup/components/or_divider.dart';
import 'package:techstagram/Signup/components/social_icon.dart';
import 'package:techstagram/components/already_have_an_account_acheck.dart';
import 'package:techstagram/components/rounded_button.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/resources/googlesignin.dart';
import 'package:techstagram/ui/HomePage.dart';

import '../../constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController phoneNumberController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;
  bool success = false;

  @override
  initState() {
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    phoneNumberController = new TextEditingController();
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

  String validateMobile(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "SIGNUP",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/signup.svg",
                height: size.height * 0.15,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Container(
                  height: 70.0,
                  child: TextFieldContainer(
                    child: TextFormField(
                      cursorColor: kPrimaryColor,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.person,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "first name"),
                      controller: firstNameInputController,
                      keyboardType: TextInputType.name,
//                      validator: emailValidator,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  height: 70.0,
                  child: TextFieldContainer(
                    child: TextFormField(
                      cursorColor: kPrimaryColor,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.input,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "last name"),
                      controller: lastNameInputController,
                      keyboardType: TextInputType.name,
//                      validator: emailValidator,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  height: 70.0,
                  child: TextFieldContainer(
                    child: TextFormField(
                      cursorColor: kPrimaryColor,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.phone_android,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "phone number"),
                      controller: phoneNumberController,
                      validator: validateMobile,
                      keyboardType: TextInputType.number,
//                      validator: emailValidator,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  height: 70.0,
                  child: TextFieldContainer(
                    child: TextFormField(
                      cursorColor: kPrimaryColor,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.email,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "email"),
                      controller: emailInputController,
                      validator: emailValidator,
                      keyboardType: TextInputType.emailAddress,
//                      validator: emailValidator,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  height: 70.0,
                  child: TextFieldContainer(
                    child: TextFormField(
                      cursorColor: kPrimaryColor,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.lock,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "create password"),
                      controller: pwdInputController,
                      validator: pwdValidator,
                      obscureText: true,
//                      validator: emailValidator,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  height: 70.0,
                  child: TextFieldContainer(
                    child: TextFormField(
                      cursorColor: kPrimaryColor,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.lock,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "confirm password"),
                      controller: confirmPwdInputController,
                      obscureText: true,
//                      validator: emailValidator,
                    ),
                  ),
                ),
              ),
              RoundedButton(
                text: "SIGNUP",
                press: () {
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
                                "phonenumber": phoneNumberController.text,
                                "email": emailInputController.text,
                              })
                              .then((result) => {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage(
                                                  title: "'s Tasks",
                                                  uid: authResult.user.uid,
                                                )),
                                        (_) => false),
                                    firstNameInputController.clear(),
                                    lastNameInputController.clear(),
                                    phoneNumberController.clear(),
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
              SizedBox(height: size.height * 0.01),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginScreen();
                      },
                    ),
                  );
                },
              ),
              OrDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SocalIcon(
                      iconSrc: "assets/icons/google-icon.svg",
                      press: () {
                        signInWithGoogle(success).whenComplete(() {
                          if (success == true)
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return HomePage(
                                    title: "Welcome",
                                  );
                                },
                              ),
                            );
                          else
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return Body();
                                },
                              ),
                            );
                        });
                      }),
                  SocalIcon(
                    iconSrc: "assets/icons/facebook.svg",
                    press: () {
                      Navigator.pushReplacementNamed(context, "/Fblogin");
                    },
                  ),
                  SocalIcon(
                    iconSrc: "assets/icons/twitter.svg",
                    press: () {
                      Navigator.pushReplacementNamed(context, "/Twit");
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
