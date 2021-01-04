import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/ComeraV/cam.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/utils/utils.dart';

class ChatsPage extends StatefulWidget {

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 3)),
      );


    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraS()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery
        .of(context)
        .size
        .width;

    final pageTitle = Padding(
      padding: EdgeInsets.only(top: 0.0, bottom: 20.0),
      child: Text(
        "Status Updates",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final notificationHeader = Container(
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: Text(
        "Coming Soon....",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
      ),
    );

    final notificationText = Text(
        "Status feature is coming soon on our app.",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15.0,
          color: Colors.grey.withOpacity(0.6),
        ),
    );
    final deviceHeight = MediaQuery.of(context).size.height;

    final image = Image.asset(
      AvailableImages.emptyState['assetPath'],
    );



    return GestureDetector(

      onTap: () => print("hui"),

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
              top: 40.0,
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
