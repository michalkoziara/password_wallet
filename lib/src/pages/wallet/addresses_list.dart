import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show RepositoryProvider;
import 'package:flutter_icons/flutter_icons.dart';

import '../../services/services.dart';
import '../../utils/error_messages.dart';

/// A list of blocked IP addresses.
class AddressesList extends StatefulWidget {
  /// Creates the log list.
  const AddressesList({@required this.username});

  /// The username of user that is signed in.
  final String username;

  @override
  _AddressesListState createState() => _AddressesListState();
}

class _AddressesListState extends State<AddressesList> {
  List<String> blockedIpAddresses = <String>[];

  @override
  void initState() {
    super.initState();

    RepositoryProvider.of<UserService>(context)
        .getBlockedIpAddresses(username: widget.username)
        .then((List<String> blockedIpAddresses) => setState(() => this.blockedIpAddresses = blockedIpAddresses));
  }

  @override
  Widget build(BuildContext context) {
    if (blockedIpAddresses.isEmpty) {
      return const Center(
        child: Text(
          'There are no blocked IP addresses yet!',
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
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  'Blocked IP Addresses',
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(blockedIpAddresses[index]),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(
                              FlutterIcons.squared_cross_ent,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              RepositoryProvider.of<UserService>(context)
                                  .unblockIp(username: widget.username, blockedIpAddress: blockedIpAddresses[index])
                                  .then(
                                (bool result) {
                                  if (result) {
                                    RepositoryProvider.of<UserService>(context)
                                        .getBlockedIpAddresses(username: widget.username)
                                        .then((List<String> blockedIpAddresses) =>
                                            setState(() => this.blockedIpAddresses = blockedIpAddresses));
                                  } else {
                                    Scaffold.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(ErrorMessages.unblockingIpAddressFailureMessage),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemCount: blockedIpAddresses.length,
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
