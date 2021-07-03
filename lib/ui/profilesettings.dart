import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:techstagram/Changepassword/login_screen.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/services/database.dart';
//import 'package:techstagram/models/users.dart';

class ProfileSettings extends StatefulWidget {
  final String email;
  final String phonenumber;
  final bool emailVerification;
  final String uid;
  ProfileSettings(
      this.email, this.phonenumber, this.emailVerification, this.uid);
  @override
  _ProfileSettingsState createState() =>
      _ProfileSettingsState(email, phonenumber, emailVerification, uid);
  static bool valueP = false;
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;
  bool valuef = true;

  final String email;
  final String phonenumber;
  bool emailVerification;
  final String uid;
  final auth = FirebaseAuth.instance;
  Timer timer;
  bool emailVerify = false;
  int followers;
  int following;
  int posts;
  bool private = false;
  User currUser;
  DocumentSnapshot docSnap;
  TextEditingController firstNameController,
      lastNameController,
      emailController,
      bioController,
      birthdayController,
      genderController,
      linkController,
      photoUrlController,
      coverPhotoUrlController,
      displayNameController,
      workController,
      educationController,
      phonenumberController,
      currentCityController,
      homeTownController,
      relationshipController,
      followersController,
      followingController,
      pinCodeController,
      userPostsController,
      uidController;

  DateTime selectedDate = DateTime.now();
  DateTime birthdate;
  String displayDate;

  void sendVerificationEmail() async {
    print("andar aaya");
    User firebaseUser = auth.currentUser;
    print("hogaya bhai");

    Fluttertoast.showToast(
        timeInSecForIosWeb: 100,
        msg: "email verificatin link has sent to you mail");

    await firebaseUser.sendEmailVerification();
  }

  fetchProfileData() async {
    currUser = FirebaseAuth.instance.currentUser;
    try {
      docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();

      displayNameController.text = docSnap["displayName"];
      firstNameController.text = docSnap["fname"];
      lastNameController.text = docSnap["surname"];
      uidController.text = docSnap["uid"];
      emailController.text = docSnap["email"];
      photoUrlController.text = docSnap["photoURL"];
      phonenumberController.text = docSnap["phonenumber"];
      emailVerify = docSnap["emailVerified"];
      bioController.text = docSnap["bio"];
      followers = docSnap["followers"];
      following = docSnap["following"];
      posts = docSnap["posts"];
      private = docSnap["private"];
      coverPhotoUrlController.text = docSnap['coverPhotoUrl'];

      if (private) {
        setState(() {
          ProfileSettings.valueP = true;
        });
      } else {
        setState(() {
          ProfileSettings.valueP = false;
        });
      }
      // setState(() {
      //   isLoading = false;
      // });

    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  // Future<String> emailVerify(String email) async {
  //
  //   FirebaseUser firebaseUser = await auth.currentUser();
  //
  //   print("bahia bhia");
  //   print(email);
  //   try {
  //     print("try");
  //     await firebaseUser.sendEmailVerification();
  //     Fluttertoast.showToast(
  //         timeInSecForIosWeb: 100,
  //         msg:
  //         "email Verification link has been sent to your mail");
  //     return currUser.uid;
  //   } catch (e) {
  //     print("An error occured while trying to send email verification");
  //     print(e.message);
  //   }
  //   return null;
  // }

  @override
  void initState() {
    // user = auth.currentUser as FirebaseUser;
//    user.sendEmailVerification();

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phonenumberController = TextEditingController();
    // emailVerificationController = TextEditingController();
    pinCodeController = TextEditingController();
    bioController = TextEditingController();
    genderController = TextEditingController();
    linkController = TextEditingController();
    photoUrlController = TextEditingController();
    coverPhotoUrlController = TextEditingController();
    displayNameController = TextEditingController();
    workController = TextEditingController();
    educationController = TextEditingController();
    currentCityController = TextEditingController();
    homeTownController = TextEditingController();
    relationshipController = TextEditingController();
    pinCodeController = TextEditingController();
    followersController = TextEditingController();
    followingController = TextEditingController();
    userPostsController = TextEditingController();
    uidController = TextEditingController();

    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      checkEmailVerified();
    });
    super.initState();

    fetchProfileData();
  }

  Future<void> checkEmailVerified() async {
   User firebaseUser = auth.currentUser;

    await firebaseUser.reload();
    if (firebaseUser.emailVerified) {
      timer.cancel();
      print(firebaseUser.email);
      DatabaseService().updateEmailVerification(uid);
      setState(() {
        emailVerification = true;
      });
    }
  }

