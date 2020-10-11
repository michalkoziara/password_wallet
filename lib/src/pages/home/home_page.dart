import 'package:flutter/material.dart';

import 'login.dart';

/// A main screen of the application.
class HomePage extends StatelessWidget {
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
          child: Login(),
        ),
      ),
    );
  }
}
