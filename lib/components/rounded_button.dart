import 'package:flutter/material.dart';
import 'package:techstagram/constants.dart';

class RoundedButtonX extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;

  const RoundedButtonX({
    Key key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      width: 200.0,
      height: 40.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        // ignore: deprecated_member_use
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          color: color,
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
