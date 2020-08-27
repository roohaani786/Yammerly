import 'package:flutter/material.dart';
import 'package:techstagram/constants.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  bool errordikhao;
  BoxDecoration boxDecoration;

  TextFieldContainer({
    Key key,
    this.child, this.errordikhao, this.boxDecoration
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.only(top: 5, bottom: 2, right: 5, left: 10),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: kPrimaryLightColor,
        borderRadius: BorderRadius.circular(29),
        border: Border.all(
          color: (errordikhao == true) ? Colors.red : kPrimaryLightColor,
        ),
      ),
      child: child,
    );
  }
}



