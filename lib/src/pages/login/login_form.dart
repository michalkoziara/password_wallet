import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import '../../blocs/registration/registration.dart';

/// A form that allows user to sign in.
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
            BlocBuilder<RegistrationBloc, RegistrationState>(
              builder: (BuildContext context, RegistrationState state) {
                return AnimatedContainer(
                  curve: Curves.easeOut,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  width: double.infinity,
                  height: state is RegistrationVisibleState ? 5 : 20,
                );
              },
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
            BlocBuilder<RegistrationBloc, RegistrationState>(
              builder: (BuildContext context, RegistrationState state) {
                if (state is RegistrationVisibleState) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 17.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            'Encrypting\nalgorithm',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        LiteRollingSwitch(
                          value: true,
                          textOn: 'SHA-512',
                          textOff: 'HMAC',
                          colorOn: const Color(0xFF8858E1),
                          colorOff: const Color(0xFFAAA3F9),
                          iconOn: FlutterIcons.enhanced_encryption_mdi,
                          iconOff: FlutterIcons.lock_mdi,
                          textSize: 16.0,
                          onChanged: (bool state) {
                            print('Current State of SWITCH IS: $state');
                          },
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox(
                  height: 25,
                );
              },
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
              child: BlocBuilder<RegistrationBloc, RegistrationState>(
                builder: (BuildContext context, RegistrationState state) {
                  if (state is RegistrationVisibleState) {
                    return const Text(
                      'Register',
                      style: TextStyle(fontSize: 20),
                    );
                  }

                  return const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 20),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
