import 'dart:io';
import 'package:flutter/material.dart';
import 'package:techstagram/ComeraV/Camera.dart';
import 'package:techstagram/ComeraV/video_controls.dart';
import 'package:techstagram/resources/uploadimage.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({this.videoPath, this.cam});

  final String videoPath;
  final int cam;
  @override
  _VideoPreviewState createState() => _VideoPreviewState(videoPath, cam);
}

class _VideoPreviewState extends State<VideoPreview>
    with SingleTickerProviderStateMixin {
  _VideoPreviewState(this.videoPath, this.cam);
  AnimationController _animationController;
  VideoPlayerController _controller;
  final String videoPath;
  final int cam;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then(
        (_) {
          setState(() {});
        },
      );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _pauseVideo() {
    _animationController.reverse();
    _controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() async {
      print('pop-');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Discard post ?"),
              content: Text("If you go back now, you will lose your Post.",
                  style: TextStyle(color: Colors.deepPurple)),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 120.0),
                  child: Column(
                    children: [
                      MaterialButton(
                        child: Text(
                          "Discard",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () {
                          //  _deleteFile();R
                          _pauseVideo();
                          print(cam);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return CameraExampleHome(
                                  cam: cam,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      MaterialButton(
                        child: Text(
                          "Keep",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                )
              ],
            );
          });
    }

    final size = MediaQuery.of(context).size;
    if (_controller.value.isInitialized) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: Card(
            child: Stack(
              children: <Widget>[
                ClipRect(
                  child: Container(
                    child: Transform.scale(
                      scale: _controller.value.aspectRatio / size.aspectRatio,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 6.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 30.0,
                        ),
                        onPressed: () {
                          // Future<bool> _onWillPop() async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text("Discard post ?"),
                                  content: Text(
                                      "If you go back now, you will lose your Post",
                                      style:
                                          TextStyle(color: Colors.deepPurple)),
                                  actions: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 120.0),
                                      child: Column(
                                        children: [
                                          MaterialButton(
                                            child: Text(
                                              "Discard",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            onPressed: () {
                                              //_deleteFile();
                                              // Navigator.pop(context,
                                              // MaterialPageRoute(
                                              //   builder: (context) {
                                              //     return CameraScreen(cam: cam,);
                                              //   }
                                              // ));
                                              //  _pauseVideo();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return CameraExampleHome(
                                                      cam: cam,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                          MaterialButton(
                                            child: Text(
                                              "Keep",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              });
                        }
                        //}
                        ),
                  ),
                ),
                Positioned(
                  top: 24.0,
                  right: 12.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _pauseVideo();
                      // Navigator.pop(context,
                      //   MaterialPageRoute(builder: (context) => HomePage()),);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UploadImage(
                                  isVideo: true,
                                  file: File(widget.videoPath),
                                  shared: false,
                                )),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoControls(
                    videoController: _controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
