import 'package:flutter/material.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/constants.dart';

class RoundedInputFieldE extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const RoundedInputFieldE({
    Key key,
    this.hintText,
    this.icon = Icons.email,
    this.onChanged,
  }) : super(key: key);

  @override
  _RoundedInputFieldEState createState() => _RoundedInputFieldEState();
}

class _RoundedInputFieldEState extends State<RoundedInputFieldE> {
//  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;

  @override
  initState() {
    emailInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: emailInputController,
        keyboardType: TextInputType.emailAddress,
        validator: emailValidator,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(
            widget.icon,
            color: kPrimaryColor,
          ),
          hintText: widget.hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
