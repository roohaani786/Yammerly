import 'package:flutter/material.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/constants.dart';

final TextEditingController _pass = TextEditingController();
final TextEditingController _confirmPass = TextEditingController();

class RoundedCPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const RoundedCPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: _confirmPass,
        validator: (val) {
          if (val.isEmpty) return 'Empty';
          if (val != _pass.text) return 'Not Match';
          return null;
        },
//        validator: (val){
//          if(val.isEmpty)
//            return 'Empty';
//          return null;
//        },
        obscureText: true,
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Confirm Password",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
