import 'package:meta/meta.dart';

/// A class representing a password form state.
@immutable
abstract class PasswordFormState {}

/// A class representing the status of a completed password form.
class PasswordFormCompletedState extends PasswordFormState {}

/// A class representing the status of a not completed password form.
class PasswordFormNotCompletedState extends PasswordFormState {}

/// A class representing the status of a incorrectly completed password form.
class PasswordFormIncorrectState extends PasswordFormState {
  /// Creates an error state.
  PasswordFormIncorrectState({@required this.message});

  /// The error message.
  final String message;
}