  setprivate(bool private) async {
    print(private);
    print(uid);
    print("dekho");

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({'private': private});

    print("yaha aaya");
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  _ProfileSettingsState(
      this.email, this.phonenumber, this.emailVerification, this.uid);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Settings", style: TextStyle(color: Colors.deepPurple)),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: SettingsList(
        // backgroundColor: Colors.orange,
        sections: [
          SettingsSection(
            title: 'Account',
            titleTextStyle: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile(
                title: 'Phone number',
                leading: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.phone,
                      color: Colors.grey,
                    )),
                trailing: Text(
                  phonenumber,
                  style: TextStyle(
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              SettingsTile(
                title: 'Email',
                leading: Icon(
                  Icons.email,
                  color: Colors.grey,
                ),
                trailing: (email != null)
                    ? (emailVerification == true)
                        ? Text(
                            "Verified",
                            style: TextStyle(
                              color: Colors.deepPurple,
                            ),
                          )
                        : MaterialButton(
                            onPressed: () {
                              sendVerificationEmail();
                            },
                            child: Text(
                              "Verify your email",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          )
                    : Text(
                        "No Email",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
              ),
              SettingsTile(
                onTap: () {
                  FirebaseAuth.instance
                      .signOut()
                      .then((result) => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new LoginScreen())))
                      .catchError((err) => print(err));
                  print("loggedout");
                },
                title: 'Log out',
                leading: GestureDetector(
                    child: new Icon(
                      Icons.exit_to_app,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      FirebaseAuth.instance
                          .signOut()
                          .then((result) => Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new LoginScreen())))
                          .catchError((err) => print(err));
                      print("loggedout");
                    }),
              ),
            ],
          ),
          SettingsSection(
            title: 'Notification Settings',
            titleTextStyle: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile(
                  title: 'Comments',
                  leading: Icon(
                    Icons.comment,
                    color: Colors.grey,
                  )),
              SettingsTile(
                  title: 'Tags',
                  leading: Icon(
                    Icons.tag_faces,
                    color: Colors.grey,
                  )),
              SettingsTile(
                  title: 'Reminders',
                  leading: Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  )),
              SettingsTile(
                onPressed: _selectDate,
                  title:(displayDate!=null)?displayDate: 'Set your Birthday',
                  leading: Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  )),
            ],
          ),
          SettingsSection(
            title: 'Security',
            titleTextStyle: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile.switchTile(
                title: (ProfileSettings.valueP) ? 'Private' : 'Public',
                leading: Icon(
                  (ProfileSettings.valueP)
                      ? Icons.privacy_tip_outlined
                      : Icons.person_outline_outlined,
                  color: Colors.grey,
                ),
                switchValue: ProfileSettings.valueP,
                switchActiveColor: Colors.deepPurple,
                onToggle: (value) {
                  if (ProfileSettings.valueP == true) {
                    setState(() {
                      ProfileSettings.valueP = false;
                    });
                    setState(() {
                      setprivate(ProfileSettings.valueP);
                    });

                  } else {
                    setState(() {
                      ProfileSettings.valueP = true;
                    });
                    setState(() {
                      setprivate(ProfileSettings.valueP);
                    });
                  }
                },
              ),
              SettingsTile.switchTile(
                title: 'Use fingerprint',
                leading: Icon(
                  Icons.fingerprint,
                  color: Colors.grey,
                ),
                switchValue: false,
                switchActiveColor: Colors.deepPurple,
                onToggle: (value) {
                  if (valuef == true) {
                    setState(() {
                      valuef = false;
                    });
                  } else {
                    setState(() {
                      valuef = true;
                    });
                  }
                },
              ),
              SettingsTile(
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen()),
                  );
                },
                title: 'Change password',
                leading: Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
//                enabled: notificationsEnabled,
                leading: Icon(
                  Icons.notifications_active,
                  color: Colors.grey,
                ),
                switchValue: false,
                switchActiveColor: Colors.deepPurple,
                onToggle: (value) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Miscellaneous',
            titleTextStyle: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.bold),
            tiles: [
              SettingsTile(
                  title: 'Terms of Service',
                  leading: Icon(
                    Icons.description,
                    color: Colors.grey,
                  )),
              SettingsTile(
                  title: 'Privacy Policy',
                  leading:
                      Icon(Icons.collections_bookmark, color: Colors.grey)),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Icon(
                    Icons.build,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Version: 1.6.7',
                  style: TextStyle(color: Colors.purple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  _selectDate(BuildContext context) async {

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1921,1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        String date =
            "${picked.toLocal().day}/${picked.toLocal().month}/${picked.toLocal().year}";
        displayDate = date;
      });
  }
}
