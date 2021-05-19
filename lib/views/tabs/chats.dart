import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techstagram/ComeraV/camera_screen.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/utils/utils.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class ChatsPage extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;

  const ChatsPage({Key key, @required this.videoPlayerController, this.looping})
      : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

bool cameraon = true;

class _ChatsPageState extends State<ChatsPage> {
  ChewieController _chewieController;

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0)
      // user have just tapped on screen (no dragging)
      return;

    if (details.primaryVelocity.compareTo(0) == -1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 3)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraScreen(cam: 0)),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      looping: widget.looping,
    );
  }

  Widget build(BuildContext context) {
    Chewie(
      controller: _chewieController,
    );
    final deviceWidth = MediaQuery.of(context).size.width;

    final pageTitle = Padding(
      padding: EdgeInsets.only(top: 0.0, bottom: 20.0),
      child: Text(
        "Status updates ",
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
            height: deviceHeight + 500,
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
                    ChatsPage(
                        videoPlayerController: VideoPlayerController.network(
                            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4')),
                    // AspectRatio(
                    //     aspectRatio: 16 / 9,
                    //     child: BetterPlayer.network(
                    //         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'
                    //     )
                    // ),
                    // AspectRatio(
                    //     aspectRatio: 16 / 9,
                    //     child: BetterPlayer.network(
                    //         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'
                    //     )
                    // ),
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
