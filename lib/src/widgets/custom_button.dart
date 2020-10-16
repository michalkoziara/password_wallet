import 'package:flutter/material.dart';

/// A button with custom colors.
class CustomButton extends StatelessWidget {
  /// Creates a button.
  const CustomButton({@required this.submitWhenPressed, @required this.child});

  /// The callback method run when this button is pressed.
  final VoidCallback submitWhenPressed;

  /// The child of this button.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: const Color(0xFF576FA5),
      textColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      onPressed: submitWhenPressed,
      child: child,
    );
  }
}