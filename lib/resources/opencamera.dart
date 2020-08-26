import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/views/tabs/chats.dart';
import 'package:video_player/video_player.dart';

class CameraExampleHome extends StatefulWidget {
  CameraExampleHome(List<CameraDescription> cameras);

  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  double scale = 1.0; //add this

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool cameraon = true;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int initialindexg;


  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0)
      // user have just tapped on screen (no dragging)
      return;

    if (details.primaryVelocity.compareTo(0) == -1) {
//      dispose();

      this.setState(() {
        cameraon = false;
      });
//      initialindexg = 1;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 1)),
      );
    }
    else {
      print("error");
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
//      onPanUpdate: (details) {
//        if (details.delta.dx < 0) {
//          // swiping in right direction
//          return ChatsPage();
//        }
//      },
      onHorizontalDragEnd: (DragEndDetails details) =>
          _onHorizontalDrag(details)

      , child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: GestureDetector(
        onScaleUpdate: (one) {
          print(one.scale);
          scale = one.scale;
          setState(() {});
        },
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),


                      child: Transform.scale(
                        scale: scale,

                        child: Center(
                          child: _cameraPreviewWidget(),
                        ),

                      ),

                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: controller != null &&
                            controller.value.isRecordingVideo
                            ? Colors.redAccent
                            : Colors.grey,
                        width: 0.0,
                      ),
                    ),
                  ),
                ),
                _captureControlRowWidget(),
                _toggleAudioWidget(),
                _buildControlBar(),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _cameraTogglesRowWidget(),
                      _thumbnailWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null ||
        !controller.value.isInitialized && cameraon == true) {
      return const Text(
        'Choose a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  /// Toggle recording audio
  Widget _toggleAudioWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Row(
        children: <Widget>[
          const Text(
            'Enable Audio:',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Switch(

            inactiveTrackColor: Colors.greenAccent,
            activeTrackColor: Colors.deepPurpleAccent,
            activeColor: Colors.greenAccent,
            inactiveThumbColor: Colors.deepPurpleAccent,
            value: enableAudio,
            onChanged: (bool value) {
              enableAudio = value;
              if (controller != null) {
                onNewCameraSelected(controller.description);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
//        IconButton( // <-- Flash
//          color: Colors.white,
//          icon: Icon(Icons.flash_auto),
//          onPressed: () {},
//        ),
        FlatButton( // <-- Take picture
          onPressed:
          controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,


          child: Container(
            height: 70.0,
            width: 70.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.greenAccent,
                width: 5.0,
              ),
            ),
          ),
        ),
//        IconButton( // <-- Switch camera
//          color: Colors.white,
//          icon: Icon(Icons.switch_camera),
//          onPressed: () {},
//        ),
      ],
    );
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            videoController == null && imagePath == null
                ? Container()
                : SizedBox(
                    child: (videoController == null)
                        ? Image.file(File(imagePath))
                        : Container(
                            child: Center(
                              child: AspectRatio(
                                  aspectRatio:
                                      videoController.value.size != null
                                          ? videoController.value.aspectRatio
                                          : 1.0,
                                  child: VideoPlayer(videoController)),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.pink)),
                          ),
                    width: 64.0,
                    height: 64.0,
                  ),
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
//        IconButton(
//          icon: const Icon(
//            Icons.camera_alt,
//            color: Colors.yellowAccent,
//          ),
//          color: Colors.blue,
//          onPressed: controller != null &&
//                  controller.value.isInitialized &&
//                  !controller.value.isRecordingVideo
//              ? onTakePictureButtonPressed
//              : null,
//        ),
        IconButton(
          icon: const Icon(
            Icons.videocam,
            color: Colors.white,
          ),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: controller != null && controller.value.isRecordingPaused
              ? Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )
              : Icon(Icons.pause, color: Colors.white),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isRecordingVideo
              ? (controller != null && controller.value.isRecordingPaused
                  ? onResumeButtonPressed
                  : onPauseButtonPressed)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop, color: Colors.white),
          color: Colors.red,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        )
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found', style:
      TextStyle(
        color: Colors.white,
      ),);
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          Theme(
            data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.deepPurple,
                disabledColor: Colors.blue),
            child: SizedBox(
              width: 90.0,
              child: RadioListTile<CameraDescription>(
                activeColor: Colors.purple,
                title: Icon(
                  getCameraLensIcon(cameraDescription.lensDirection,),
                  color: Colors.white,
                ),
                groupValue: controller?.description,
                value: cameraDescription,
                onChanged: controller != null &&
                    controller.value.isRecordingVideo
                    ? null
                    : onNewCameraSelected,
              ),
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) showInSnackBar('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}


//List<CameraDescription> cameras = [];
