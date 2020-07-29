import 'package:flutter/material.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/constants.dart';

//final TextEditingController _pass = TextEditingController();
//final TextEditingController _confirmPass = TextEditingController();

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const RoundedPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _obscureText = true;

  TextEditingController pwdInputController;

  @override
  initState() {
    pwdInputController = new TextEditingController();
    super.initState();
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool loginfail = false;
    return Container(
      height: 70.0,
      child: TextFieldContainer(
        child: TextFormField(
          obscureText: _obscureText,
          controller: pwdInputController,
          validator: pwdValidator,
          cursorColor: kPrimaryColor,
          decoration: InputDecoration(
            errorText: loginfail ? 'password not match' : null,
            hintText: "Password",
            icon: Icon(
              Icons.lock,
              color: kPrimaryColor,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon(
                Icons.visibility,
                color: kPrimaryColor,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
