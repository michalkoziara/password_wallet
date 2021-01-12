import 'package:chips_choice/chips_choice.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../data/models/data_change.dart';
import '../../data/models/models.dart';
import '../../services/data_change_service.dart';
import '../../services/password_service.dart';
import '../../utils/failure.dart';
import '../../utils/string_extension.dart';

/// A list containing historical user activities.
class ActionsList extends StatefulWidget {
  /// Creates the activities list.
  const ActionsList({@required this.username, @required this.callback});

  /// The username of user that is signed in.
  final String username;

  /// The callback to the parent widget.
  final ValueChanged<int> callback;

  @override
  _ActionsListState createState() => _ActionsListState();
}

class _ActionsListState extends State<ActionsList> {
  final List<String> _options = <String>[
    'View',
    'Create',
    'Modify',
    'Delete',
    'Restore',
  ];

  List<String> _selectedOptions = <String>[
    'View',
    'Create',
    'Modify',
    'Delete',
    'Restore',
  ];

  SlidableController _slidableController;

  List<DataChange> _dataChanges = <DataChange>[];
  List<DataChange> _displayedDataChanges = <DataChange>[];
  List<Password> _passwords = <Password>[];

  @override
  void initState() {
    super.initState();

    _slidableController = SlidableController(
      onSlideIsOpenChanged: (bool isOpened) => !isOpened ? widget.callback(-1) : null,
    );

    RepositoryProvider.of<DataChangeService>(context).getUserDataChanges(username: widget.username).then(
      (List<DataChange> dataChanges) {
        setState(
          () {
            _dataChanges = dataChanges.reversed.toList();
          },
        );

        RepositoryProvider.of<PasswordService>(context).getPasswords(username: widget.username).then(
              (Either<Failure, List<Password>> result) => setState(
                () {
                  _passwords = result.getOrElse(() => <Password>[]);
                },
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _displayedDataChanges = _dataChanges
        .where((DataChange dataChange) => _selectedOptions.contains(dataChange.actionType.capitalize()))
        .toList();

    return Column(
      children: <Widget>[
        ChipsChoice<String>.multiple(
          value: _selectedOptions,
          wrapped: true,
          alignment: WrapAlignment.center,
          choiceActiveStyle: const C2ChoiceStyle(color: Colors.deepPurple),
          onChanged: (List<String> values) => setState(() => _selectedOptions = values),
          choiceItems: C2Choice.listFrom<String, String>(
            source: _options,
            value: (int index, String value) => value,
            label: (int index, String value) => value,
          ),
        ),
        Expanded(
            child: _displayedDataChanges.isEmpty
                ? const Center(
                    child: Text(
                      'There are no activities yet!',
                      style: TextStyle(fontSize: 25, color: Color(0xFFE1DFF8)),
                    ),
                  )
                : Column(
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
                          padding: const EdgeInsets.only(bottom: 10, left: 25, right: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const <Widget>[
                              Text(
                                'Date',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Account',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Action',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              )
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
                                Slidable(
                                  closeOnScroll: true,
                                  controller: _slidableController,
                                  actionExtentRatio: 0.25,
                                  actionPane: const SlidableScrollActionPane(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 25),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          _getDateFromMilliseconds(_displayedDataChanges[index].changeTime),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          _getPasswordDetailsByIndex(index),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          width: 45,
                                          child: Text(
                                            _displayedDataChanges[index].actionType.capitalize(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  secondaryActions: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right: 3.0),
                                      child: FlatButton(
                                        onPressed: () => widget.callback(
                                          _getRelatedPassword(_displayedDataChanges[index]).id,
                                        ),
                                        color: Colors.deepPurpleAccent,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const <Widget>[
                                            Icon(
                                              Icons.archive,
                                              color: Colors.white,
                                            ),
                                            Spacer(),
                                            Text(
                                              'Data',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            separatorBuilder: (BuildContext context, int index) => const Divider(),
                            itemCount: _displayedDataChanges.length,
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
                  ))
      ],
    );
  }

  String _getDateFromMilliseconds(int milliseconds) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${date.toString().substring(0, 10)}\n${date.toString().substring(11, 19)}';
  }

  Password _getRelatedPassword(DataChange dataChange) {
    final List<Password> relatedPasswords =
        _passwords.where((Password password) => password.id == dataChange.passwordId).toList();

    if (relatedPasswords.isEmpty) {
      return null;
    }

    return relatedPasswords[0];
  }

  String _getPasswordDetailsByIndex(int index) {
    final Password relatedPassword = _getRelatedPassword(_displayedDataChanges[index]);
    if (relatedPassword == null) {
      return '';
    }

    return '${relatedPassword.webAddress}\n${relatedPassword.login}';
  }
}
