import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../../blocs/password_form/password_form.dart';
import '../../blocs/password_list/password_list.dart';
import '../../blocs/profile_form/profile_form.dart';
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
  String password;

  @override
  void initState() {
    super.initState();

    password = widget.password;
  }

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
      body: SafeArea(
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
            Expanded(
              child: BlocListener<PasswordFormBloc, PasswordFormState>(
                listener: (BuildContext context, PasswordFormState state) {
                  if (state is PasswordFormCompletedState) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        margin: const EdgeInsets.only(bottom: 32, left: 30, right: 30),
                        content: const Text('Created'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }

                  if (state is PasswordFormIncorrectState) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: BlocListener<PasswordListBloc, PasswordListState>(
                  listener: (BuildContext context, PasswordListState state) {
                    if (state is PasswordListErrorState) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: BlocListener<ProfileFormBloc, ProfileFormState>(
                    listener: (BuildContext context, ProfileFormState state) {
                      if (state is ProfileFormCompletedState) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            margin: const EdgeInsets.only(bottom: 32, left: 30, right: 30),
                            content: const Text('Changed'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        password = state.password;
                      }

                      if (state is ProfileFormIncorrectState) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: _createContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createContent() {
    switch (activeIndex) {
      case 0:
        return PasswordForm(
          username: widget.username,
          password: password,
        );

      case 1:
        return PasswordsList(
          username: widget.username,
          password: password,
        );

      case 2:
        return ProfileForm(
          username: widget.username,
          password: password,
        );

      default:
        return Container();
    }
  }
}
