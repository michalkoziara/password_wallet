import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';

import '../../blocs/keyboard/keyboard.dart';
import 'login_form.dart';

/// A widget containing a login.
class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    KeyboardVisibility.onChange.listen(
      (bool visible) {
        if (visible) {
          BlocProvider.of<KeyboardBloc>(context).add(ShowKeyboard());
        } else {
          BlocProvider.of<KeyboardBloc>(context).add(HideKeyboard());
        }
      },
    );

    return Column(
      children: <Widget>[
        BlocBuilder<KeyboardBloc, KeyboardState>(
          builder: (BuildContext context, KeyboardState state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  curve: Curves.easeOut,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  width: double.infinity,
                  height: state is KeyboardVisibleState ? 10 : 50,
                ),
                AnimatedContainer(
                  curve: Curves.easeOut,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  width: double.infinity,
                  height: state is KeyboardVisibleState ? 80 : 200,
                  child: SvgPicture.asset(
                    'assets/images/security_lock.svg',
                    fit: BoxFit.scaleDown,
                  ),
                ),
                AnimatedContainer(
                  curve: Curves.easeOut,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  width: double.infinity,
                  height: state is KeyboardVisibleState ? 10 : 30,
                ),
                AnimatedDefaultTextStyle(
                  child: const Text('Password Wallet'),
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  style: state is KeyboardVisibleState
                      ? const TextStyle(color: Colors.white, fontSize: 16)
                      : const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ],
            );
          },
        ),
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.3,
          child: const LoginForm(),
        ),
      ],
    );
  }
}
