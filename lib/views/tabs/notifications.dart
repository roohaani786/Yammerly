import 'package:flutter/material.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/utils/utils.dart';

class NotificationsPage extends StatefulWidget {


  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0)
      // user have just tapped on screen (no dragging)
      return;

    if (details.primaryVelocity.compareTo(0) == -1) {
//      dispose();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 4)),
      );
    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final pageTitle = Padding(
      padding: EdgeInsets.only(top: 1.0, bottom: 30.0),
      child: Text(
        "Notifications",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final image = Image.asset(
      AvailableImages.emptyState['assetPath'],
    );

    final notificationHeader = Container(
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: Text(
        "Coming Soon....",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
      ),
    );
    final notificationText = Text(
      "Notification feature is coming on our app.",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        color: Colors.grey.withOpacity(0.6),
      ),
      textAlign: TextAlign.center,
    );

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) =>
          _onHorizontalDrag(details),
      onTap: () => Navigator.of(context).pop(true),
      child: Scaffold(
        // resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              top: 30.0,
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
                    notificationText
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
