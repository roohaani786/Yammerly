import 'package:flutter/material.dart';

class CameraFilterModel {
  final BlendMode blendMode;
  var gradient;
  CameraFilterModel({this.blendMode, this.gradient});
}

class Filters {
  static List<CameraFilterModel> filterList = [
    CameraFilterModel(
      blendMode: BlendMode.color,
      gradient: LinearGradient(colors: [
        Colors.red,
        Colors.green,
      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
  ];
}
