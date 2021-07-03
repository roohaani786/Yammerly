// import 'package:flutter/material.dart';
// import 'package:techstagram/ComeraV/camera_screen.dart';
//
// const Color barColor = const Color(0x20000000);
//
//
// class CameraS extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Camera',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         //brightness: Brightness.dark,
//         backgroundColor: Colors.black,
//         bottomAppBarColor: barColor,
//       ),
//       home: CameraClass(),
//     );
//   }
// }
//
// class CameraClass extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
//
//
// class _HomePageState extends State<CameraClass> {
//   final _cameraKey = GlobalKey<CameraScreenState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         extendBody: true,
//         backgroundColor: Theme.of(context).backgroundColor,
//         body: CameraScreen(
//           cam: 0,
//           key: _cameraKey,
//         ),
//       ),
//     );
//   }
// }
