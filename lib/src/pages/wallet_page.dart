import 'package:flutter/material.dart';

/// A screen containing the password wallet.
class WalletPage extends StatelessWidget {
  /// Creates the password wallet page.
  const WalletPage({@required this.username});

  /// The username of user that is signed in.
  final String username;

  @override
  Widget build(BuildContext context) {
    const List<Color> backgroundColors = <Color>[
      Color(0xFF5A24F8),
      Color(0xFF8858E1),
      Color(0xFF9B94E9),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backgroundColors,
        )),
        child: SafeArea(
          child: Container(
            child: Text(
              username,
            ),
          ),
        ),
      ),
    );
  }
}
