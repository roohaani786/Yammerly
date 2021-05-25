import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as ImD;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:techstagram/ComeraV/gallery.dart';
import 'package:techstagram/ComeraV/video_timer.dart';
import 'package:techstagram/main.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/resources/uploadimage.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class CameraScreen extends StatefulWidget {
  final int cam;
  final bool check;

  const CameraScreen({Key key,this.cam,this.check}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState(cam: cam,check: check);
}

class CameraScreenState extends State<CameraScreen>
    with AutomaticKeepAliveClientMixin {

  CameraScreenState({this.cam,this.check});
  CameraController _controller;
  List<CameraDescription> _cameras;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isRecordingMode = false;
  bool _isRecording = false;
  final _timerKey = GlobalKey<VideoTimerState>();
  Map<String, dynamic> _profile;
  bool _loading = false;
  int cam;
  bool check = false;
  AnimationController _flashModeControlRowAnimationController;
  Animation<double> _flashModeControlRowAnimation;
  AnimationController _exposureModeControlRowAnimationController;
  AnimationController _focusModeControlRowAnimationController;
  Animation<double> _exposureModeControlRowAnimation;
  Animation<double> _focusModeControlRowAnimation;




  @override
  void initState() {
    _initCamera();
    super.initState();

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
     // vsync: this,
    );

    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
     // vsync: this,
    );

    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
     //vsync: this,
    );

    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );

    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );

    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    initPlatformState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    bioController = TextEditingController();
    genderController = TextEditingController();
    linkController = TextEditingController();
    photoUrlController = TextEditingController();
    displayNameController = TextEditingController();
    workController = TextEditingController();
    educationController = TextEditingController();
    currentCityController = TextEditingController();
    homeTownController = TextEditingController();
    relationshipController = TextEditingController();
    pincodeController = TextEditingController();

    uidController = TextEditingController();
    fetchProfileData();
  }

  DocumentSnapshot docSnap;

  fetchProfileData() async {
    currUser =  FirebaseAuth.instance.currentUser;
    try {
      docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();

      firstNameController.text = docSnap["fname"];
      lastNameController.text = docSnap["surname"];
      phoneNumberController.text = docSnap["phonenumber"];
      emailController.text = docSnap["email"];
      bioController.text = docSnap["bio"];
      genderController.text = docSnap["gender"];
      linkController.text = docSnap["link"];
      photoUrlController.text = docSnap["photoURL"];
      displayNameController.text = docSnap["displayName"];
      workController.text = docSnap["work"];
      educationController.text = docSnap["education"];
      currentCityController.text = docSnap["currentCity"];
      homeTownController.text = docSnap["homeTown"];
      relationshipController.text = docSnap["relationship"];
      pincodeController.text = docSnap["pincode"];

      uidController.text = docSnap["uid"];

      setState(() {
//        isLoading = false;
//        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  initPlatformState() async {
//    bool hasFlash = await Lamp.hasLamp;
//    print("Device has flash ? $hasFlash");
//    setState(() { _hasFlash = hasFlash; });
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[cam], ResolutionPreset.veryHigh);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller?.dispose();
    super.dispose();
  }

//   void _onHorizontalDrag(DragEndDetails details,context) {
//     if (details.primaryVelocity == 0)
//       // user have just tapped on screen (no dragging)
//       return;
//
//     if (details.primaryVelocity.compareTo(0) == -1) {
//       dispose();
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage(initialindexg: 0)),
//       );
//
//
//     }
// //     else {
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(builder: (context) => CameraScreen()),
// //       );
// // //      Navigator.push(
// // //          context,
// // //          MaterialPageRoute(
// // //              builder: (BuildContext context) => HomePage())).then((res) {
// // //        setState(() {
// // //          cameraon = true;
// // //        });
// // //      }
// // //      );
// //     }
//   }

  bool flashOn=false;
  PickedFile _image;
  User currUser;

  TextEditingController firstNameController,
      lastNameController,
      emailController,
      phoneNumberController,uidController,
      bioController,genderController,linkController,photoUrlController,
      displayNameController,workController,educationController,
      currentCityController,homeTownController,relationshipController,pincodeController ;
  bool upload = false;
  Future pickImage() async {
    // ignore: deprecated_member_use
    await ImagePicker().getImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
        upload = true;
      });
    });

    if (_image != null){
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UploadImage(file: File(_image.path)),));
    }else{
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraScreen(cam: cam,),));
    }
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => UploadImage(file: _image,)),
//    );
    print("Done..");
  }
  String url;

  controlUploadAndSave() async {
    setState(() {
//      uploading = true;
    });

    await compressPhoto();

    String downloadUrl = await uploadPhoto(_image);
    savePostInfoToFirestore(downloadUrl);

    setState(() {
      // file = null;
//      uploading = false;
      postId = Uuid().v4();
    });
    Navigator.pop(context);
  }
  final Reference storageReference =
  FirebaseStorage.instance.ref().child("Post Pictures");

  Future<String> uploadPhoto(mImageFile) async {
    UploadTask mStorageUploadTask =
    storageReference.child("post_$postId.jpg").putFile(mImageFile);
    TaskSnapshot storageTaskSnapshot =
    await mStorageUploadTask.whenComplete(() => null);
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  String postId = Uuid().v4();

  final postReference = FirebaseFirestore.instance.collection("posts");

  savePostInfoToFirestore(String url) {
    postReference.doc(postId).set({
      "postId": postId,
      "uid" : uidController.text,
      "displayName": displayNameController.text,
      "timestamp": Timestamp.now(),
      "email": emailController.text,
      "photoURL" :photoUrlController.text,
//      "email": widget.userData.email,
//      "description": descriptionController.text,
      "likes": 0,
      "url": url,
//      "photourl": widget.userData.photoUrl,
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(initialindexg: 2)),
    );
  }

  compressPhoto() async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    ImD.Image mImageFile = ImD.decodeImage(await _image.readAsBytes());
    final compressedImage = File('$path/img_$uidController.jpg')
      ..writeAsBytesSync(
        ImD.encodeJpg(mImageFile, quality: 60),
      );
    setState(() {
      _image = PickedFile(compressedImage.path);
    });
  }




  @override
  Widget build(BuildContext context) {

    super.build(context);
    if (_controller != null) {
      if (!_controller.value.isInitialized) {
        return Container();
      }
    } else {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(),
        ),
      );
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

    if (!_controller.value.isInitialized) {
      return Container();
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onDoubleTap: (){
          _onCameraSwitch();
        },
        child: Scaffold(

          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          extendBody: true,
          body: Stack(
            children: <Widget>[


              _buildCameraPreview(),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                    //Navigator.pushNamed(context, '/HomePage');
                    //Navigator.of(context, rootNavigator: true).pop(context);
                    //Navigator.of(context).maybePop();
                    // if(check == true){
                    //   Navigator.pop(context);
                    // }else{
                    //   showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return AlertDialog(
                    //           backgroundColor: Colors.white,
                    //           title: Text("Note"),
                    //           content: Text(
                    //               "Please left swipe for back",
                    //               style: TextStyle(
                    //                   color: Colors.deepPurple
                    //               )),
                    //         );
                    //       });
                    // }
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: IconButton(
                    icon: Icon(
                      (flashOn) ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        flashOn = !flashOn;
                      });
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





              if (_isRecordingMode)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 32.0,
                  child: VideoTimer(
                    key: _timerKey,
                  ),
                ),

            ],
          ),

          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    return ClipRect(
      child: Container(
        child: Transform.scale(
          scale: _controller.value.aspectRatio / size.aspectRatio,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.transparent,
      height: 100.0,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[

              IconButton(

                  icon: Icon(FontAwesomeIcons.photoVideo,
                    color: Colors.white60,), onPressed:
                  (){
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => pickImage(),));
                pickImage();
                if (upload == true){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UploadImage(file: File(_image.path),)));
                }else{
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          cam: 0,
                        ),
                      ));
                }
              }

              ),

              // ignore: deprecated_member_use
              FlatButton(
                color: Colors.transparent,
                onPressed: () async => null,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 28.0,
                  child: IconButton(
                    highlightColor: Colors.transparent,
                    icon: Icon(
                      (_isRecordingMode)
                          ? (_isRecording) ? Icons.stop : Icons.videocam
                          : Icons.camera_alt,
                      size: 28.0,
                      color: (_isRecording) ? Colors.red : Colors.black,
                    ),
                    onPressed: () {
                      print("$_isRecordingMode");

                      if (!_isRecordingMode) {
                        // print("alam");
                        // print(cam);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => Gallery(filePath: currentCityController.text,cam:cam),
                        //   ),
                        // );
                        _captureImage();
                        if (flashOn) {
                          print("dhjfh");
                        }
                      } else {
                        if (_isRecording) {
                          stopVideoRecording();
                        } else {
                          startVideoRecording();
                        }
                      }
                    },
                  ),

                ),
              ),
              IconButton(
                // icon: Icon(
                //   Icons.camera_alt,color: Colors.transparent,
                // ),
                // onPressed: (){},
                icon: Icon(
                  (_isRecordingMode) ? Icons.camera_alt : Icons.videocam,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isRecordingMode = !_isRecordingMode;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

//  Future _turnFlash() async {
//    bool hasTorch = await Torch.hasTorch;
//    if(hasTorch){
//      (flashOn || cam!=null) ? Torch.turnOn() : Torch.turnOff();
//      var f = await Torch.hasTorch;
//      Torch.flash(Duration(milliseconds: 300));
//      setState((){
//        _hasFlash = f;
//        //flashOn = !flashOn;
//      });
//    }
//  }

  Future<FileSystemEntity> getLastImage() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    final myDir = Directory(dirPath);
    List<FileSystemEntity> _images;
    _images = myDir.listSync(recursive: true, followLinks: false);
    _images.sort((a, b) {
      return b.path.compareTo(a.path);
    });
    var lastFile = _images[0];
    var extension = path.extension(lastFile.path);
    if (extension == '.jpeg') {
      return lastFile;
    } else {
//      String thumb = await Thumbnails.getThumbnail(
//          videoFile: lastFile.path, imageType: ThumbFormat.PNG, quality: 100);
//      return File(thumb);
      print("dfdf");
    }
  }

  Future<void> _onCameraSwitch() async {
    //final CameraDescription cameraDescription =
    if(cam == 0){
      setState(() {
        cam = 1;
      });
    }else if(cam == 1){
      setState(() {
        cam = 0;
      });
    }

    final CameraDescription cameraDescription = _cameras[cam];
    //(_controller.description == _cameras[0]) ? _cameras[1] : _cameras[0];
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.ultraHigh);
    _controller.addListener(() {
      if (mounted) setState(() {

      });
      if (_controller.value.hasError) {
        showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _captureImage() async {
    print('_captureImage');
    print('${_controller.value.isInitialized}');

    if (_controller.value.isInitialized) {
      SystemSound.play(SystemSoundType.click);
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/media';
      await Directory(dirPath).create(recursive: true);
      String filePath = '$dirPath/${_timestamp()}.jpeg';
      print('path: $filePath');


      // Attempt to take a picture and log where it's been saved.
      XFile halua = await _controller.takePicture();
      setState(() {});
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Gallery(filePath: halua,cam: cam,)),
      );
    }
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

  Future<String> startVideoRecording() async {
    print('startVideoRecording');
    if (!_controller.value.isInitialized) {
      return null;
    }
    setState(() {
      _isRecording = true;
    });
    _timerKey.currentState.startTimer();

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_timestamp()}.mp4';

    if (_controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
//      videoPath = filePath;
      //await _controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return null;
    }
    _timerKey.currentState.stopTimer();
    setState(() {
      _isRecording = false;
    });

    try {
      await _controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  @override
  bool get wantKeepAlive => true;
}

class GalleryItemThumbnail extends StatelessWidget {
  GalleryItemThumbnail({
    this.heroId,
    this.resource,
    this.onTap,
    this.height,
    this.margin,
  });

  final String heroId;
  final double height;
  final String resource;
  final GestureTapCallback onTap;
  final margin;

  @override
  Widget build(BuildContext context) {
    //print('gallery: img-$id');
    return Container(
      margin: margin,
      color: Color.fromRGBO(255, 255, 255, 0.05),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: Hero(
              tag: heroId,
              child: Image.file(
                new File(resource),
                width: height,
                height: height,
                cacheWidth: height.ceil(),
                cacheHeight: height.ceil(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}