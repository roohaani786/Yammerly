import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/Login/components/background.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: unused_import
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
  TextEditingController emailInputController;
  bool isLoading = false;
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';


  Future<bool> useremailCheck(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return result.docs.isEmpty;
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
//    var hu = value;
    if (!regex.hasMatch(value) && value.length == null) {
      return "please enter valid email";
      // setState(() {
      //   errordikhaoL = true;
      // });
    } else {
      email = value;
      // setState(() {
      //   errordikhaoL = false;
      // });
    }
    return null;
  }

  Future<String> resetPass(String email) async {
    FirebaseUser user;
    String errorMessage;
    final valid = await useremailCheck(emailInputController.text);

      if (_formKey.currentState.validate()) {
        if (!valid) {
          print("bahia bhia");
          print(email);
          FirebaseAuth.instance
              .sendPasswordResetEmail(email: email)
              .then((value) => print("Check you mail"));
          Fluttertoast.showToast(
              timeInSecForIosWeb:100,
              msg:
              "Reset password link has sent to your mail");
         // Navigator.pop(context);
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );

        }else if(valid){
          showDialog(
              context: context,
              builder: (BuildContext context) {

                return AlertDialog(
                  title: Text("Error"),
                  content: Text("email does not exists!", style: TextStyle(
                      color: Colors.deepPurple
                  )),
                  actions: <Widget>[
                    // ignore: deprecated_member_use
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
    return null;
  }

  @override
  initState() {
    emailInputController = new TextEditingController();
    super.initState();
  }

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
          body: (isLoading == false)?Center(
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
                          controller: emailInputController,
                          //validator: emailValidator,
                          validator: (value) {
                            RegExp regex = new RegExp(pattern);
                            if (value.isEmpty) {
                              return "please enter your email";
                            } else if(!value.contains("@")){
                              return "invalid email address";
                            } else if(!value.contains(".com")){
                              return "invalid email address";
                            } else if(value.contains("@.com")){
                              return "invalid email address";
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
                        // ignore: deprecated_member_use
                        child: RaisedButton(
                          onPressed: () {
                            resetPass(email);
                            // if (_formKey.currentState.validate()) {
                            //   FirebaseAuth.instance
                            //       .sendPasswordResetEmail(email: email)
                            //       .then((value) => print("Check you mail"));
                            //   Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (BuildContext context) =>
                            //               CheckMail()));
                            // }
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
          ):Center(
            child: CircularProgressIndicator(
              strokeWidth: 5.0,
              semanticsLabel: 'loading...',
              semanticsValue: 'loading...',
              backgroundColor: Colors.deepPurpleAccent,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple),
            ),
          )),
    );
  }
}
