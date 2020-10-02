import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart' as fl;
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:responsive_layout_builder/responsive_layout_builder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:techstagram/Login/components/background.dart';
import 'package:techstagram/Signup/components/or_divider.dart';
import 'package:techstagram/Signup/components/social_icon.dart';
import 'package:techstagram/Signup/signup_screen.dart';
import 'package:techstagram/components/already_have_an_account_acheck.dart';
import 'package:techstagram/components/rounded_button.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/ui/HomePage.dart';
import '../../constants.dart';
import '../../forgotpassword.dart';

class Body extends StatefulWidget {
  final IconData icon;

  const Body({
    Key key,
    this.icon = FontAwesomeIcons.lockOpen,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _obscureText = true;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController ppwdInputController,pwdInputController,newpwdInputController;
  bool isUserSignedIn = true;

  final FocusNode _email = FocusNode();
  final FocusNode _pwd = FocusNode();
  final FocusNode _apwd = FocusNode();
  final FocusNode _cpwd = FocusNode();

  final FirebaseAuth auth = FirebaseAuth.instance;
  fl.FacebookLogin fbLogin = new fl.FacebookLogin();
  bool isFacebookLoginIn = false;
  String errorMessage = '';
  String successMessage = '';
  bool isLoading = false;
  bool facebooksuccess = false;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    ppwdInputController = new TextEditingController();
    newpwdInputController = new TextEditingController();
    super.initState();
    checkIfUserIsSignedIn();
  }

  @override
  void dispose() {
    newpwdInputController.dispose();
    ppwdInputController.dispose();
   // _newPasswordController.dispose();
   // _repeatPasswordController.dispose();
    super.dispose();
  }

  void _changePassword(String password) async{
    print(password);
    //Create an instance of the current user.
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_){
      print("Succesfull changed password");
      return PasswordChanged();
    }).catchError((error){
      print("Password can't be changed" + error.toString());
      showDialog(
          context: context,
          builder: (BuildContext context) {

            return AlertDialog(
              content: Text(
                '$error',
                style: TextStyle(color: Colors.black),
              ),
              title: Text("Error !", style:
              TextStyle(color: Colors.red),),
            );
          });
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  void checkIfUserIsSignedIn() async {
    var userSignedIn = await googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });
  }


  bool errordikhaoL = false;


  Future<String> signIn(String email, String password) async {
    FirebaseUser user;
    String errorMessage;

    this.setState(() {
      isLoading = true;
    });

    try {
      if (_loginFormKey.currentState.validate()) {
        AuthResult result = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: emailInputController.text,
            password: pwdInputController.text);
        user = result.user;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Your email or password is wrong.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage =
          "An error occurred, maybe due to unfilled fields, internet or other issue.";
      }

      Future.error(errorMessage);
    }

