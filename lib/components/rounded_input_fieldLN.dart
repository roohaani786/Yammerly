import 'package:flutter/material.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/constants.dart';

class RoundedInputFieldLN extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const RoundedInputFieldLN({
    Key key,
    this.hintText,
    this.icon = Icons.input,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0,
      child: TextFieldContainer(
        child: TextField(
          onChanged: onChanged,
          cursorColor: kPrimaryColor,
          decoration: InputDecoration(
            icon: Icon(
              icon,
              color: kPrimaryColor,
            ),
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
