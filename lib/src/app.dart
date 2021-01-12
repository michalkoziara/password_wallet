import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider, MultiBlocProvider, RepositoryProvider;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'blocs/blocs.dart' show RegistrationBloc, PasswordFormBloc, ProfileFormBloc, PasswordListBloc;
import 'pages/login/login_page.dart';
import 'repositories/data_change_repository.dart';
import 'repositories/repositories.dart';
import 'services/data_change_service.dart';
import 'services/services.dart';
import 'utils/constants.dart';
import 'utils/random_values_generator.dart';

/// A widget that defines this application.
class PasswordWalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProviders(
      child: ServiceProviders(
        child: BlocProviders(
          child: KeyboardVisibilityProvider(
            child: KeyboardDismissOnTap(
              child: MaterialApp(
                title: Constants.title,
                theme: ThemeData(fontFamily: 'PTSans'),
                home: LoginPage(),
              ),
            ),
          ),
        ),
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
        BlocProvider<RegistrationBloc>(
          create: _registrationBlocBuilder,
        ),
        BlocProvider<PasswordFormBloc>(
          create: _passwordFormBlocBuilder,
        ),
        BlocProvider<PasswordListBloc>(
          create: _passwordListBlocBuilder,
        ),
        BlocProvider<ProfileFormBloc>(
          create: _profileFormBlocBuilder,
        ),
      ],
      child: child,
    );
  }

  RegistrationBloc _registrationBlocBuilder(BuildContext context) {
    return RegistrationBloc(RepositoryProvider.of<UserService>(context));
  }

  PasswordFormBloc _passwordFormBlocBuilder(BuildContext context) {
    return PasswordFormBloc(RepositoryProvider.of<PasswordService>(context));
  }

  PasswordListBloc _passwordListBlocBuilder(BuildContext context) {
    return PasswordListBloc(RepositoryProvider.of<PasswordService>(context));
  }

  ProfileFormBloc _profileFormBlocBuilder(BuildContext context) {
    return ProfileFormBloc(RepositoryProvider.of<UserService>(context));
  }
}

/// A helper class that injects repositories into widget tree.
class RepositoryProviders extends StatelessWidget {
  /// Creates repository providers.
  const RepositoryProviders({Key key, @required this.child}) : super(key: key);

  /// A child of this widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserRepository>(
      create: _userRepositoryBuilder,
      child: RepositoryProvider<PasswordRepository>(
        create: _passwordRepositoryBuilder,
        child: RepositoryProvider<LogRepository>(
          create: _logRepositoryBuilder,
          child: RepositoryProvider<IpAddressRepository>(
            create: _ipAddressRepositoryBuilder,
            child: RepositoryProvider<DataChangeRepository>(
              create: _dataChangeRepositoryBuilder,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  UserRepository _userRepositoryBuilder(BuildContext context) {
    return UserRepository();
  }

  PasswordRepository _passwordRepositoryBuilder(BuildContext context) {
    return PasswordRepository();
  }

  LogRepository _logRepositoryBuilder(BuildContext context) {
    return LogRepository();
  }

  IpAddressRepository _ipAddressRepositoryBuilder(BuildContext context) {
    return IpAddressRepository();
  }

  DataChangeRepository _dataChangeRepositoryBuilder(BuildContext context) {
    return DataChangeRepository();
  }
}

/// A helper class that injects services into widget tree.
class ServiceProviders extends StatelessWidget {
  /// Creates service providers.
  const ServiceProviders({Key key, @required this.child}) : super(key: key);

  /// A child of this widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<DataChangeService>(
      create: _dataChangeServiceBuilder,
      child: RepositoryProvider<PasswordService>(
        create: _passwordServiceBuilder,
        child: RepositoryProvider<UserService>(
          create: _userServiceBuilder,
          child: child,
        ),
      ),
    );
  }

  UserService _userServiceBuilder(BuildContext context) {
    return UserService(
      RepositoryProvider.of<UserRepository>(context),
      RepositoryProvider.of<PasswordRepository>(context),
      RepositoryProvider.of<LogRepository>(context),
      RepositoryProvider.of<IpAddressRepository>(context),
      RepositoryProvider.of<PasswordService>(context),
      RandomValuesGenerator(),
    );
  }

  PasswordService _passwordServiceBuilder(BuildContext context) {
    return PasswordService(
      RepositoryProvider.of<PasswordRepository>(context),
      RepositoryProvider.of<UserRepository>(context),
      RepositoryProvider.of<DataChangeService>(context),
      RandomValuesGenerator(),
    );
  }

  DataChangeService _dataChangeServiceBuilder(BuildContext context) {
    return DataChangeService(
      RepositoryProvider.of<DataChangeRepository>(context),
      RepositoryProvider.of<UserRepository>(context),
      RepositoryProvider.of<PasswordRepository>(context),
    );
  }
}
