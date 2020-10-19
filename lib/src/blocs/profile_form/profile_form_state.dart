import 'package:meta/meta.dart';

/// A class representing a profile form state.
@immutable
abstract class ProfileFormState {}

/// A class representing the state of a completed profile form.
class ProfileFormCompletedState extends ProfileFormState {
  /// Creates a completed profile form state.
  ProfileFormCompletedState({@required this.password});

  /// The new password of user that is signed in.
  final String password;
}

/// A class representing the state of a not completed profile form.
class ProfileFormNotCompletedState extends ProfileFormState {}

/// A class representing the state of a incorrectly completed profile form.
class ProfileFormIncorrectState extends ProfileFormState {
  /// Creates an error state.
  ProfileFormIncorrectState({@required this.message});

  /// The error message.
  final String message;
}
