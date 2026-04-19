import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Function validatorFunc;

  const TextBox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validatorFunc,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.orange,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: TextStyle(color: Colors.white70),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),

        border: OutlineInputBorder(),
      ),
      validator: validatorFunc(),
      obscureText: obscureText,
    );
  }
}
