import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A class representing a password form event.
@immutable
class PasswordFormEvent extends Equatable {
  /// Creates a password form event.
  const PasswordFormEvent(
      {@required this.login,
      @required this.webAddress,
      @required this.password,
      @required this.description,
      @required this.username,
      @required this.userPassword});

  /// The login passed by user during a password form.
  final String login;

  /// The web address passed by user during a password form.
  final String webAddress;

  /// The password passed by user during a password form.
  final String password;

  /// The description passed by user during a password form.
  final String description;

  /// The user's username.
  final String username;

  /// The user's profile password.
  final String userPassword;

  @override
  List<Object> get props => <Object>[login, webAddress, password, description, username, userPassword];
}
