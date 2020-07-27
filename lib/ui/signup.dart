import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:techstagram/resources/googlesignin.dart';


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
    final height = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
//        backgroundColor: Colors.grey.shade900,
        backgroundColor: Colors.white,

        body: Container(
            height: height,
////            decoration: BoxDecoration(
////              image: DecorationImage(
////                image: AssetImage("assets/sd.png"),
////                fit: BoxFit.cover,
////              ),
//            ),
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
                  key: _registerFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Row(
                          children: [
                            Column(
                              children: [

                                FlatButton(

                                  child: Container(

                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(
                                            40.0),
                                      ),
                                      height: 50.0,
                                      width: 50.0,
                                      child: Image.asset(
                                        "assets/google-logo.png",
                                      )),
                                  onPressed: () {
                                    signInWithGoogle().whenComplete(() {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return HomePage();
                                          },
                                        ),
                                      );
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: FlatButton(

                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, "/Fblogin");
                                    },

                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                              60.0),
                                        ),
                                        height: 44.0,
                                        width: 50.0,
                                        child: Image.asset(
                                          "assets/fb-logo.png",)),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Container(

                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(
                                            40.0),
                                      ),
                                      height: 45.0,
                                      width: 50.0,
                                      child: Image.asset(
                                        "assets/insta_logo.png",
                                      )),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Container(

                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(
                                            40.0),
                                      ),
                                      height: 50.0,
                                      width: 50.0,
                                      child: Image.asset(
                                        "assets/twitter-logo.png",
                                      )),
                                ),


                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Container(
                                      height: 50.0,
                                      width: 50.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(
                                            60.0),
                                      ),
                                      child: Image.asset(
                                          "assets/phone-icon.png")),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 60.0, top: 140.0),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Row(
                                  children: <Widget>[
                                    // height: 120.0,

                                    Container(
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Text("SIGNUP",
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,

                                            ),)),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        child: Align(
                                          child: FlatButton(
//                                             shape:  RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(20)),
//                                             color: Colors.purple,
                                            child: Text("LOGIN",
                                              style: TextStyle(
                                                color: Colors.deepPurpleAccent,
                                                fontSize: 15.0,
                                              ),),
                                            onPressed: () {
                                              Navigator.pushReplacementNamed(
                                                  context, "/Login");
                                            },
                                          ),
                                          //alignment: Alignment.center,
//                                           child: Text("SIGNIN",
//                                             style: TextStyle(
//                                               color: Colors.deepPurple,
//                                               fontSize: 25.0,
//                                               fontWeight: FontWeight.bold,
//
//                                             ),)
                                        ),
                                      ),
                                    ),

//                                Image.asset("assets/flashu.png",
//                                ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

//                      Padding(
//                        padding: const EdgeInsets.only(top: 8.0),
//                        child: Container(
//                          height: 50.0,
//                          child: new Theme(
//                            data: new ThemeData(
//                              primaryColor: Colors.blueAccent,
//                            ),
//                            child: TextFormField(
//                                decoration: InputDecoration(
////                                    border: new OutlineInputBorder(
////                                      borderRadius: const BorderRadius.all(
////                                        const Radius.circular(60.0),
////
////                                      ),
////                                    ),
//                                    fillColor: Colors.white70,
//                                    filled: true,
//                                     hintText: "last name"),
//                                controller: lastNameInputController,
//                                validator: (value) {
//                                  if (value.length < 3) {
//                                    return "Please enter a valid last name.";
//                                  }
//                                }),
//                          ),
//                        ),
//                      ),
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
//full name field
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
                                  hintText: "Full name"),
                              controller: firstNameInputController,
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
                              primaryColor: Colors.deepPurple,
                            ),
                            child: TextFormField(
                              decoration: InputDecoration(
//                                  border: new OutlineInputBorder(
//                                    borderRadius: const BorderRadius.all(
//                                      const Radius.circular(80.0),
//
//                                    ),
//                                  ),
                                  fillColor: Colors.white70,
                                  filled: true,
                                  hintText: "confirm password",
                                  labelStyle: TextStyle(
                                      color: Colors.grey.shade200,
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
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Container(
                          width: 250.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),

                          ),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),


                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0)),

                                ),
                                child: Text("SIGNUP")),
//                            color: Theme.of(context).primaryColor,
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () {
                              if (_registerFormKey.currentState.validate()) {
                                if (pwdInputController.text ==
                                    confirmPwdInputController.text) {
                                  FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                      email: emailInputController.text,
                                      password: pwdInputController.text)
                                      .then((authResult) =>
                                      Firestore.instance
                                          .collection("users")
                                          .document(authResult.user.uid)
                                          .setData({
                                        "uid": authResult.user.uid,
                                        "fname": firstNameInputController.text,
                                        "surname": lastNameInputController.text,
                                        "email": emailInputController.text,
                                      })
                                          .then((result) =>
                                      {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage(
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
                                          content: Text(
                                              "The passwords do not match"),
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
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text("Already have an account?",
                          style: TextStyle(
                              color: Colors.black,
                              fontStyle: FontStyle.italic
                          ),),
                      ),
//                      Padding(
//                        padding: const EdgeInsets.only(top: 20.0),
//                        child: Container(
//                          height: 40.0,
//                          width: 160.0,
//                          child: FlatButton(
//                            shape:  RoundedRectangleBorder(
//                                borderRadius: BorderRadius.circular(20)),
//                            color: Colors.purple,
//                            child: Text("LOGIN!",
//                            style: TextStyle(
//                              color: Colors.white,
//                            ),),
//                            onPressed: () {
//                              Navigator.pushReplacementNamed(context, "/Login");
//                            },
//                          ),
//                        ),
//                      ),

                    ],
                  ),
                ))));
  }


}