import 'package:equatable/equatable.dart';

/// A class representing a failure.
abstract class Failure extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

/// A class representing failure about existing user.
class ExistingUserFailure extends Failure {}

/// A class representing user creation failure.
class UserCreationFailure extends Failure {}

/// A Class representing the failure caused by a login attempt from a non-existent user.
class NonExistentUserFailure extends Failure{}

/// A class representing user signing failure.
class UserSigningFailure extends Failure {}