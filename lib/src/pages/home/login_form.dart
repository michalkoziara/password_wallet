import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

/// A form that allows user to log in.
class LoginForm extends StatefulWidget {
  /// Creates login form.
  const LoginForm();

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: Form(
        key: _formKey,
        onChanged: () {
          Form.of(primaryFocus.context).save();
        },
        child: Column(
          children: <Widget>[
            TextFormField(
              cursorColor: const Color(0xFF8858E1),
              decoration: InputDecoration(
                helperText: ' ',
                helperStyle: const TextStyle(height: 1),
                errorStyle: const TextStyle(height: 1, color: Colors.white),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Username',
                prefixIcon: const Icon(
                  FlutterIcons.user_ant,
                  color: Color(0xFF8858E1),
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
                  return 'Please enter username';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              cursorColor: const Color(0xFF8858E1),
              decoration: InputDecoration(
                helperText: ' ',
                helperStyle: const TextStyle(height: 1),
                errorStyle: const TextStyle(height: 1, color: Colors.white),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Password',
                prefixIcon: const Icon(
                  FlutterIcons.lock1_ant,
                  color: Color(0xFF8858E1),
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
                  return 'Please enter password';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 25,
            ),
            RaisedButton(
              color: const Color(0xFF576FA5),
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Processing Data'),
                    ),
                  );
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
