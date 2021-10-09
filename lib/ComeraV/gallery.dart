import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:techstagram/ComeraV/Camera.dart';
import 'package:techstagram/resources/uploadimage.dart';
import 'package:image/image.dart' as imageLib;
import 'package:techstagram/status/model/status_model.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:video_player/video_player.dart';

class Gallery extends StatefulWidget {
  Gallery({this.filePath, this.cam});

  final XFile filePath;
  final int cam;

  @override
  _GalleryState createState() => _GalleryState(filePath, cam);
}

class _GalleryState extends State<Gallery> {
  XFile currentFilePath;
  // XFile filePath;
  File _selectedFile;
  int cam;
  File image;
  bool _inProcess = false;
  CameraController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  XFile imageFile;
  XFile videoFile;
  VideoPlayerController videoController;

  _GalleryState(this.currentFilePath, this.cam);

  int indexd;

  @override
  void initState() {
    cropImage(File(currentFilePath.path));
    super.initState();
  }

  Future<bool> _onWillPop() async {
    print('pop-');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Discard  ?"),
            content: Text("If you go back now, you will lose your post.",
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
                        _deleteFile();
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

  Future imageFilter(context) async {
    if (_selectedFile != null) {
      File imageFile = _selectedFile;
      String fileName = path.basename(imageFile.path);
      var image = imageLib.decodeImage(await imageFile.readAsBytes());
      image = imageLib.copyResize(image, width: 600);
      Map imagefile = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
            title: Text("Photo Filter"),
            appBarColor: Colors.deepPurple,
            image: image,
            filters: presetFiltersList,
            filename: fileName,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );

      if (imagefile != null && imagefile.containsKey('image_filtered')) {
        setState(() {
          _selectedFile = imagefile['image_filtered'];
        });
      }
    } else
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PLease crop the image first!')));
  }

  cropImage(File file) async {
    if (_selectedFile == null) {
      this.setState(() {
        _inProcess = true;
      });
      if (file != null) {
        File cropped = await ImageCropper.cropImage(
            sourcePath: file.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 700,
            maxHeight: 700,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.white,
              toolbarTitle: "Yammerly Cropper",
              activeControlsWidgetColor: Colors.purple,
              toolbarWidgetColor: Colors.deepPurple,
              statusBarColor: Colors.purple,
              backgroundColor: Colors.white,
              showCropGrid: false,
              dimmedLayerColor: Colors.black54,
            ));

        this.setState(() {
          _selectedFile = cropped;
          _inProcess = false;
        });
      } else {
        this.setState(() {
          _inProcess = false;
        });
      }
    }
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
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

  getImage(File file) async {
    cropImage(File(currentFilePath.path));
    print("home feed");
    print(_selectedFile);
    if (_selectedFile != null)
      print("in if condition");
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => UploadImage(
              file: _selectedFile, shared: false, isVideo: false)),
    );
    print("afeter if");
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => UploadImage(
      //           file: _selectedFile, shared: false, isVideo: false)),
      // );
  }

