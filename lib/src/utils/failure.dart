import 'package:equatable/equatable.dart';

/// A class representing a failure.
abstract class Failure extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

/// A class representing failure about already existing user.
class AlreadyExistingUserFailure extends Failure {}

/// A class representing user creation failure.
class UserCreationFailure extends Failure {}

/// A class representing user's profile update failure.
class UserUpdateFailure extends Failure {}

/// A class representing failure caused by an attempt from a non-existent user.
class NonExistentUserFailure extends Failure{}

/// A class representing user signing failure.
class UserSigningFailure extends Failure {}

/// A class representing password creation failure.
class PasswordCreationFailure extends Failure {}

/// A class representing an IP address not found failure.
class IpAddressNotFoundFailure extends Failure {}

/// A class representing log creation failure.
class LogCreationFailure extends Failure {}

/// A class representing blocked user login failure.
class BlockedUserLoginFailure extends Failure {}

/// A class representing blocked IP address login failure.
class BlockedIpAddressLoginFailure extends Failure {}