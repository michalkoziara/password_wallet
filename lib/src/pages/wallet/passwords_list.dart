import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, BlocProvider, RepositoryProvider;
import 'package:flutter_icons/flutter_icons.dart';

import '../../blocs/password_list/password_list.dart';
import '../../data/models/models.dart' show Password;
import '../../services/password_service.dart';
import 'password_edit_form.dart';

/// An expandable list of passwords with descriptions.
class PasswordsList extends StatefulWidget {
  /// Creates the password list.
  const PasswordsList({@required this.username, @required this.password});

  /// The username of user that is signed in.
  final String username;

  /// The password of user that is signed in.
  final String password;

  @override
  _PasswordsListState createState() => _PasswordsListState();
}

class _PasswordsListState extends State<PasswordsList> {
  bool isFormOpened;
  Password editedPassword;

  @override
  void initState() {
    super.initState();

    isFormOpened = false;

    BlocProvider.of<PasswordListBloc>(context).add(
      PasswordListOpenEvent(
        username: widget.username,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isFormOpened
        ? PasswordEditForm(
            username: widget.username,
            userPassword: widget.password,
            password: editedPassword,
            callback: (int result) => setState(() {
              isFormOpened = false;

              if (result == 0) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.only(bottom: 32, left: 30, right: 30),
                    content: const Text('Could not update password, please try again!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }

              if (result == 1) {
                BlocProvider.of<PasswordListBloc>(context).add(
                  PasswordListOpenEvent(
                    username: widget.username,
                  ),
                );

                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.only(bottom: 32, left: 30, right: 30),
                    content: const Text('Updated password'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }),
          )
        : BlocBuilder<PasswordListBloc, PasswordListState>(
            builder: (BuildContext context, PasswordListState state) {
              if (state is PasswordListSuccessState && state.passwords.isNotEmpty) {
                return Column(
                  children: <Widget>[
                    Container(
                      height: 25,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        color: Color(0xFFE1DFF8),
                      ),
                    ),
                    Container(
                      color: const Color(0xFFE1DFF8),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Text(
                              'Passwords List',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Theme(
                              data: ThemeData().copyWith(cardColor: const Color(0xFFE1DFF8)),
                              child: ExpansionPanelList(
                                expansionCallback: (int index, bool isExpanded) {
                                  if (!isExpanded) {
                                    BlocProvider.of<PasswordListBloc>(context).add(
                                      PasswordListItemExtendedEvent(passwords: state.passwords, index: index),
                                    );
                                  } else {
                                    BlocProvider.of<PasswordListBloc>(context).add(
                                      PasswordListItemExtendedEvent(passwords: state.passwords, index: -1),
                                    );
                                  }
                                },
                                children: state.passwords
                                    .asMap()
                                    .map<int, ExpansionPanel>(
                                      (int index, Password password) {
                                        return MapEntry<int, ExpansionPanel>(
                                          index,
                                          ExpansionPanel(
                                            headerBuilder: (BuildContext context, bool isExpanded) {
                                              return ListTile(
                                                title: Row(
                                                  children: <Widget>[
                                                    const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: Icon(FlutterIcons.user_ant, size: 20),
                                                    ),
                                                    Text(password.login),
                                                  ],
                                                ),
                                                subtitle: Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      const Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                        child: Icon(FlutterIcons.web_mco, size: 20),
                                                      ),
                                                      Text(password.webAddress),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            body: ListTile(
                                              title: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Icon(FlutterIcons.lock1_ant, size: 20),
                                                  ),
                                                  BlocBuilder<PasswordListBloc, PasswordListState>(
                                                    builder: (BuildContext context, PasswordListState passwordState) {
                                                      if (passwordState is PasswordListVisiblePasswordState) {
                                                        return Text(
                                                          passwordState.password,
                                                        );
                                                      }

                                                      return const Text(
                                                        'Hidden',
                                                        style:
                                                            TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                                      );
                                                    },
                                                  ),
                                                  const Spacer(),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 9.0),
                                                    child: IconButton(
                                                      icon: const Icon(FlutterIcons.eye_mco, size: 20),
                                                      padding: const EdgeInsets.all(0),
                                                      onPressed: () {
                                                        if (state is PasswordListItemExpandedState) {
                                                          BlocProvider.of<PasswordListBloc>(context).add(
                                                            PasswordDisplayEvent(
                                                                passwords: state.passwords,
                                                                index: state.index,
                                                                id: password.id,
                                                                password: widget.password),
                                                          );
                                                        }
                                                      },
                                                      constraints: const BoxConstraints(
                                                        maxHeight: 28,
                                                        maxWidth: 28,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        const Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                          child: Icon(FlutterIcons.text_ent, size: 20),
                                                        ),
                                                        Text(password.description),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 8.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Spacer(),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 9.0),
                                                            child: IconButton(
                                                              icon:
                                                                  const Icon(FlutterIcons.delete_forever_mdi, size: 26),
                                                              padding: const EdgeInsets.all(0),
                                                              onPressed: () {
                                                                RepositoryProvider.of<PasswordService>(context)
                                                                    .removePassword(passwordId: password.id)
                                                                    .then((bool result) {
                                                                  if (result) {
                                                                    BlocProvider.of<PasswordListBloc>(context).add(
                                                                      PasswordListOpenEvent(
                                                                        username: widget.username,
                                                                      ),
                                                                    );
                                                                  }
                                                                });
                                                              },
                                                              constraints: const BoxConstraints(
                                                                maxHeight: 28,
                                                                maxWidth: 28,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 9.0),
                                                            child: IconButton(
                                                              icon: const Icon(FlutterIcons.edit_mdi, size: 25),
                                                              padding: const EdgeInsets.all(0),
                                                              onPressed: () {
                                                                setState(() {
                                                                  isFormOpened = true;
                                                                  editedPassword = password;
                                                                });
                                                              },
                                                              constraints: const BoxConstraints(
                                                                maxHeight: 28,
                                                                maxWidth: 28,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            isExpanded: state is PasswordListItemExpandedState && state.index == index,
                                          ),
                                        );
                                      },
                                    )
                                    .values
                                    .toList(),
                              ),
                            ),
                            Container(
                              height: 25,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                                color: Color(0xFFE1DFF8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const Center(
                child: Text(
                  'You have to add passwords first!',
                  style: TextStyle(fontSize: 25, color: Color(0xFFE1DFF8)),
                ),
              );
            },
          );
  }
}
