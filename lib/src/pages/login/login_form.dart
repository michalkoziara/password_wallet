import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import '../../blocs/registration/registration.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_form_field.dart';
import '../wallet/wallet_page.dart';

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
            CustomFormField(
              controller: _usernameController,
              hintText: 'Username',
              inputType: TextInputType.text,
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
            CustomFormField(
              controller: _passwordController,
              hintText: 'Password',
              inputType: TextInputType.visiblePassword,
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
                        password: _passwordController?.text,
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
                  return CustomButton(
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

                return CustomButton(
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
