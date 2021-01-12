import 'package:chips_choice/chips_choice.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/data_change.dart';
import '../../data/models/models.dart';
import '../../services/data_change_service.dart';
import '../../services/password_service.dart';
import '../../utils/failure.dart';
import '../../utils/string_extension.dart';

/// A list containing historical user activities.
class ActionsList extends StatefulWidget {
  /// Creates the activities list.
  const ActionsList({@required this.username});

  /// The username of user that is signed in.
  final String username;

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

  List<DataChange> _dataChanges = <DataChange>[];
  List<DataChange> _displayedDataChanges = <DataChange>[];
  List<Password> _passwords = <Password>[];

  @override
  void initState() {
    super.initState();

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
                                Padding(
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
                                        width: 43,
                                        child: Text(
                                          _displayedDataChanges[index].actionType.capitalize(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
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

  String _getPasswordDetailsByIndex(int index) {
    final List<Password> detailedPasswords =
        _passwords.where((Password password) => password.id == _displayedDataChanges[index].passwordId).toList();

    if (detailedPasswords.isEmpty) {
      return '';
    }

    return '${detailedPasswords[0].webAddress}\n${detailedPasswords[0].login}';
  }
}