  void onTakePictureButtonPressed(context,file) {
    print("camera start 2");
    Alert(
      closeFunction: () {
        Navigator.of(context).pop();
        setState(() {});
      },
      context: context,
      title: 'Select Photo',
      buttons: [
        DialogButton(
            color: Colors.deepPurple[400],
            child: Text(
              'Upload Photo on home feed',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              print("photo upload");
              // uploadFile();
              // Get.to(Gallery(filePath: file, cam: cam,));
              getImage(File(file.path));
              // takePicture().then((XFile file) {
              //   if (mounted) {
              //     setState(() {
              //       imageFile = file;
              //       videoController?.dispose();
              //       videoController = null;
              //     });
              //     if (file != null)
              //       // onTakePictureButtonPressed(context,file);
              //
              //       // Navigator.push(
              //       //   context,
              //       //   MaterialPageRoute(
              //       //       builder: (context) =>
              //       //           Gallery(
              //       //             filePath: file,
              //       //             cam: cam,
              //       //           )),
              //       // );
              //   }
              // });
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => Gallery(
              //         filePath: file,
              //         cam: cam,
              //       )),
              // );
              //showInSnackBar('Picture saved to ${file.path}');
              print("after photo upload");
              Navigator.of(context).pop();
              setState(() {});

            }),
        DialogButton(
            color: Colors.deepPurple[400],
            child: Text(
              'Upload Photo in status',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              uploadFile(File(file.path),context);

              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(initialindexg: 0)),
              );
              setState(() {});
            })
      ],
    ).show();

  }

  Future uploadFile(File file,context) async {
    getCurrentUser();
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("Story")
        .child(uid)
        .child(DateTime.now().toString());

    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;

    urlDownload = await taskSnapshot.ref.getDownloadURL();

    final Status status =
    Status(data: urlDownload, type: StatusType.image, caption: '');
    status.addMediaStatus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yay! Status Upload successfully!')));
  }

  String uid;
  User currUser = FirebaseAuth.instance.currentUser;
  String urlDownload;
  getCurrentUser() async {
    var docSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser.uid)
        .get();
    uid = docSnap["uid"];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        child: Scaffold(
          body: Container(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.height,
                  child: (cam == 1)
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: (_selectedFile != null)
                              ? Image.file(
                                  _selectedFile,
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.contain,
                                )
                              : Image.file(File(currentFilePath.path),
                                  fit: BoxFit.cover),
                        )
                      : (_selectedFile != null)
                          ? Image.file(
                              _selectedFile,
                              width: 250,
                              height: 250,
                              fit: BoxFit.contain,
                            )
                          : Image.file(
                              File(currentFilePath.path),
                              fit: BoxFit.cover,
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, left: 6.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey.shade400,
                        size: 30.0,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text("Discard post ?"),
                                content: Text(
                                    "If you go back now, you will loose your post.",
                                    style: TextStyle(color: Colors.deepPurple)),
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
                                            _deleteFile();
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
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: IconButton(
                                onPressed: () {
                                  imageFilter(context);
                                },
                                icon: Icon(
                                  Icons.filter,
                                  size: 18,
                                  color: Colors.white,
                                ))),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            onTakePictureButtonPressed(context,File(currentFilePath.path));
                            // getImage(File(currentFilePath.path));
                          },
                          child:
                              Text((_selectedFile != null) ? 'Post' : 'Crop'),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.deepPurple)),
                        )
                      ],
                    ),
                  ),
                ),
                (_inProcess)
                    ? Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height * 0.95,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Center()
              ],
            ),
          ),
        ),
      ),
    );
  }

//  _shareFile() async {
//    var extension = path.extension(currentFilePath);
//    await Share.file(
//      'image',
//      (extension == '.jpeg') ? 'image.jpeg' : '	video.mp4',
//      File(currentFilePath).readAsBytesSync(),
//      (extension == '.jpeg') ? 'image/jpeg' : '	video/mp4',
//    );
//  }

  _deleteFile() {
    final dir = Directory(currentFilePath.path);
//    dir.deleteSync(recursive: true);
    print('deleted');
    setState(() {});
  }

//  Future uploadFile() async {
//
//    StorageReference storageReference = FirebaseStorage.instance
//        .ref()
//        .child('posts/${Path.basename(currentFilePath)}}');
//    StorageUploadTask uploadTask = storageReference.putFile(File(currentFilePath));
//    await uploadTask.onComplete;
//    print('File Uploaded');
//    storageReference.getDownloadURL().then((fileURL) {
//      setState(() {
//        currentFilePath = fileURL;
//      });
//    });
//  }

//  Future<List<FileSystemEntity>> _getAllImages() async {
//    final Directory extDir = await getApplicationDocumentsDirectory();
//    final String dirPath = '${extDir.path}/media';
//    final myDir = Directory(dirPath);
//    List<FileSystemEntity> _images;
//    _images = myDir.listSync(recursive: true, followLinks: false);
//    _images.sort((a, b) {
//      return b.path.compareTo(a.path);
//    });
//    return _images;
//  }
//}
}
