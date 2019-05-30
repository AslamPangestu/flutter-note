import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  InputText(
      {@required this.type, @required this.hint, @required this.controller});

  final String type;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
        child: TextFormField(
          controller: controller,
          validator: (String value) {
            return _validateInput(value);
          },
          decoration: InputDecoration(
              labelText: type,
              hintText: hint,
              errorStyle: TextStyle(
                color: Colors.redAccent,
                fontSize: 15.0,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
        ));
  }

  String _validateInput(String value) {
    if (value.isEmpty) {
      return 'Your input is empty';
    } else {
      return null;
    }
  }
}
