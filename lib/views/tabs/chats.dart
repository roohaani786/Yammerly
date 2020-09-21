import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/ComeraV/cam.dart';
//import 'package:techstagram/resources/opencamera.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/utils/utils.dart';

import '../../phoneVerification.dart';

class ChatsPage extends StatefulWidget {


//  List<CameraDescription> cameras = [];

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

bool cameraon = true;

class _ChatsPageState extends State<ChatsPage> {

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0)
      // user have just tapped on screen (no dragging)
      return;

    if (details.primaryVelocity.compareTo(0) == -1) {
//      dispose();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 2)),
      );


    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraS()),
      );
      cameraon = false;
//      Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (BuildContext context) => HomePage())).then((res) {
//        setState(() {
//          cameraon = true;
//        });
//      }
//      );
    }
  }

//  Future<void> _opencamera() async {
//    // Fetch the available cameras before initializing the app.
//    try {
//      WidgetsFlutterBinding.ensureInitialized();
//      cameras = await availableCameras();
//    } on CameraException catch (e) {
//      logError(e.code, e.description);
//    }
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => CameraExampleHome(cameras)),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery
        .of(context)
        .size
        .width;

    final pageTitle = Padding(
      padding: EdgeInsets.only(top: 1.0, bottom: 20.0),
      child: Text(
        "Status",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final searchBar = Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      height: 50.0,
      width: deviceWidth,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          ),
          contentPadding: EdgeInsets.only(top: 15.0),
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    final onlineUsersHeading = Text(
      "ONLINE USERS",
      style: TextStyle(
        color: Colors.grey.withOpacity(0.6),
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
      ),
    );
    final notificationHeader = Container(
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: Text(
        "No Status at the Movement",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
      ),
    );

    final notificationText = Text(
        "You currently do not have any Status.",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18.0,
          color: Colors.grey.withOpacity(0.6),
        ),
    );
    final deviceHeight = MediaQuery.of(context).size.height;

    final image = Image.asset(
      AvailableImages.emptyState['assetPath'],
    );



    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) =>
          _onHorizontalDrag(details),

      onTap: () => Navigator.of(context).pop(true),

//      onHorizontalDragUpdate: (details){
//        print(details.primaryDelta);
//        if(details.primaryDelta >0){
//          ChatsPage();
//        }
//        else if (details.primaryDelta <0){
//          CameraExampleHome(cameras);
//        }
//        else{
//          print("error");
//        }
//
//      }

      child: Scaffold(
        // resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              top: 70.0,
              left: 30.0,
              right: 30.0,
              bottom: 30.0,
            ),
            height: deviceHeight,
            width: deviceWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                pageTitle,
                SizedBox(
                  height: deviceHeight * 0.1,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    image,
                    notificationHeader,
                    notificationText,
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.circleNotch,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PhoneV()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
