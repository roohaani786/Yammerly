import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:techstagram/Changepassword/login_screen.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileSettings extends StatefulWidget {
  final String email;
  final String phonenumber;
  final bool emailVerification;
  ProfileSettings(this.email,this.phonenumber,this.emailVerification);
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState(email,phonenumber,emailVerification);
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;
  bool valuef = true;
  final String email;
  final String phonenumber;
  final bool emailVerification;
  //FirebaseUser user;
  final auth = FirebaseAuth.instance;
  Timer timer;
  User user;

  Future<String> emailVerify(String email) async {

    user = auth.currentUser;

    print("bahia bhia");
    print(email);
    try {
      print("try");
      await user.sendEmailVerification();
      Fluttertoast.showToast(
          timeInSecForIosWeb: 100,
          msg:
          "email Verification link has been sent to your mail");
      return user.uid;
    } catch (e) {
      print("An error occured while trying to send email        verification");
      print(e.message);
    }
    return null;
  }

  @override
  void initState(){
    // user = auth.currentUser as FirebaseUser;
    // user.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user.reload();
    if (user.isEmailVerified) {
      timer.cancel();
      print("ho gaya bhai");
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  _ProfileSettingsState(this.email,this.phonenumber,this.emailVerification);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Settings",style:
          TextStyle(
            color: Colors.deepPurple
          )),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.deepPurple,), onPressed: (){
          Navigator.pop(context);
        }),
      ),
      body: SettingsList(
        // backgroundColor: Colors.orange,
        sections: [

          SettingsSection(
            title: 'Account',titleTextStyle: TextStyle(color: Colors.deepPurple,
          fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile(title: 'Phone number', leading: GestureDetector(
                onTap: (){

                },
                  child: Icon(Icons.phone,color: Colors.grey,)),
              trailing: Text(phonenumber,style: TextStyle(
                color: Colors.deepPurple,
              ),),),
              SettingsTile(title: 'Email', leading: Icon(Icons.email,color: Colors.grey,),
                  trailing: (emailVerification == true)?Text("Verified",style: TextStyle(
                    color: Colors.deepPurple,
                  ),):FlatButton(
                    onPressed: () {
                      emailVerify(email);
                    },
                    child: Text("Verify your email",style: TextStyle(
                      color: Colors.red,
                    ),),
                  ),),
              SettingsTile(
                onTap: (){
                  FirebaseAuth.instance
                      .signOut()

                      .then((result) =>
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (context) =>
                          new LoginScreen())
                      ))
                      .catchError((err) => print(err));
                print("loggedout");
                },
                title: 'Log out', leading: GestureDetector(
                  child: new Icon(
                    Icons.exit_to_app,
                    color: Colors.grey,
                  ),
                  onTap: () {

                    FirebaseAuth.instance
                        .signOut()
                        .then((result) =>
                        Navigator.push(context, new MaterialPageRoute(
                            builder: (context) =>
                            new LoginScreen())
                        ))
                        .catchError((err) => print(err));
                    print("loggedout");
                  }),),
            ],
          ),

          SettingsSection(
            title: 'Notification Settings',titleTextStyle: TextStyle(color: Colors.deepPurple,
              fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile(title: 'Comments', leading: Icon(Icons.comment,color: Colors.grey,)),
              SettingsTile(title: 'Tags', leading: Icon(Icons.tag_faces,color: Colors.grey,)),
              SettingsTile(title: 'Reminders', leading: Icon(Icons.calendar_today,color: Colors.grey,)),
            ],
          ),
          SettingsSection(
            title: 'Security',titleTextStyle: TextStyle(color: Colors.deepPurple,
            fontWeight: FontWeight.bold),
            tiles: [

              SettingsTile.switchTile(
                  title: 'Use fingerprint',
                  leading: Icon(Icons.fingerprint,color: Colors.grey,),
                switchValue: false,
                switchActiveColor: Colors.deepPurple,
                onToggle: (value) {
                   if(valuef == true){
                     valuef = false;
                   }
                   else{
                     valuef = true;
                   }
                },
                  ),
              SettingsTile(
                onTap: (){
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      ChangePasswordScreen()),
                  );
                },
                title: 'Change password',
                leading: Icon(Icons.lock,color: Colors.grey,),
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
//                enabled: notificationsEnabled,
                leading: Icon(Icons.notifications_active,color: Colors.grey,),
                switchValue: false,
                switchActiveColor: Colors.deepPurple,
                onToggle: (value) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Miscellaneous',titleTextStyle: TextStyle(color: Colors.deepPurple,
              fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile(
                  title: 'Terms of Service', leading: Icon(Icons.description,color: Colors.grey,)),
              SettingsTile(
                  title: 'Privacy Policy',
                  leading: Icon(Icons.collections_bookmark,color: Colors.grey)),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Icon(Icons.build,color: Colors.grey.shade600,),
                ),
                Text(
                  'Version: 1.4.0',
                  style: TextStyle(color: Colors.purple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}