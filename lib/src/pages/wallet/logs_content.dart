import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'actions_list.dart';
import 'data_changes_list.dart';
import 'logs_list.dart';

/// A list of logs.
class LogsContent extends StatefulWidget {
  /// Creates the log list.
  const LogsContent({@required this.username, @required this.userPassword});

  /// The username of user that is signed in.
  final String username;

  /// The password of user that is signed in.
  final String userPassword;

  @override
  _LogsContentState createState() => _LogsContentState();
}

class _LogsContentState extends State<LogsContent> {
  int _contentIndex = 0;
  List<String> contentLabels = <String>['Login Logs', 'Activity Logs'];
  int _passwordId = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Builder(
            builder: (BuildContext context) {
              switch (_contentIndex) {
                case 0:
                  return LogsList(username: widget.username);
                case 1:
                  return ActionsList(
                    username: widget.username,
                    callback: (int passwordId) {
                      setState(() {
                        _passwordId = passwordId;

                        if (passwordId != null) {
                          if (!contentLabels.contains('Data Changes')) {
                            contentLabels.add('Data Changes');
                          }
                          _contentIndex = 2;
                        } else {
                          contentLabels.remove('Data Changes');
                        }
                      });
                    },
                  );
                case 2:
                  return _passwordId != -1
                      ? DataChangesList(
                          username: widget.username,
                          userPassword: widget.userPassword,
                          passwordId: _passwordId,
                        )
                      : Container();
                default:
                  return Container();
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 35, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ToggleSwitch(
                minWidth: MediaQuery.of(context).size.width - 50,
                minHeight: 50.0,
                initialLabelIndex: _contentIndex,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveFgColor: Colors.black87,
                activeBgColor: Colors.deepPurpleAccent,
                inactiveBgColor: const Color(0xFFE1DFF8),
                labels: contentLabels,
                iconSize: 30.0,
                onToggle: (int index) {
                  setState(() => _contentIndex = index);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
