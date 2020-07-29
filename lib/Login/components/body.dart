import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:techstagram/Login/components/background.dart';
import 'package:techstagram/Signup/components/or_divider.dart';
import 'package:techstagram/Signup/components/social_icon.dart';
import 'package:techstagram/Signup/signup_screen.dart';
import 'package:techstagram/components/already_have_an_account_acheck.dart';
import 'package:techstagram/components/rounded_button.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/ui/HomePage.dart';

import '../../constants.dart';
import '../../forgotpassword.dart';

class Body extends StatefulWidget {
  final IconData icon;

  const Body({
    Key key,
    this.icon = Icons.email,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool loginfail = false;
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.35,
              ),
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  height: 70.0,
                  child: new Theme(
                    data: new ThemeData(
                      primaryColor: Colors.deepPurple,
                    ),
                    child: TextFieldContainer(
                      child: TextFormField(
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              widget.icon,
                              color: kPrimaryColor,
                            ),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true,
                            hintText: "email"),
                        controller: emailInputController,
                        keyboardType: TextInputType.emailAddress,
//                      validator: emailValidator,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  height: 70.0,
                  child: new Theme(
                    data: new ThemeData(
                      primaryColor: Colors.deepPurple,
                    ),
                    child: TextFieldContainer(
                      child: TextFormField(
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.lock,
                              color: kPrimaryColor,
                            ),
                            border: InputBorder.none,
                            fillColor: Colors.deepPurple.shade50,
                            errorText: loginfail ? 'password not match' : null,
                            filled: true,
                            hintText: "password"),
                        controller: pwdInputController,
                        obscureText: true,
//                      validator: pwdValidator,
                      ),
                    ),
                  ),
                ),
              ),
              RoundedButton(
                  text: "LOGIN",
                  press: () {
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
                                                title: "hello",
                                                uid: authResult.user.uid,
                                              ))))
                              .catchError((err) => print(err)))
                          .catchError((err) => print(err));
                    }
                  }),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignUpScreen();
                      },
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(right: 0.0, top: 10.0),
                child: Container(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ForgotScreen()));
                    },
                    child: Text(
                      "Forgot password ?",
                      style: TextStyle(color: Color(0xFF6F35A5)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              OrDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SocalIcon(
                    iconSrc: "assets/icons/facebook.svg",
                    press: () {},
                  ),
                  SocalIcon(
                    iconSrc: "assets/icons/instagram.svg",
                    press: () {},
                  ),
                  SocalIcon(
                    iconSrc: "assets/icons/google-plus.svg",
                    press: () {},
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