    if (errorMessage != null) {
      this.setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                '$errorMessage',
                style: TextStyle(color: Colors.black),
              ),
              title: Text("Error !", style:
              TextStyle(color: Colors.red),),
            );
          });
    }

    return user.uid;
  }

  //facebook login method

  PublishSubject loading = PublishSubject();

  Future<FirebaseUser> facebookLogin(BuildContext context) async {
    loading.add(true);


    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
    await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
//        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
//        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        this.setState(() {
          facebooksuccess = true;
        });
        try {
          FacebookAccessToken facebookAccessToken =
              facebookLoginResult.accessToken;
          final AuthCredential credential = FacebookAuthProvider.getCredential(
              accessToken: facebookAccessToken.token);
          final FirebaseUser user = (await auth.signInWithCredential(
              credential))
              .user;
          (await FirebaseAuth.instance.currentUser()).uid;
//        assert(user.email != null);
//        assert(user.displayName != null);
//        assert(user.isAnonymous);
//        assert(user.getIdToken() != null);

          authService.updateUserData(user);
          loading.add(false);

          print("signed in " + user.displayName);
          return user;
        } catch (e) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Text(e.code, style: TextStyle(
                      color: Colors.deepPurple
                  )),
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
//        onLoginStatusChanged(true);
        break;
    }

  }

  //facebook logout method

  Future<bool> facebookLoginout() async {
    await auth.signOut();
    await fbLogin.logOut();
    return true;
  }

  //Password padlock toggle

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loginfail = false;
    Size size = MediaQuery
        .of(context)
        .size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios,color: Colors.deepPurple,), onPressed:
          (){
            Navigator.pop(context);
          }
              ),
          title: Text("Change Password",style: TextStyle(
            color: Colors.deepPurple,
          ),),
        ),
        body: ResponsiveLayoutBuilder(
          builder: (context, size) =>
              Background(
                child: !isLoading ? SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/icons/login.svg",
                          height: 200.0,
                        ),
                        SizedBox(height: 10.0),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 50.0,
                            width: 250.0,
                            child: new Theme(
                              data: new ThemeData(
                                primaryColor: Colors.deepPurple,
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.only(top: 5, bottom: 2, right: 5, left: 10),
//                              width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: kPrimaryLightColor,
                                  borderRadius: BorderRadius.circular(29),
//                                  border: Border.all(
//                                    color: (errordikhaoL == true)
//                                        ? Colors.red
//                                        : kPrimaryLightColor,
//                                  ),
                                ),
                                child: TextFormField(
                                  //enableInteractiveSelection: false,
                                  cursorColor: kPrimaryColor,

                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 0, right: 3, top: 6, bottom: 12),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.red)),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _toggle();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0),
                                          child: new Icon(
                                            _obscureText
                                                ? FontAwesomeIcons.eyeSlash
                                                : FontAwesomeIcons.eye,
                                            size: 15.0,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        FontAwesomeIcons.lock,
                                        color: Colors.brown.shade300,
                                      ),
                                      border: InputBorder.none,
                                      fillColor: Colors.deepPurple.shade50,
                                      errorText:
                                      loginfail ? 'password not match' : null,
                                      filled: true,
                                      hintText: "Current Password",
                                    // errorText: checkCurrentPasswordValid
                                    //     ? null
                                    //     : "Please double check your current password",
                                  ),
                                  controller: ppwdInputController,
                                  obscureText: _obscureText,
                                  focusNode: _pwd,
                                  onFieldSubmitted: (value) {
                                    _pwd.unfocus();
                                    RoundedButton;
                                  },
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      height: 1.5,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 50.0,
                            width: 250.0,
                            child: new Theme(
                              data: new ThemeData(
                                primaryColor: Colors.deepPurple,
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.only(top: 5, bottom: 2, right: 5, left: 10),
//                              width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: kPrimaryLightColor,
                                  borderRadius: BorderRadius.circular(29),
//                                  border: Border.all(
//                                    color: (errordikhaoL == true)
//                                        ? Colors.red
//                                        : kPrimaryLightColor,
//                                  ),
                                ),
                                child: TextFormField(
                                  //enableInteractiveSelection: false,
                                  cursorColor: kPrimaryColor,

                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 0, right: 3, top: 6, bottom: 12),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.red)),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _toggle();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0),
                                          child: new Icon(
                                            _obscureText
                                                ? FontAwesomeIcons.eyeSlash
                                                : FontAwesomeIcons.eye,
                                            size: 15.0,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        FontAwesomeIcons.lock,
                                        color: Colors.brown.shade800,
                                      ),
                                      border: InputBorder.none,
                                      fillColor: Colors.deepPurple.shade50,
                                      errorText:
                                      loginfail ? 'password not match' : null,
                                      filled: true,
                                      hintText: "New Password"),
                                  controller: newpwdInputController,
                                  obscureText: _obscureText,
                                  focusNode: _apwd,
                                  onFieldSubmitted: (value) {
                                    _apwd.unfocus();
                                    RoundedButton;
                                  },
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      height: 1.5,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 50.0,
                            width: 250.0,
                            child: new Theme(
                              data: new ThemeData(
                                primaryColor: Colors.deepPurple,
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.only(top: 5, bottom: 2, right: 5, left: 10),
//                              width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: kPrimaryLightColor,
                                  borderRadius: BorderRadius.circular(29),
//                                  border: Border.all(
//                                    color: (errordikhaoL == true)
//                                        ? Colors.red
//                                        : kPrimaryLightColor,
//                                  ),
                                ),
                                child: TextFormField(
                                  //enableInteractiveSelection: false,
                                  cursorColor: kPrimaryColor,

                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 0, right: 3, top: 6, bottom: 12),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.red)),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _toggle();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0),
                                          child: new Icon(
                                            _obscureText
                                                ? FontAwesomeIcons.eyeSlash
                                                : FontAwesomeIcons.eye,
                                            size: 15.0,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        FontAwesomeIcons.lock,
                                        color: Colors.brown.shade800,
                                      ),
                                      border: InputBorder.none,
                                      fillColor: Colors.deepPurple.shade50,
                                      errorText:
                                      loginfail ? 'password not match' : null,
                                      filled: true,
                                      hintText: "Confirm New Password"),
                                  controller: newpwdInputController,
                                  obscureText: _obscureText,
                                  focusNode: _cpwd,
                                  onFieldSubmitted: (value) {
                                    _cpwd.unfocus();
                                    RoundedButton;
                                  },
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      height: 1.5,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: RoundedButton(
                              text: "Change Password",
                              press: () {
                                _changePassword(newpwdInputController.text);
//
                              }),
                        ),
                        SizedBox(height: 15.0),

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

                      ],
                    ),
                  ),
                ) : CircularProgressIndicator(
                  strokeWidth: 5.0,
                  semanticsLabel: 'loading...',
                  semanticsValue: 'loading...',
                  backgroundColor: Colors.deepPurpleAccent,
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple),
                ),
              ),
        ),
      ),
    );
  }
}

class PasswordChanged extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("success"),
      ),
    );
  }
}

_fieldFocusChange(BuildContext context, FocusNode currentFocus,
    FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
