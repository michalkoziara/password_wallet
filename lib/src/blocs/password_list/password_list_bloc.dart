import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import '../../data/models/models.dart' show Password;
import '../../services/services.dart' show PasswordService;
import '../../utils/error_messages.dart';
import '../../utils/failure.dart';
import 'password_list.dart';

/// A BLoC class managing password list states.
class PasswordListBloc extends Bloc<PasswordListEvent, PasswordListState> {
  /// Creates password list states managing.
  PasswordListBloc(this._passwordService) : super(PasswordListNotPopulatedState());

  final PasswordService _passwordService;

  @override
  String toString() => 'PasswordListBloc';

  @override
  Stream<PasswordListState> mapEventToState(PasswordListEvent event) async* {
    if (event is PasswordListOpenEvent) {
      yield* _mapOpenToState(event);
    }

    if (event is PasswordListItemExtendedEvent) {
      yield* _mapExtendToState(event);
    }

    if (event is PasswordDisplayEvent) {
      yield* _mapDisplayToState(event);
    }
  }

  Stream<PasswordListState> _mapExtendToState(PasswordListItemExtendedEvent event) async* {
    yield PasswordListItemExpandedState(passwords: event.passwords, index: event.index);
  }

  Stream<PasswordListState> _mapDisplayToState(PasswordDisplayEvent event) async* {
    final Either<Failure, String> failureOrPassword =
        await _passwordService.getPassword(id: event.id, userPassword: event.password, isRegistered: true);

    yield failureOrPassword.fold(
      (Failure failure) => PasswordListErrorState(message: _mapFailureToMessage(failure)),
      (String password) => PasswordListVisiblePasswordState(
        passwords: event.passwords,
        index: event.index,
        password: password,
      ),
    );
  }

  Stream<PasswordListState> _mapOpenToState(PasswordListOpenEvent event) async* {
    final Either<Failure, List<Password>> failureOrList = await _passwordService.getActivePasswords(
      username: event.username,
    );

    yield* _eitherPopulatedOrFailureState(failureOrList);
  }

  Stream<PasswordListState> _eitherPopulatedOrFailureState(Either<Failure, List<Password>> failureOrList) async* {
    yield failureOrList.fold(
      (Failure failure) => PasswordListErrorState(message: _mapFailureToMessage(failure)),
      (List<Password> passwords) => PasswordListPopulatedState(passwords: passwords),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NonExistentUserFailure:
        return ErrorMessages.incorrectUserPasswordCreationFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
