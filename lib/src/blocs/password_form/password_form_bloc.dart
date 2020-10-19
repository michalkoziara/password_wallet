import 'dart:async';

import 'package:bloc/bloc.dart' show Bloc;
import 'package:dartz/dartz.dart' show Either;

import '../../services/services.dart' show PasswordService;
import '../../utils/error_messages.dart';
import '../../utils/failure.dart';
import 'password_form.dart';

/// A BLoC class managing password form states.
class PasswordFormBloc extends Bloc<PasswordFormEvent, PasswordFormState> {
  /// Creates password form states managing.
  PasswordFormBloc(this._passwordService) : super(PasswordFormNotCompletedState());

  final PasswordService _passwordService;

  @override
  String toString() => 'PasswordFormBloc';

  @override
  Stream<PasswordFormState> mapEventToState(PasswordFormEvent event) async* {
    yield* _mapEventToState(event);
  }

  Stream<PasswordFormState> _mapEventToState(PasswordFormEvent event) async* {
    final Either<Failure, void> failureOrNull = await _passwordService.addPassword(
      login: event.login,
      webAddress: event.webAddress,
      password: event.password,
      description: event.description,
      username: event.username,
      userPassword: event.userPassword,
    );

    yield* _eitherCompletedOrFailureState(failureOrNull);
  }

  Stream<PasswordFormState> _eitherCompletedOrFailureState(Either<Failure, void> failureOrNull) async* {
    yield failureOrNull.fold(
      (Failure failure) => PasswordFormIncorrectState(message: _mapFailureToMessage(failure)),
      (void _) => PasswordFormCompletedState(),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case PasswordCreationFailure:
        return ErrorMessages.passwordCreationFailureMessage;
      case NonExistentUserFailure:
        return ErrorMessages.incorrectUserPasswordCreationFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
