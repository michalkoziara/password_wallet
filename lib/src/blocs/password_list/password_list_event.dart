import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/models/models.dart';

/// A class representing a password list event.
@immutable
abstract class PasswordListEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

/// A class representing a password list open event.
class PasswordListOpenEvent extends PasswordListEvent {
  /// Creates a password list open event.
  PasswordListOpenEvent({@required this.username});

  /// The user's username.
  final String username;

  @override
  List<Object> get props => <Object>[username];
}

/// A class representing a password list item extend event.
class PasswordListItemExtendedEvent extends PasswordListEvent {
  /// Creates a password list item extend event.
  PasswordListItemExtendedEvent({@required this.passwords, @required this.index});

  /// The list of passwords.
  final List<Password> passwords;

  /// The index of expanded item.
  final int index;

  @override
  List<Object> get props => <Object>[passwords, index];
}

/// A class representing the password display event.
class PasswordDisplayEvent extends PasswordListEvent {
  /// Creates a password list item extend event.
  PasswordDisplayEvent({@required this.passwords, @required this.index, @required this.id, @required this.password});

  /// The list of passwords.
  final List<Password> passwords;

  /// The index of expanded item.
  final int index;

  /// The ID of password.
  final int id;

  /// The user's profile password.
  final String password;

  @override
  List<Object> get props => <Object>[passwords, index, id, password];
}
