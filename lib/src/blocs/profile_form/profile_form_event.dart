import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A class representing a profile form event.
@immutable
class ProfileFormEvent extends Equatable {
  /// Creates a profile form event.
  const ProfileFormEvent({@required this.username, @required this.oldPassword, @required this.newPassword});

  /// The user's username.
  final String username;

  /// The user's profile old password.
  final String oldPassword;

  /// The user's profile new password.
  final String newPassword;

  @override
  List<Object> get props => <Object>[username, oldPassword, newPassword];
}
