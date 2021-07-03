import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final Function onTap;
  final Widget icon;
  final double containerRadius;
  final EdgeInsets padding;
  final Color backColor;
  final Color splashColor;

  const CircularIconButton(
      {Key key,
      this.backColor = Colors.black26,
      this.containerRadius = 36,
      this.icon,
      this.onTap,
      this.padding = const EdgeInsets.all(0),
      this.splashColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: InkWell(
            onTap: onTap,
            child: ClipOval(
                child: Material(
                    color: backColor,
                    child: InkWell(
                      splashColor: backColor == Colors.blue.withOpacity(0.8)
                          ? backColor
                          : splashColor,
                      child: SizedBox(
                          width: containerRadius,
                          height: containerRadius,
                          child: icon),
                      onTap: onTap,
                    )))));
  }
}
