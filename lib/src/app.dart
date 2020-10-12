import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/keyboard/keyboard.dart' show KeyboardBloc;
import 'blocs/registration/registration.dart';
import 'pages/login/login_page.dart';
import 'utils/constants.dart';

/// A widget that defines this application.
class PasswordWalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProviders(
      child: MaterialApp(
        title: Constants.title,
        theme: ThemeData(fontFamily: 'PTSans'),
        home: LoginPage(),
      ),
    );
  }
}

/// A helper class that injects BLoC objects into widget tree.
class BlocProviders extends StatelessWidget {
  /// Creates BLoC providers.
  const BlocProviders({Key key, this.child}) : super(key: key);

  /// A child of this widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<KeyboardBloc>(
          create: _keyboardBlocBuilder,
        ),
        BlocProvider<RegistrationBloc>(
          create: _registrationBlocBuilder,
        )
      ],
      child: child,
    );
  }

  KeyboardBloc _keyboardBlocBuilder(BuildContext context) {
    return KeyboardBloc();
  }

  RegistrationBloc _registrationBlocBuilder(BuildContext context) {
    return RegistrationBloc();
  }
}
