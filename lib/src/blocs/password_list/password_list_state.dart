import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/models/models.dart';

/// A class representing a password list state.
@immutable
abstract class PasswordListState extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

/// A class representing the state of a not populated password list.
class PasswordListNotPopulatedState extends PasswordListState {}

/// A class representing the state of created a password list.
class PasswordListSuccessState extends PasswordListState {
  /// Creates a created password list state.
  PasswordListSuccessState({@required this.passwords});

  /// The list of passwords.
  final List<Password> passwords;

  @override
  List<Object> get props => <Object>[passwords];
}

/// A class representing the state of populated password list.
class PasswordListPopulatedState extends PasswordListSuccessState {
  /// Creates a populated password list state.
  PasswordListPopulatedState({@required List<Password> passwords}) : super(passwords: passwords);
}

/// A class representing a state of password list with expanded item.
class PasswordListItemExpandedState extends PasswordListSuccessState {
  /// Creates an extended list item state.
  PasswordListItemExpandedState({@required List<Password> passwords, @required this.index})
      : super(passwords: passwords);

  /// The index of expanded item.
  final int index;

  @override
  List<Object> get props => <Object>[passwords, index];
}

/// A class representing a state of password list with visible password.
class PasswordListVisiblePasswordState extends PasswordListItemExpandedState {
  /// Creates a visible password state.
  PasswordListVisiblePasswordState({@required List<Password> passwords, @required int index, @required this.password})
      : super(passwords: passwords, index: index);

  /// The visible password.
  final String password;

  @override
  List<Object> get props => <Object>[passwords, index, password];
}

/// A class representing the failure state of a password list.
class PasswordListErrorState extends PasswordListState {
  /// Creates an error state.
  PasswordListErrorState({@required this.message});

  /// The error message.
  final String message;

  @override
  List<Object> get props => <Object>[message];
}
