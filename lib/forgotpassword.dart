import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/Login/components/background.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/constants.dart';

import 'checkmail.dart';

class ForgotScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ForgotScreen();
  }
}

class _ForgotScreen extends State<ForgotScreen> {
  String email = "";
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Background(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(

//        backgroundColor: Color(0xFF6F35A5),
            title: Text(
              "Forgot Password",
              style: TextStyle(color: Colors.deepPurple),
            ),
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
              onPressed: () =>
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new LoginScreen())
                  ),
          ),
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 30.0, left: 20.0, right: 20.0, bottom: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(
                      'We will mail you a link ... Please click on that link to reset your password',
                      style:
                          TextStyle(color: Color(0xFF6F35A5), fontSize: 15.0,
                          fontFamily: "Quicksand-Bold"),
                    ),
                    Theme(
                      data: ThemeData(hintColor: Colors.blue),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "please enter your email";
                            } else {
                              email = value;
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.mail,
                              color: kPrimaryColor,
                            ),
                            labelText: "Email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Color(0xffff2fc3), width: 1)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Color(0xffff2fc3), width: 1)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Color(0xffff2fc3), width: 1)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: Color(0xffff2fc3), width: 1)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
                        child: RaisedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email)
                                  .then((value) => print("Check you mail"));
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CheckMail()));
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Colors.purple,
                          child: Text(
                            "Send email",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                                fontFamily: "Quicksand-Bold"),
                          ),
                          padding: EdgeInsets.all(10.0),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
