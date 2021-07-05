// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:techstagram/ComeraV/gallery.dart';
import 'package:techstagram/ComeraV/video_preview.dart';
import 'package:techstagram/resources/uploadimage.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:video_player/video_player.dart';

class CameraExampleHome extends StatefulWidget {
  final int cam;
  final bool check;

  const CameraExampleHome({Key key, this.cam, this.check}) : super(key: key);
  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState(cam: cam, check: check);
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
    with WidgetsBindingObserver, TickerProviderStateMixin {
  _CameraExampleHomeState({this.cam, this.check});
  CameraController controller;
  bool check = false;
  XFile imageFile;
  XFile videoFile;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  AnimationController _flashModeControlRowAnimationController;
  Animation<double> _flashModeControlRowAnimation;
  AnimationController _exposureModeControlRowAnimationController;
  Animation<double> _exposureModeControlRowAnimation;
  AnimationController _focusModeControlRowAnimationController;
  Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom;
  double _maxAvailableZoom;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  List<CameraDescription> _cameras;
  final Dependencies dependencies = new Dependencies();
  final Stopwatch stopwatch = new Stopwatch();
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  Duration maxVideoDuration = Duration(seconds: 31),
      pausedVideoDuration = Duration(seconds: 0);

  void leftButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        print("${dependencies.stopwatch.elapsedMilliseconds}");
      } else {
        dependencies.stopwatch.reset();
      }
    });
  }

  void rightButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
        dependencies.stopwatch.start();
      }
    });
  }

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    _initCamera();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  int cam = 0;
  Future<void> _onCameraSwitch() async {
    //final CameraDescription cameraDescription =
    //switching camera
    if (cam == 0) {
      setState(() {
        cam = 1;
      });
    } else if (cam == 1) {
      setState(() {
        cam = 0;
      });
    }

    final CameraDescription cameraDescription = _cameras[cam];
    //(_controller.description == _cameras[0]) ? _cameras[1] : _cameras[0];
    if (controller != null) {
      await controller.dispose();
    }
    controller =
        CameraController(cameraDescription, ResolutionPreset.ultraHigh);
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

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[cam], ResolutionPreset.veryHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
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

  Future<bool> _onWillPop() {
    //Navigator.pop(context);
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return HomePage(initialindexg: 1);
        },
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool timeronpress = false;
  bool flash = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          // appBar: AppBar(
          //   title: const Text('Camera example'),
          // ),
          body: GestureDetector(
            onDoubleTap: () {
              _onCameraSwitch();
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Stack(
                        children: [
                          _cameraPreviewWidget(),
                          Positioned(
                            top: 24.0,
                            left: 12.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.switch_camera,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _onCameraSwitch();
                              },
                            ),
                          ),
                          Positioned(
                            top: 24.0,
                            right: 12.0,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Navigator.pop(context,
                                //   MaterialPageRoute(builder: (context) => HomePage()),);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          (timeronpress)
                              ? Positioned(
                                  bottom: 80.0,
                                  right: 165.0,
                                  child: TimerText(dependencies: dependencies),
                                )
                              : Container(),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 24.0),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: IconButton(
                                    icon: Icon(
                                      // (flashOn) ? Icons.flash_on : Icons.flash_off,
                                      Icons.flash_on,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // setState(() {
                                      //   flashOn = !flashOn;
                                      // });
                                      onFlashModeButtonPressed();

                                      // setState(() {
                                      //   flashOn = !flashOn;
                                      // });
                                      // if (!flashOn) {
                                      //   //Lamp.turnOff();
                                      //   TorchCompat.turnOff();
                                      // } else {
                                      //   TorchCompat.turnOn();
                                      //   //Lamp.turnOn();
                                      // }
                                    },
                                    //onPressed: () => TorchCompat.turnOff(),
                                  ),
                                ),
                              ),
                              _modeControlRowWidget(),
                            ],
                          ),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: _captureControlRowWidget()),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      // border: Border.all(
                      //   color: controller != null && controller.value.isRecordingVideo
                      //       ? Colors.redAccent
                      //       : Colors.grey,
                      //   width: 3.0,
                      // ),
                    ),
                  ),
                ),
                //_captureControlRowWidget(),

                // Padding(
                //   padding: const EdgeInsets.all(5.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: <Widget>[
                //       _cameraTogglesRowWidget(),
                //       _thumbnailWidget(),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final aspectRatio = 3 / 4;
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        '',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: Container(
          child: Center(
            child: ShaderMask(
              blendMode: BlendMode.color,
              shaderCallback: (rect) => LinearGradient(
                      colors: [Colors.red, Colors.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)
                  .createShader(rect),
              child: CameraPreview(
                controller,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onTapDown: (details) =>
                        onViewFinderTap(details, constraints),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  // Widget _thumbnailWidget() {
  //   return Expanded(
  //     child: Align(
  //       alignment: Alignment.centerRight,
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           videoController == null && imageFile == null
  //               ? Container()
  //               : SizedBox(
  //             child: (videoController == null)
  //                 ? Image.file(File(imageFile.path))
  //                 : Container(
  //               child: Center(
  //                 child: AspectRatio(
  //                     aspectRatio:
  //                     videoController.value.size != null
  //                         ? videoController.value.aspectRatio
  //                         : 1.0,
  //                     child: VideoPlayer(videoController)),
  //               ),
  //               decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.pink)),
  //             ),
  //             width: 64.0,
  //             height: 64.0,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  /// Display a bar with buttons to change the flash and exposure modes
  Widget _modeControlRowWidget() {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   mainAxisSize: MainAxisSize.max,
        //   children: <Widget>[
        //     IconButton(
        //       icon: Icon(Icons.flash_on),
        //       color: Colors.blue,
        //       onPressed: controller != null ? onFlashModeButtonPressed : null,
        //     ),
        //     IconButton(
        //       icon: Icon(Icons.exposure),
        //       color: Colors.blue,
        //       onPressed:
        //       controller != null ? onExposureModeButtonPressed : null,
        //     ),
        //     IconButton(
        //       icon: Icon(Icons.filter_center_focus),
        //       color: Colors.blue,
        //       onPressed: controller != null ? onFocusModeButtonPressed : null,
        //     ),
        //     IconButton(
        //       icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
        //       color: Colors.blue,
        //       onPressed: controller != null ? onAudioModeButtonPressed : null,
        //     ),
        //     IconButton(
        //       icon: Icon(controller?.value?.isCaptureOrientationLocked ?? false
        //           ? Icons.screen_lock_rotation
        //           : Icons.screen_rotation),
        //       color: Colors.blue,
        //       onPressed: controller != null
        //           ? onCaptureOrientationLockButtonPressed
        //           : null,
        //     ),
        //   ],
        // ),
        _flashModeControlRowWidget(),
        _exposureModeControlRowWidget(),
        _focusModeControlRowWidget(),
      ],
    );
  }

  Widget _flashModeControlRowWidget() {
    {
      return SizeTransition(
        sizeFactor: _flashModeControlRowAnimation,
        child: ClipRect(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(
                icon: Icon(Icons.flash_off),
                color: controller?.value?.flashMode == FlashMode.off
                    ? Colors.orange
                    : Colors.white,
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.off)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.flash_auto),
                color: controller?.value?.flashMode == FlashMode.auto
                    ? Colors.orange
                    : Colors.white,
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.flash_on),
                color: controller?.value?.flashMode == FlashMode.always
                    ? Colors.orange
                    : Colors.white,
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.always)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.highlight),
                color: controller?.value?.flashMode == FlashMode.torch
                    ? Colors.orange
                    : Colors.white,
                onPressed: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                    : null,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _exposureModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value?.exposureMode == ExposureMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value?.exposureMode == ExposureMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Exposure Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) controller.setExposurePoint(null);
                      showInSnackBar('Resetting exposure point');
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.locked)
                        : null,
                  ),
                ],
              ),
              Center(
                child: Text("Exposure Offset"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(_minAvailableExposureOffset.toString()),
                  Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    onChanged: _minAvailableExposureOffset ==
                            _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                  ),
                  Text(_maxAvailableExposureOffset.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value?.focusMode == FocusMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value?.focusMode == FocusMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _focusModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Focus Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) controller.setFocusPoint(null);
                      showInSnackBar('Resetting focus point');
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  File _image;
  bool upload = false;
  Future pickImage() async {
    await ImagePicker().getImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = File(image.path);
        upload = true;
      });
    });

    if (_image != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UploadImage(file: _image, shared: false, isVideo: false),
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraExampleHome(
              cam: cam,
            ),
          ));
    }
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => UploadImage(file: _image,)),
//    );
    print("Done..");
  }

  bool _isRecordingMode = false;
  bool _isRecording = false;

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // FlatButton(
          //   color: Colors.transparent,
          //   onPressed: () async => null,
          //   child: CircleAvatar(
          //     backgroundColor: Colors.white,
          //     radius: 28.0,
          //     child: IconButton(
          //       highlightColor: Colors.transparent,
          //       icon: Icon(
          //         (_isRecordingMode)
          //             ? (_isRecording) ? Icons.stop : Icons.videocam
          //             : Icons.camera_alt,
          //         size: 28.0,
          //         color: (_isRecording) ? Colors.red : Colors.black,
          //       ),
          //       onPressed: () {
          //         print("$_isRecordingMode");
          //
          //         if (!_isRecordingMode) {
          //           (controller != null &&
          //               controller.value.isInitialized &&
          //               !controller.value.isRecordingVideo)
          //               ? onTakePictureButtonPressed
          //               : null;
          //           print("camera start");
          //         } else {
          //           if (_isRecording) {
          //             (controller != null &&
          //                 controller.value.isInitialized &&
          //                 controller.value.isRecordingVideo)
          //                 ? onStopButtonPressed
          //                 : null;
          //             print("video stop");
          //           } else {
          //             (controller != null &&
          //                 controller.value.isInitialized &&
          //                 !controller.value.isRecordingVideo)
          //                 ? onVideoRecordButtonPressed
          //                 : null;
          //               print("video start");
          //           }
          //         }
          //       },
          //     ),
          //
          //   ),
          // ),

          (!_isRecordingMode)
              ? CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 28.0,
                  //camera button
                  child: GestureDetector(
                    onLongPressStart: (details) async {
                      onVideoRecordButtonPressed();
                      setState(() {
                        _isRecording = true;
                        timeronpress = true;
                        (controller?.value?.flashMode == FlashMode.auto)
                            ? onSetFlashModeButtonPressed(FlashMode.auto)
                            : (controller?.value?.flashMode == FlashMode.torch)
                                ? onSetFlashModeButtonPressed(FlashMode.torch)
                                : onSetFlashModeButtonPressed(FlashMode.off);
                      });
                    },
                    onLongPressEnd: (details) async {
                      onStopButtonPressed();
                      setState(() {
                        _isRecording = false;
                        timeronpress = false;
                      });
                    },
                    child: IconButton(
                      icon: _isRecording
                          ? Icon(
                              Icons.radio_button_on,
                              color: Colors.red.shade400,
                            )
                          : Icon(Icons.camera_alt),
                      color: Colors.black,
                      onPressed: controller != null &&
                              controller.value.isInitialized &&
                              !controller.value.isRecordingVideo
                          ? onTakePictureButtonPressed
                          : null,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                        height: 20.0,
                        child: TimerText(dependencies: dependencies)),
                    Row(
                      children: [
                        //when recording button pressed this single button appears when clicked recording starts

                        IconButton(
                          icon: const Icon(Icons.videocam),
                          color: Colors.white,
                          onPressed: controller != null &&
                                  controller.value.isInitialized &&
                                  !controller.value.isRecordingVideo
                              ? onVideoRecordButtonPressed
                              : null,
                        ),

                        GestureDetector(
                          onTap: () {
                            // rightButtonPressed();
                            //   dependencies.stopwatch.stop();

                            setState(() {
                              dependencies.stopwatch.stop();
                            });
                          },
                          child: IconButton(
                            icon: controller != null &&
                                    controller.value.isRecordingPaused
                                ? Icon(Icons.play_arrow)
                                : Icon(Icons.pause),
                            color: Colors.white,
                            onPressed: controller != null &&
                                    controller.value.isInitialized &&
                                    controller.value.isRecordingVideo
                                ? (controller != null &&
                                        controller.value.isRecordingPaused
                                    ? onResumeButtonPressed
                                    : onPauseButtonPressed)
                                : null,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            dependencies.stopwatch.stop();
                          },
                          child: IconButton(
                            icon: const Icon(Icons.stop),
                            color: Colors.red,
                            onPressed: controller != null &&
                                    controller.value.isInitialized &&
                                    controller.value.isRecordingVideo
                                ? onStopButtonPressed
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

          // IconButton(
          //   // icon: Icon(
          //   //   Icons.camera_alt,color: Colors.transparent,
          //   // ),
          //   // onPressed: (){},
          //   icon: Icon(
          //     (_isRecordingMode) ? Icons.camera_alt : Icons.videocam,
          //     color: Colors.white,
          //     size: 30,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _isRecordingMode = !_isRecordingMode;
          //     });
          //
          //     if (_isRecordingMode) {
          //       print("video");
          //       controller != null &&
          //               controller.value.isInitialized &&
          //               !controller.value.isRecordingVideo
          //           //camera or video one at a time
          //           ? print("recording abhi chalu nhi hui hai")
          //           //  ? onVideoRecordButtonPressed()
          //           : print("nahi gaya");
          //
          //     } else {
          //       stopVideoRecording();
          //       dependencies.stopwatch.reset();
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => CameraExampleHome(
          //                   cam: cam,
          //                 )),
          //       );
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  // Widget _cameraTogglesRowWidget() {
  //   final List<Widget> toggles = <Widget>[];
  //
  //   if (cameras.isEmpty) {
  //     return const Text('No camera found');
  //   } else {
  //     for (CameraDescription cameraDescription in cameras) {
  //       toggles.add(
  //         SizedBox(
  //           width: 90.0,
  //           child: RadioListTile<CameraDescription>(
  //             title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
  //             groupValue: controller?.description,
  //             value: cameraDescription,
  //             onChanged: controller != null && controller.value.isRecordingVideo
  //                 ? null
  //                 : onNewCameraSelected,
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //
  //   return Row(children: toggles);
  // }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller.setExposurePoint(offset);
    controller.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
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
      await Future.wait([
        controller
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        controller
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        controller.getMaxZoomLevel().then((value) => _maxAvailableZoom = value),
        controller.getMinZoomLevel().then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    print("camera start 2");
    takePicture().then((XFile file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        if (file != null)
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Gallery(
                      filePath: file,
                      cam: cam,
                    )),
          );
        //showInSnackBar('Picture saved to ${file.path}');
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller.description);
    }
  }

  void onCaptureOrientationLockButtonPressed() async {
    if (controller != null) {
      if (controller.value.isCaptureOrientationLocked) {
        await controller.unlockCaptureOrientation();
        showInSnackBar('Capture orientation unlocked');
      } else {
        await controller.lockCaptureOrientation();
        showInSnackBar(
            'Capture orientation locked to ${controller.value.lockedCaptureOrientation.toString().split('.').last}');
      }
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
      //showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        rightButtonPressed();
      });
    });
    print("videoo");
    startVideoRecording().then((_) {
      maxVideoDuration = Duration(seconds: 31);
      Timer(maxVideoDuration, () {
        print("timer chalu");
        (controller != null &&
                controller.value.isInitialized &&
                controller.value.isRecordingVideo &&
                !controller.value.isRecordingPaused)
            ? onStopButtonPressed()
            : null;
      });
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() {
    print("recording band hogyi ");
    stopVideoRecording().then((file) {
      if (mounted && file != null)
        setState(() {
          videoFile = file;
          String vf = file.path;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPreview(videoPath: vf, cam: cam)),
          );
        });
    });
  }

  void onPauseButtonPressed() {
    print("pause hui");
    pauseVideoRecording().then((_) {
      if (mounted)
        setState(() {
          dependencies.stopwatch.stop();
          pausedVideoDuration = Duration(
              milliseconds: dependencies.stopwatch.elapsedMilliseconds);
          print(pausedVideoDuration);
        });
      //   showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    print("resume hui hui");
    resumeVideoRecording().then((_) {
      if (mounted)
        setState(() {
          dependencies.stopwatch.start();
          maxVideoDuration -= pausedVideoDuration;
          Timer(maxVideoDuration, () {
            print("timer chalu");
            (controller != null &&
                    controller.value.isInitialized &&
                    controller.value.isRecordingVideo &&
                    !controller.value.isRecordingPaused)
                ? onStopButtonPressed()
                : null;
          });
        });
      // showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    print("bhai bhaaaa");
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (controller.value.isRecordingVideo) {
      //A recording is already started, do nothing.
      return;
    }

    try {
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile> stopVideoRecording() async {
    print("stop me aaya");
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      return controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
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

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    try {
      await controller.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    try {
      await controller.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vController =
        VideoPlayerController.file(File(videoFile.path));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vController.addListener(videoPlayerListener);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  Future<XFile> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await controller.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class CameraApp extends StatelessWidget {
  final int cam;
  final bool check;
  const CameraApp({Key key, this.cam, this.check}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraExampleHome(cam: cam, check: check),
    );
  }
}

// List<CameraDescription> cameras = [];
//
// Future<void> main() async {
//   // Fetch the available cameras before initializing the app.
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//     cameras = await availableCameras();
//   } on CameraException catch (e) {
//     logError(e.code, e.description);
//   }
//   runApp(CameraApp());
// }

//timer thing is start from here

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle = const TextStyle(
      color: Colors.white, fontSize: 15.0, fontFamily: "Bebas Neue");
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class TimerText extends StatefulWidget {
  TimerText({this.dependencies});
  final Dependencies dependencies;

  TimerTextState createState() =>
      new TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies});
  final Dependencies dependencies;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = new Timer.periodic(
        new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate),
        callback);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RepaintBoundary(
          child: new SizedBox(
            height: 20.0,
            child: new MinutesAndSeconds(dependencies: dependencies),
          ),
        ),
        new RepaintBoundary(
          child: new SizedBox(
            height: 20.0,
            child: new Hundreds(dependencies: dependencies),
          ),
        ),
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.dependencies});
  final Dependencies dependencies;

  MinutesAndSecondsState createState() =>
      new MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({this.dependencies});
  final Dependencies dependencies;

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return new Text('$minutesStr:$secondsStr.', style: dependencies.textStyle);
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({this.dependencies});
  final Dependencies dependencies;

  HundredsState createState() => new HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({this.dependencies});
  final Dependencies dependencies;

  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hundreds != hundreds) {
      setState(() {
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return new Text(hundredsStr, style: dependencies.textStyle);
  }
}
