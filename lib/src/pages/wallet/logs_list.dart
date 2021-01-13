import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show RepositoryProvider;
import 'package:flutter_icons/flutter_icons.dart';

import '../../data/models/models.dart' show Log;
import '../../services/services.dart';

/// A list of logs.
class LogsList extends StatefulWidget {
  /// Creates the log list.
  const LogsList({@required this.username});

  /// The username of user that is signed in.
  final String username;

  @override
  _LogsListState createState() => _LogsListState();
}

class _LogsListState extends State<LogsList> {
  List<Log> logs = <Log>[];

  @override
  void initState() {
    super.initState();

    RepositoryProvider.of<UserService>(context)
        .getUserLogs(username: widget.username)
        .then((List<Log> logs) => setState(() => this.logs = logs.toList()));
  }

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'There are no logs yet!',
          style: TextStyle(fontSize: 25, color: Color(0xFFE1DFF8)),
        ),
      );
    }

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
                  'Login Logs',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Ink(
            color: const Color(0xFFE1DFF8),
            child: ListView.separated(
              itemBuilder: (_, int index) => Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        if (logs[index].isSuccessful)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Icon(
                              FlutterIcons.checksquareo_ant,
                              color: Colors.lightGreen,
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Icon(
                              FlutterIcons.closesquareo_ant,
                              color: Colors.redAccent,
                            ),
                          ),
                        Text('IP Address: ${logs[index].ipAddress}'),
                        const Spacer(),
                        Text(DateTime.fromMillisecondsSinceEpoch(logs[index].loginTime).toString().substring(0, 19)),
                      ],
                    ),
                  )
                ],
              ),
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemCount: logs.length,
            ),
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
    );
  }
}
