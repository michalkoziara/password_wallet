import 'package:bloc/bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';
import 'src/blocs/blocs.dart' show SimpleBlocObserver;

/// Starts application.
///
/// Before application startup BLoC observer is configured.
/// Additionally, [resamplingEnabled] flag is set to smooth scrolling
/// for unmatched input and display frequencies.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  GestureBinding.instance.resamplingEnabled = true;
  Bloc.observer = SimpleBlocObserver();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xFF9B94E9),
    systemNavigationBarDividerColor: Color(0xFF9B94E9),
  ));

  runApp(PasswordWalletApp());
}
