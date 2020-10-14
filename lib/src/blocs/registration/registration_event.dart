import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A class representing a registration event.
@immutable
abstract class RegistrationEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

/// A class representing a registration show event.
class ShowRegistration extends RegistrationEvent {}

/// A class representing a registration hide event.
class HideRegistration extends RegistrationEvent {}

/// A class representing a registration complete event.
class CompleteRegistration extends RegistrationEvent {
  /// Creates a complete registration event.
  CompleteRegistration({@required this.username, @required this.password, @required this.isEncryptingAlgorithmSha});

  /// The username passed during this registration event.
  final String username;

  /// The password passed during this registration event.
  final String password;

  /// The encryption algorithm flag passed during this registration event.
  final bool isEncryptingAlgorithmSha;

  @override
  List<Object> get props => <Object>[username, password, isEncryptingAlgorithmSha];
}

/// A class representing a login complete event.
class CompleteLogin extends RegistrationEvent {
  /// Creates a complete login event.
  CompleteLogin({@required this.username, @required this.password});

  /// The username passed during this login event.
  final String username;

  /// The password passed during this login event.
  final String password;

  @override
  List<Object> get props => <Object>[username, password];
}
