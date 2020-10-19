import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import '../../services/services.dart' show UserService;
import '../../utils/error_messages.dart';
import '../../utils/failure.dart';
import 'profile_form.dart';

/// A BLoC class managing profile form states.
class ProfileFormBloc extends Bloc<ProfileFormEvent, ProfileFormState> {
  /// Creates profile form states managing.
  ProfileFormBloc(this._userService) : super(ProfileFormNotCompletedState());

  final UserService _userService;

  @override
  String toString() => 'ProfileFormBloc';

  @override
  Stream<ProfileFormState> mapEventToState(ProfileFormEvent event) async* {
    yield* _mapEventToState(event);
  }

  Stream<ProfileFormState> _mapEventToState(ProfileFormEvent event) async* {
    final Either<Failure, void> failureOrNull = await _userService.changePassword(
      newUserPassword: event.newPassword,
      oldUserPassword: event.oldPassword,
      username: event.username,
    );

    yield failureOrNull.fold(
      (Failure failure) => ProfileFormIncorrectState(message: _mapFailureToMessage(failure)),
      (void _) => ProfileFormCompletedState(password: event.newPassword),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case UserUpdateFailure:
        return ErrorMessages.userProfileUpdateFailureMessage;
      case NonExistentUserFailure:
        return ErrorMessages.incorrectUserPasswordCreationFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
