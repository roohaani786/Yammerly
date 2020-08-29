import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techstagram/camera/camera_screen.dart';
//import 'package:techstagram/resources/opencamera.dart';
import 'package:techstagram/ui/HomePage.dart';

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
        MaterialPageRoute(builder: (context) => CameraScreen()),
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
        "Chats",
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
          body: SingleChildScrollView(
            child: Container(child: Text("Pending implementation")),
//        child: Container(
//          padding: EdgeInsets.only(top: 40.0),
//          width: deviceWidth,
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Container(
//                padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    pageTitle,
//                    searchBar,
//                    onlineUsers,
//                    chatList
//                  ],
//                ),
//              )
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget _buildUserCard(User user, BuildContext context) {
//    final firstName = user.name.split(" ")[0];
//
//    final onlineTag = Positioned(
//      bottom: 10.0,
//      right: 3.0,
//      child: Container(
//        height: 15.0,
//        width: 15.0,
//        decoration: BoxDecoration(
//          shape: BoxShape.circle,
//          border: Border.all(color: Colors.white, width: 2.0),
//          color: Colors.lightGreen,
//        ),
//      ),
//    );
//    return Column(
//      children: <Widget>[
//        InkWell(
//          onTap: () => Navigator.pushNamed(context, chatDetailsViewRoute,
//              arguments: user.id),
//          child: Stack(
//            children: <Widget>[
//              Container(
//                margin: EdgeInsets.only(right: 8.0),
//                height: 70.0,
//                width: 70.0,
//                decoration: BoxDecoration(
//                  image: DecorationImage(
//                    image: AssetImage(user.photo),
//                    fit: BoxFit.cover,
//                  ),
//                  shape: BoxShape.circle,
//                ),
//              ),
//              onlineTag
//            ],
//          ),
//        ),
//        Text(
//          firstName,
//          style: TextStyle(fontWeight: FontWeight.w600),
//        )
//      ],
//    );
//  }
//
//  Widget _buildChatTile(Chat chat, BuildContext context) {
//    final unreadCount = Positioned(
//      bottom: 9.0,
//      right: 0.0,
//      child: Container(
//        height: 25.0,
//        width: 25.0,
//        decoration: BoxDecoration(
//          shape: BoxShape.circle,
//          border: Border.all(color: Colors.white, width: 2.0),
//          gradient: primaryGradient,
//        ),
//        child: Center(
//          child: Text(
//            chat.unreadCount.toString(),
//            style: TextStyle(color: Colors.white),
//          ),
//        ),
//      ),
//    );
//
//    final userImage = InkWell(
//      onTap: () {
//        Navigator.pushNamed(
//          context,
//          userDetailsViewRoute,
//          arguments: chat.userId,
//        );
//      },
//      child: Stack(
//        children: <Widget>[
//          Hero(
//            tag: chat.userImage,
//            child: Container(
//              margin: EdgeInsets.only(right: 8.0, bottom: 10.0),
//              height: 70.0,
//              width: 70.0,
//              decoration: BoxDecoration(
//                image: DecorationImage(
//                  image: AssetImage(chat.userImage),
//                  fit: BoxFit.cover,
//                ),
//                shape: BoxShape.circle,
//              ),
//            ),
//          ),
//          chat.unreadCount == 0 ? Container() : unreadCount
//        ],
//      ),
//    );
//
//    final userNameMessage = Expanded(
//      child: InkWell(
//        onTap: () {
//          Navigator.pushNamed(
//            context,
//            chatDetailsViewRoute,
//            arguments: chat.userId,
//          );
//        },
//        child: Container(
//          padding: EdgeInsets.only(
//            left: 10.0,
//          ),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Hero(
//                tag: chat.userName,
//                child: Text(
//                  chat.userName,
//                  style: TextStyle(
//                    fontWeight: FontWeight.bold,
//                    fontSize: 20.0,
//                  ),
//                ),
//              ),
//              Text(
//                chat.message,
//                style: TextStyle(
//                  fontWeight: FontWeight.w600,
//                  fontSize: 18.0,
//                  color: Colors.grey.withOpacity(0.6),
//                ),
//                overflow: TextOverflow.ellipsis,
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//    return Container(
//      margin: EdgeInsets.only(bottom: 8.0),
//      child: Row(
//        children: <Widget>[userImage, userNameMessage],
//      ),
//    );
          )),
    );
  }
}
