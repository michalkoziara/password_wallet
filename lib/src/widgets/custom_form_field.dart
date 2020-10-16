import 'package:flutter/material.dart';

/// A form field with round borders and custom colors.
class CustomFormField extends StatelessWidget {
  /// Creates a form field.
  const CustomFormField({
    @required this.controller,
    @required this.hintText,
    @required this.inputType,
    @required this.validationErrorMessage,
    @required this.iconData,
  });

  /// A controller for an editable text field.
  final TextEditingController controller;

  /// A text that suggests what sort of input the field accepts.
  final String hintText;

  /// The type of information for which to optimize the text input control.
  final TextInputType inputType;

  /// The message that is displayed after a validation error.
  final String validationErrorMessage;

  /// A data of icon that appears before the editable part of the text field.
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: inputType,
      maxLines: null,
      controller: controller,
      cursorColor: const Color(0xFF8858E1),
      decoration: InputDecoration(
        helperText: ' ',
        helperStyle: const TextStyle(height: 1),
        errorStyle: const TextStyle(height: 1, color: Colors.white),
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        prefixIcon: Icon(
          iconData,
          color: const Color(0xFF8858E1),
        ),
        focusColor: const Color(0xFF8858E1),
        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(30),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return validationErrorMessage;
        }
        return null;
      },
    );
  }
}
