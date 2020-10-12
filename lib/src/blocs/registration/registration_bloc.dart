import 'dart:async';

import 'package:bloc/bloc.dart';

import 'registration.dart';

/// A BLoC class managing registration states.
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  /// Creates registration states managing.
  RegistrationBloc() : super(RegistrationInvisibleState());

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
  }

  Stream<RegistrationState> _mapShowToState(ShowRegistration event) async* {
    yield RegistrationVisibleState();
  }

  Stream<RegistrationState> _mapHideToState(HideRegistration event) async* {
    yield RegistrationInvisibleState();
  }
}
