import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import '../../services/services.dart' show UserService;
import '../../utils/error_messages.dart';
import '../../utils/failure.dart';
import 'registration.dart';

/// A BLoC class managing registration states.
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  /// Creates registration states managing.
  RegistrationBloc(this._userService) : super(RegistrationInvisibleState());

  final UserService _userService;

  @override
  String toString() => 'RegistrationBloc';

  @override
  Stream<RegistrationState> mapEventToState(RegistrationEvent event) async* {
    if (event is ShowRegistration) {
      yield* _mapShowToState(event);
    }

    if (event is HideRegistration) {
      yield* _mapHideToState(event);
    }

    if (event is CompleteRegistration) {
      yield* _mapCompleteRegistrationToState(event);
    }

    if (event is CompleteLogin) {
      yield* _mapCompleteLoginToState(event);
    }
  }

  Stream<RegistrationState> _mapShowToState(ShowRegistration event) async* {
    yield RegistrationVisibleState();
  }

  Stream<RegistrationState> _mapHideToState(HideRegistration event) async* {
    yield RegistrationInvisibleState();
  }

  Stream<RegistrationState> _mapCompleteRegistrationToState(CompleteRegistration event) async* {
    final Either<Failure, void> failureOrNull = await _userService.registerUser(
      username: event.username,
      password: event.password,
      isEncryptingAlgorithmSha: event.isEncryptingAlgorithmSha,
    );

    yield* _eitherRegisteredOrErrorState(failureOrNull);
  }

  Stream<RegistrationState> _mapCompleteLoginToState(CompleteLogin event) async* {
    final Either<Failure, void> failureOrNull =
        await _userService.checkCredentials(username: event.username, password: event.password);

    yield* _eitherLoggedOrErrorState(failureOrNull);
  }

  Stream<RegistrationState> _eitherRegisteredOrErrorState(Either<Failure, void> failureOrNull) async* {
    yield failureOrNull.fold(
      (Failure failure) => RegistrationErrorState(message: _mapFailureToMessage(failure)),
      (void _) => RegistrationCompletionState(),
    );
  }

  Stream<RegistrationState> _eitherLoggedOrErrorState(Either<Failure, void> failureOrNull) async* {
    yield failureOrNull.fold(
      (Failure failure) => LoginErrorState(message: _mapFailureToMessage(failure)),
      (void _) => LoginCompletionState(),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case UserCreationFailure:
        return ErrorMessages.userCreationFailureMessage;
      case ExistingUserFailure:
        return ErrorMessages.existingUserFailureMessage;
      case NonExistentUserFailure:
        return ErrorMessages.nonExistentUserFailureMessage;
      case UserSigningFailure:
        return ErrorMessages.userSigningFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
