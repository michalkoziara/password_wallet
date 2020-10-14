import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import '../../blocs/registration/registration.dart';
import '../wallet_page.dart';

/// A form that allows user to sign in.
class LoginForm extends StatefulWidget {
  /// Creates login form.
  const LoginForm();

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController;
  TextEditingController _passwordController;

  bool _isEncryptingAlgorithmSha = true;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    super.initState();
  }

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
            LoginFormField(
              controller: _usernameController,
              hintText: 'Username',
              iconData: FlutterIcons.user_ant,
              validationErrorMessage: 'Please enter username',
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
            LoginFormField(
              controller: _passwordController,
              hintText: 'Password',
              iconData: FlutterIcons.lock1_ant,
              validationErrorMessage: 'Please enter password',
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
                            _isEncryptingAlgorithmSha = state;
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
            BlocConsumer<RegistrationBloc, RegistrationState>(
              listener: (BuildContext context, RegistrationState state) {
                if (state is RegistrationCompletionState || state is LoginCompletionState) {
                  Navigator.pushReplacement<WalletPage, void>(
                    context,
                    MaterialPageRoute<WalletPage>(
                      builder: (BuildContext context) => WalletPage(
                        username: _usernameController?.text,
                      ),
                      maintainState: false,
                    ),
                  );
                }

                if (state is RegistrationErrorState || state is LoginErrorState) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text((state as ErrorState).message),
                    ),
                  );
                }
              },
              builder: (BuildContext context, RegistrationState state) {
                if (state is RegistrationInvisibleState || state is LoginErrorState) {
                  return LoginFormButton(
                    submitWhenPressed: () {
                      if (_formKey.currentState.validate()) {
                        BlocProvider.of<RegistrationBloc>(context).add(
                          CompleteLogin(username: _usernameController?.text, password: _passwordController?.text),
                        );
                      }
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }

                return LoginFormButton(
                  submitWhenPressed: () {
                    if (_formKey.currentState.validate()) {
                      BlocProvider.of<RegistrationBloc>(context).add(
                        CompleteRegistration(
                            username: _usernameController?.text,
                            password: _passwordController?.text,
                            isEncryptingAlgorithmSha: _isEncryptingAlgorithmSha),
                      );
                    }
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A button used in the login form.
class LoginFormButton extends StatelessWidget {
  /// Creates a login form button.
  const LoginFormButton({@required this.submitWhenPressed, @required this.child});

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

/// A form field used in the login form.
class LoginFormField extends StatelessWidget {
  /// Creates a login form field.
  const LoginFormField({
    @required this.controller,
    @required this.hintText,
    @required this.validationErrorMessage,
    @required this.iconData,
  });

  /// A controller for an editable text field.
  final TextEditingController controller;

  /// A text that suggests what sort of input the field accepts.
  final String hintText;

  /// The message that is displayed after a validation error.
  final String validationErrorMessage;

  /// A data of icon that appears before the editable part of the text field.
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
