import 'package:meta/meta.dart';

/// A class representing a registration state.
@immutable
abstract class RegistrationState {}

/// A class representing a registration visibility state.
class RegistrationVisibleState extends RegistrationState {}

/// A class representing a registration invisibility state.
class RegistrationInvisibleState extends RegistrationState {}

/// A class representing a registration completion state.
class RegistrationCompletionState extends RegistrationState {}

/// A class representing a login completion state.
class LoginCompletionState extends RegistrationState {}

/// A class representing an error state.
class ErrorState extends RegistrationState {
  /// Creates an error state.
  ErrorState({@required this.message});

  /// The error message.
  final String message;
}

/// A class representing a registration error state.
class RegistrationErrorState extends ErrorState {
  /// Creates registration error state.
  RegistrationErrorState({@required String message}) : super(message: message);
}

/// A class representing a login error state.
class LoginErrorState extends ErrorState {
  /// Creates a login error state.
  LoginErrorState({@required String message}) : super(message: message);
}
