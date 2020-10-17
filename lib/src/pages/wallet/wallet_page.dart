import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../../blocs/password_form/password_form.dart';
import 'password_form.dart';
import 'passwords_list.dart';
import 'profile_form.dart';

/// A screen containing the password wallet.
class WalletPage extends StatefulWidget {
  /// Creates the password wallet page.
  const WalletPage({@required this.username, @required this.password});

  /// The username of user that is signed in.
  final String username;

  /// The password of user that is signed in.
  final String password;

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int activeIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B94E9),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: const Color(0xFF9B94E9),
        style: TabStyle.react,
        items: const <TabItem<IconData>>[
          TabItem<IconData>(icon: FlutterIcons.add_mdi, title: 'Add password'),
          TabItem<IconData>(icon: FlutterIcons.list_sli, title: 'Passwords'),
          TabItem<IconData>(icon: FlutterIcons.user_edit_faw5s, title: 'Change password'),
        ],
        initialActiveIndex: 1,
        onTap: (int i) => setState(() {
          activeIndex = i;
        }),
      ),
      body: BlocListener<PasswordFormBloc, PasswordFormState>(
        listener: (BuildContext context, PasswordFormState state) {
          if (state is PasswordFormCompletedState) {
            Scaffold.of(context).showSnackBar(
              const SnackBar(
                content: Text('Success'),
              ),
            );
          }

          if (state is PasswordFormIncorrectState) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: 60,
                child: Center(
                  child: Text(
                    'Welcome ${widget.username}!',
                    style: const TextStyle(fontSize: 30, color: Color(0xFFE1DFF8)),
                  ),
                ),
              ),
              Expanded(child: _createContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createContent() {
    switch (activeIndex) {
      case 0:
        return PasswordForm(username: widget.username, password: widget.password);

      case 1:
        return PasswordsList();

      case 2:
        return ProfileForm();

      default:
        return Container();
    }
  }
}
