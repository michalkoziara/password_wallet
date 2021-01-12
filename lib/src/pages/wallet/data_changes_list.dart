import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show RepositoryProvider;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../data/models/data_change.dart';
import '../../data/models/models.dart';
import '../../services/data_change_service.dart';
import '../../services/password_service.dart';
import '../../utils/failure.dart';
import '../../utils/string_extension.dart';

/// A list of data changes.
class DataChangesList extends StatefulWidget {
  /// Creates the data changes list.
  const DataChangesList({@required this.username, @required this.userPassword, @required this.passwordId});

  /// The username of user that is signed in.
  final String username;

  /// The password of user that is signed in.
  final String userPassword;

  /// The ID of the password that is related to this data changes.
  final int passwordId;

  @override
  _DataChangesListState createState() => _DataChangesListState();
}

class _DataChangesListState extends State<DataChangesList> {
  final SlidableController _slidableController = SlidableController();

  List<DataChange> _dataChanges = <DataChange>[];
  List<Password> _passwords = <Password>[];

  @override
  void initState() {
    super.initState();

    RepositoryProvider.of<DataChangeService>(context).getPasswordChanges(passwordId: widget.passwordId).then(
      (List<DataChange> dataChanges) {
        setState(() => _dataChanges = dataChanges.reversed.toList());

        RepositoryProvider.of<PasswordService>(context).getPasswords(username: widget.username).then(
              (Either<Failure, List<Password>> result) => setState(
                () => _passwords = result.getOrElse(() => <Password>[]),
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_dataChanges.isEmpty) {
      return const Center(
        child: Text(
          'There are no data changes yet!',
          style: TextStyle(fontSize: 20, color: Color(0xFFE1DFF8)),
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
            padding: const EdgeInsets.only(bottom: 5, left: 25, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text(
                  'Date',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Before',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'After',
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
              itemBuilder: (_, int index) {
                if (<String>['modify', 'delete', 'restore'].contains(_dataChanges[index].actionType)) {
                  return Slidable(
                    closeOnScroll: true,
                    controller: _slidableController,
                    actionExtentRatio: 0.3,
                    actionPane: const SlidableScrollActionPane(),
                    secondaryActions: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: FlatButton(
                          onPressed: () {
                            RepositoryProvider.of<PasswordService>(context)
                                .restorePassword(dataChange: _dataChanges[index])
                                .then((int restoredPasswordId) {
                              String messageText = '';
                              if (restoredPasswordId != -1) {
                                messageText = 'Data restored!';

                                RepositoryProvider.of<DataChangeService>(context)
                                    .getPasswordChanges(passwordId: restoredPasswordId)
                                    .then(
                                  (List<DataChange> dataChanges) {
                                    setState(() => _dataChanges = dataChanges.reversed.toList());

                                    RepositoryProvider.of<PasswordService>(context)
                                        .getPasswords(username: widget.username)
                                        .then(
                                          (Either<Failure, List<Password>> result) => setState(
                                            () => _passwords = result.getOrElse(() => <Password>[]),
                                          ),
                                        );
                                  },
                                );
                              } else {
                                messageText = 'Could not restore data!';
                              }

                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  margin: const EdgeInsets.only(bottom: 32, left: 30, right: 30),
                                  content: Text(messageText),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            });
                          },
                          color: Colors.deepPurpleAccent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Icon(
                                FlutterIcons.restore_mdi,
                                color: Colors.white,
                              ),
                              Spacer(),
                              Text(
                                'Restore',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                    child: _getListRow(index),
                  );
                }

                return _getListRow(index);
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemCount: _dataChanges.length,
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

  String _getDateFromMilliseconds(int milliseconds) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${date.toString().substring(0, 10)}\n${date.toString().substring(11, 19)}';
  }

  Widget _getListRow(int index) {
    final List<Password> previousPasswords =
        _passwords.where((Password password) => password.id == _dataChanges[index].previousRecordId).toList();

    final List<Password> presentPasswords =
        _passwords.where((Password password) => password.id == _dataChanges[index].presentRecordId).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            _getDateFromMilliseconds(_dataChanges[index].changeTime),
            textAlign: TextAlign.center,
          ),
          Text(
            previousPasswords.isEmpty ? '' : previousPasswords[0].toString(),
            textAlign: TextAlign.center,
          ),
          Text(
            presentPasswords.isEmpty ? '' : presentPasswords[0].toString(),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            width: 45,
            child: Text(
              _dataChanges[index].actionType.capitalize(),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
