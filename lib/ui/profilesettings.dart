import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:techstagram/Changepassword/login_screen.dart';
import 'package:techstagram/Login/login_screen.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;
  bool valuef = false;

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
                  child: Icon(Icons.phone,color: Colors.green,))),
              SettingsTile(title: 'Email', leading: Icon(Icons.email,color: Colors.blue,)),
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
                    color: Colors.redAccent,
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
              SettingsTile(title: 'Comments', leading: Icon(Icons.comment,color: Colors.lightBlueAccent,)),
              SettingsTile(title: 'Tags', leading: Icon(Icons.tag_faces,color: Colors.teal,)),
              SettingsTile(title: 'Reminders', leading: Icon(Icons.calendar_today,color: Colors.blue.shade800,)),
            ],
          ),
          SettingsSection(
            title: 'Security',titleTextStyle: TextStyle(color: Colors.deepPurple,
            fontWeight: FontWeight.bold),
            tiles: [

              SettingsTile.switchTile(
                  title: 'Use fingerprint',
                  leading: Icon(Icons.fingerprint,color: Colors.green.shade800,),
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
                leading: Icon(Icons.lock,color: Colors.redAccent.shade100,),
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
//                enabled: notificationsEnabled,
                leading: Icon(Icons.notifications_active,color: Colors.brown,),
                switchValue: true,
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
                  title: 'Terms of Service', leading: Icon(Icons.description,color: Colors.brown.shade700,)),
              SettingsTile(
                  title: 'Privacy Policy',
                  leading: Icon(Icons.collections_bookmark,color: Colors.brown.shade700)),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Icon(Icons.build),
                ),
                Text(
                  'Version: 1.0.0 (10)',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}