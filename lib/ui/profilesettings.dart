import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

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
              SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              SettingsTile(title: 'Email', leading: Icon(Icons.email)),
              SettingsTile(title: 'Log out', leading: Icon(Icons.exit_to_app)),
            ],
          ),

          SettingsSection(
            title: 'Notification Settings',titleTextStyle: TextStyle(color: Colors.deepPurple,
              fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile(title: 'Comments', leading: Icon(Icons.comment)),
              SettingsTile(title: 'Tags', leading: Icon(Icons.tag_faces)),
              SettingsTile(title: 'Reminders', leading: Icon(Icons.calendar_today)),
            ],
          ),
          SettingsSection(
            title: 'Security',titleTextStyle: TextStyle(color: Colors.deepPurple,
            fontWeight: FontWeight.bold),
            tiles: [

              SettingsTile(
                  title: 'Use fingerprint',
                  leading: Icon(Icons.fingerprint),
                  ),
              SettingsTile(
                title: 'Change password',
                leading: Icon(Icons.lock),
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
//                enabled: notificationsEnabled,
                leading: Icon(Icons.notifications_active),
                switchValue: true,
                onToggle: (value) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Misc',titleTextStyle: TextStyle(color: Colors.deepPurple,
              fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile(
                  title: 'Terms of Service', leading: Icon(Icons.description)),
              SettingsTile(
                  title: 'Privacy Policy',
                  leading: Icon(Icons.collections_bookmark)),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Image.asset(
                    'assets/settings.png',
                    height: 50,
                    width: 50,
                    color: Color(0xFF777777),
                  ),
                ),
                Text(
                  'Version: 1.0.0 (10)',
                  style: TextStyle(color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}