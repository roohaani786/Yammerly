import 'package:flutter/material.dart';

class CameraFilterModel {
  final BlendMode blendMode;
  var gradient;
  CameraFilterModel({this.blendMode, this.gradient});
}

class Filters {
  static List<CameraFilterModel> filterList = [
    // 1st
    CameraFilterModel(
      blendMode: BlendMode.color,
      gradient: LinearGradient(colors: [
        Colors.red,
        Colors.green,
      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    //2nd
    CameraFilterModel(
      blendMode: BlendMode.color,
      gradient: LinearGradient(
        colors: [Colors.grey, Colors.grey],
      ),
    ),
    //add ons
    CameraFilterModel(
      blendMode: BlendMode.difference,
      gradient: LinearGradient(
        colors: [Colors.grey, Colors.grey],
      ),
    ),
    //3rd
    CameraFilterModel(
      blendMode: BlendMode.colorBurn,
      gradient: RadialGradient(
        radius: 1,
        colors: [Colors.transparent, Colors.grey],
      ),
    ),
    //4th
    CameraFilterModel(
      blendMode: BlendMode.colorDodge,
      gradient: RadialGradient(
        radius: 1.3,
        colors: [Colors.black, Colors.blue],
      ),
    ),
    //5th
    CameraFilterModel(
      blendMode: BlendMode.colorDodge,
      gradient: RadialGradient(
        radius: 1,
        colors: [Colors.black, Colors.blueAccent],
      ),
    ),
    //6th
    CameraFilterModel(
      blendMode: BlendMode.color,
      gradient: RadialGradient(
        radius: 1.2,
        colors: [Colors.purple, Colors.blueAccent],
      ),
    ),
    //7th
    CameraFilterModel(
      blendMode: BlendMode.color,
      gradient: RadialGradient(
        radius: 1,
        colors: [Colors.orange, Colors.redAccent],
      ),
    ),
    //8th
    CameraFilterModel(
        blendMode: BlendMode.color,
        gradient: RadialGradient(
          radius: 0.1,
          tileMode: TileMode.repeated,
          colors: [Colors.blue, Colors.purple],
        ))
  ];
}
