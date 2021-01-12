import 'package:flutter/material.dart';

import 'addresses_list.dart';
import 'logs_content.dart';
import 'password_form.dart';
import 'passwords_list.dart';
import 'profile_form.dart';

/// A widget that displays wallet content.
class WalletContent extends StatelessWidget {
  /// Creates the password wallet page.
  const WalletContent({@required this.username, @required this.password, @required this.activeIndex});

  /// The username of user that is signed in.
  final String username;

  /// The password of user that is signed in.
  final String password;

  /// The index of active content.
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      switch (activeIndex) {
        case 0:
          return ProfileForm(
            username: username,
            password: password,
          );

        case 1:
          return PasswordForm(
            username: username,
            password: password,
          );

        case 2:
          return PasswordsList(
            username: username,
            password: password,
          );

        case 3:
          return LogsContent(
            username: username,
            userPassword: password,
          );

        case 4:
          return AddressesList(username: username);

        default:
          return Container();
      }
    });
  }
}
