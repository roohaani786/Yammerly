import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/Signup/signup_screen.dart';
import 'package:techstagram/Welcome/components/background.dart';
import 'package:techstagram/components/rounded_button.dart';
import 'package:techstagram/constants.dart';

class Body extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return new WillPopScope(
      onWillPop: () async => false,
      child: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
//              Text(
//                "WELCOME TO AIO-Chat",
//                style: TextStyle(fontWeight: FontWeight.bold),
//              ),
//              SizedBox(height: size.height * 0.05),
              SvgPicture.asset(
                "assets/icons/chat.svg",
                height: size.height * 0.45,
              ),
              SizedBox(height: size.height * 0.05),
              RoundedButtonX(
                text: "LOGIN",
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
              RoundedButtonX(
                text: "SIGN UP",
                color: kPrimaryLightColor,
                textColor: Colors.black,
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
            ],
          ),
        ),
      ),
    );
  }
}
