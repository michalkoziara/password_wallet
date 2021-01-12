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
  final FocusNode _textFieldFocusNode = FocusNode();

  bool _checked;

  TextEditingController _usernameController;
  bool _isShareButtonActive;
  bool _activeShare;
  bool _isUsernameInputValid;

  bool _isFormOpened;
  Password _editedPassword;

  @override
  void initState() {
    super.initState();

    _checked = false;
    _isShareButtonActive = false;
    _activeShare = false;
    _isUsernameInputValid = true;
    _isFormOpened = false;

    BlocProvider.of<PasswordListBloc>(context).add(
      PasswordListOpenEvent(
        username: widget.username,
      ),
    );

    _usernameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return _isFormOpened
        ? PasswordEditForm(
            username: widget.username,
            userPassword: widget.password,
            password: _editedPassword,
            callback: (int result) => setState(() {
              _isFormOpened = false;

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
                    Container(
                      color: const Color(0xFFE1DFF8),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CheckboxListTile(
                          title: const Text('Edit mode'),
                          value: _checked,
                          activeColor: Colors.deepPurpleAccent,
                          checkColor: Colors.white,
                          onChanged: (bool value) {
                            setState(() {
                              _checked = value;
                            });
                          },
                          selected: _checked,
                          secondary: const Icon(FlutterIcons.edit_mdi),
                          controlAffinity: ListTileControlAffinity.trailing,
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
                                      PasswordListItemExtendedEvent(
                                        passwords: state.passwords,
                                        index: index,
                                      ),
                                    );
                                    _activeShare = false;
                                    _isShareButtonActive = false;
                                  } else {
                                    BlocProvider.of<PasswordListBloc>(context).add(
                                      PasswordListItemExtendedEvent(
                                        passwords: state.passwords,
                                        index: -1,
                                      ),
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
                                                        style: TextStyle(
                                                          fontStyle: FontStyle.italic,
                                                          color: Colors.grey,
                                                        ),
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
                                                        setState(() {
                                                          _isShareButtonActive = true;
                                                        });

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
                                                      padding: const EdgeInsets.only(bottom: 8.0, top: 9.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          RawMaterialButton(
                                                            constraints: BoxConstraints.tight(const Size(45, 36)),
                                                            child: const Icon(
                                                              FlutterIcons.delete_forever_mdi,
                                                              size: 26,
                                                            ),
                                                            shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(18.0),
                                                                bottomLeft: Radius.circular(18.0),
                                                              ),
                                                            ),
                                                            fillColor: _checked ? Colors.white : Colors.blueGrey[200],
                                                            padding: const EdgeInsets.only(left: 5),
                                                            onPressed: _checked
                                                                ? () {
                                                                    if (password.ownerPasswordId == null) {
                                                                      _activeShare = false;
                                                                      _isShareButtonActive = false;

                                                                      RepositoryProvider.of<PasswordService>(context)
                                                                          .removePassword(password: password)
                                                                          .then((bool result) {
                                                                        if (result) {
                                                                          BlocProvider.of<PasswordListBloc>(context)
                                                                              .add(
                                                                            PasswordListOpenEvent(
                                                                              username: widget.username,
                                                                            ),
                                                                          );
                                                                        }
                                                                      });
                                                                    } else {
                                                                      Scaffold.of(context).showSnackBar(
                                                                        SnackBar(
                                                                          margin: const EdgeInsets.only(
                                                                            bottom: 32,
                                                                            left: 30,
                                                                            right: 30,
                                                                          ),
                                                                          content: const Text(
                                                                              'You have to be an owner to share this!'),
                                                                          behavior: SnackBarBehavior.floating,
                                                                        ),
                                                                      );
                                                                    }
                                                                  }
                                                                : null,
                                                          ),
                                                          const SizedBox(width: 5),
                                                          RawMaterialButton(
                                                            constraints: BoxConstraints.tight(const Size(45, 36)),
                                                            child: const Icon(
                                                              FlutterIcons.edit_mdi,
                                                              size: 26,
                                                            ),
                                                            shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(18.0),
                                                                bottomRight: Radius.circular(18.0),
                                                              ),
                                                            ),
                                                            fillColor: _checked ? Colors.white : Colors.blueGrey[200],
                                                            padding: const EdgeInsets.only(right: 5),
                                                            onPressed: _checked
                                                                ? () {
                                                                    if (password.ownerPasswordId == null) {
                                                                      setState(() {
                                                                        _activeShare = false;
                                                                        _isShareButtonActive = false;

                                                                        _isFormOpened = true;
                                                                        _editedPassword = password;
                                                                      });
                                                                    } else {
                                                                      Scaffold.of(context).showSnackBar(
                                                                        SnackBar(
                                                                          margin: const EdgeInsets.only(
                                                                            bottom: 32,
                                                                            left: 30,
                                                                            right: 30,
                                                                          ),
                                                                          content: const Text(
                                                                              'You have to be an owner to edit this!'),
                                                                          behavior: SnackBarBehavior.floating,
                                                                        ),
                                                                      );
                                                                    }
                                                                  }
                                                                : null,
                                                          ),
                                                          const Spacer(),
                                                          if (_isShareButtonActive)
                                                            RawMaterialButton(
                                                              constraints: BoxConstraints.tight(const Size(45, 45)),
                                                              child: Icon(
                                                                FlutterIcons.share_sli,
                                                                size: 26,
                                                                color: _activeShare ? Colors.white : Colors.black87,
                                                              ),
                                                              shape: const CircleBorder(),
                                                              fillColor:
                                                                  _activeShare ? Colors.deepPurpleAccent : Colors.white,
                                                              padding: const EdgeInsets.only(bottom: 3, right: 3),
                                                              onPressed: () {
                                                                if (password.ownerPasswordId == null) {
                                                                  setState(() {
                                                                    _activeShare = !_activeShare;
                                                                  });
                                                                } else {
                                                                  Scaffold.of(context).showSnackBar(
                                                                    SnackBar(
                                                                      margin: const EdgeInsets.only(
                                                                        bottom: 32,
                                                                        left: 30,
                                                                        right: 30,
                                                                      ),
                                                                      content: const Text(
                                                                          'You have to be an owner to share this!'),
                                                                      behavior: SnackBarBehavior.floating,
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (_activeShare)
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 3.0),
                                                        child: TextField(
                                                          focusNode: _textFieldFocusNode,
                                                          maxLines: 1,
                                                          controller: _usernameController,
                                                          cursorColor: const Color(0xFF8858E1),
                                                          decoration: InputDecoration(
                                                            suffixIcon: IconButton(
                                                              onPressed: () {
                                                                _textFieldFocusNode.unfocus();
                                                                _textFieldFocusNode.canRequestFocus = false;

                                                                if (_usernameController.text.isEmpty ||
                                                                    _usernameController.text == widget.username) {
                                                                  setState(() {
                                                                    _isUsernameInputValid = false;
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    _isUsernameInputValid = true;
                                                                  });

                                                                  RepositoryProvider.of<PasswordService>(context)
                                                                      .sharePassword(
                                                                          password: password,
                                                                          username: _usernameController.text,
                                                                          ownerPassword: widget.password)
                                                                      .then((bool result) {
                                                                    if (result) {
                                                                      Scaffold.of(context).showSnackBar(
                                                                        SnackBar(
                                                                          margin: const EdgeInsets.only(
                                                                            bottom: 32,
                                                                            left: 30,
                                                                            right: 30,
                                                                          ),
                                                                          content: const Text('Password shared!'),
                                                                          behavior: SnackBarBehavior.floating,
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      Scaffold.of(context).showSnackBar(
                                                                        SnackBar(
                                                                          margin: const EdgeInsets.only(
                                                                            bottom: 32,
                                                                            left: 30,
                                                                            right: 30,
                                                                          ),
                                                                          content: const Text(
                                                                              'Could not share password, please try again!'),
                                                                          behavior: SnackBarBehavior.floating,
                                                                        ),
                                                                      );
                                                                    }
                                                                  });
                                                                }

                                                                Future<void>.delayed(
                                                                  const Duration(milliseconds: 100),
                                                                  () => _textFieldFocusNode.canRequestFocus = true,
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                FlutterIcons.arrowright_ant,
                                                                color: Color(0xFF8858E1),
                                                              ),
                                                            ),
                                                            helperText: ' ',
                                                            helperStyle: const TextStyle(height: 1),
                                                            errorStyle: const TextStyle(
                                                              height: 1,
                                                              color: Colors.redAccent,
                                                            ),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            hintText: 'Username',
                                                            errorText:
                                                                _isUsernameInputValid ? null : 'Please enter username',
                                                            prefixIcon: const Icon(
                                                              FlutterIcons.share_sli,
                                                              color: Color(0xFF8858E1),
                                                            ),
                                                            focusColor: const Color(0xFF8858E1),
                                                            contentPadding: const EdgeInsets.only(
                                                              left: 14.0,
                                                              bottom: 8.0,
                                                              top: 8.0,
                                                            ),
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
                                                        ),
                                                      )
                                                    else
                                                      Container()
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
