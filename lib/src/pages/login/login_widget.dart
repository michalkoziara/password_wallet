import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, BlocProvider;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;

import '../../blocs/registration/registration.dart';
import 'login_form.dart';

/// A widget containing a login.
class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context) ?? false;

    return Column(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              curve: Curves.easeOut,
              duration: const Duration(
                milliseconds: 200,
              ),
              width: double.infinity,
              height: isKeyboardVisible ? 10 : 50,
            ),
            AnimatedContainer(
              curve: Curves.easeOut,
              duration: const Duration(
                milliseconds: 200,
              ),
              width: double.infinity,
              height: isKeyboardVisible ? 80 : 200,
              child: SvgPicture.asset(
                'assets/images/security_lock.svg',
                fit: BoxFit.scaleDown,
              ),
            ),
            BlocBuilder<RegistrationBloc, RegistrationState>(
              builder: (BuildContext context, RegistrationState registrationState) {
                double spacerHeight = isKeyboardVisible ? 10 : 30;

                if (isKeyboardVisible && registrationState is RegistrationVisibleState) {
                  spacerHeight = 5;
                } else if (registrationState is RegistrationVisibleState) {
                  spacerHeight = 10;
                }

                return AnimatedContainer(
                  curve: Curves.easeOut,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  width: double.infinity,
                  height: spacerHeight,
                );
              },
            ),
            AnimatedDefaultTextStyle(
              child: const Text('Password Wallet'),
              duration: const Duration(
                milliseconds: 200,
              ),
              style: isKeyboardVisible
                  ? const TextStyle(color: Colors.white, fontSize: 16)
                  : const TextStyle(color: Colors.white, fontSize: 30),
            ),
          ],
        ),
        BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (BuildContext context, RegistrationState state) {
            return AnimatedContainer(
              curve: Curves.easeOut,
              duration: const Duration(
                milliseconds: 200,
              ),
              width: double.infinity,
              height: state is RegistrationVisibleState ? 10 : 30,
            );
          },
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.3,
          child: const LoginForm(),
        ),
        BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (BuildContext context, RegistrationState state) {
            if (state is RegistrationInvisibleState || state is LoginErrorState) {
              return RegistrationButton();
            }

            return SignInButton();
          },
        ),
      ],
    );
  }
}

/// A button allowing registration.
class RegistrationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'No account?',
          style: TextStyle(fontSize: 16, color: Color(0xFF361594)),
        ),
        FlatButton(
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 3),
          onPressed: () {
            BlocProvider.of<RegistrationBloc>(context).add(ShowRegistration());
          },
          child: const Text(
            'Create One!',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

/// A button allowing signing in.
class SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Already have account?',
          style: TextStyle(fontSize: 16, color: Color(0xFF361594)),
        ),
        FlatButton(
          textColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 3),
          onPressed: () {
            BlocProvider.of<RegistrationBloc>(context).add(HideRegistration());
          },
          child: const Text(
            'Sign in!',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
