import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'utils/constants.dart';

/// A widget that defines this application.
class PasswordWalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.title,
      home: HomePage(),
    );
  }
}
