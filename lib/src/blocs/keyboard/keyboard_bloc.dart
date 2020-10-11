import 'dart:async';

import 'package:bloc/bloc.dart';

import 'keyboard.dart';

/// A BLoC class managing keyboard states.
class KeyboardBloc extends Bloc<KeyboardEvent, KeyboardState> {
  /// Creates keyboard states managing.
  KeyboardBloc() : super(KeyboardInvisibleState());

  @override
  String toString() => 'SingleGameBloc';

  @override
  Stream<KeyboardState> mapEventToState(KeyboardEvent event) async* {
    if (event is ShowKeyboard) {
      yield* _mapShowToState(event);
    }

    if (event is HideKeyboard) {
      yield* _mapHideToState(event);
    }
  }

  Stream<KeyboardState> _mapShowToState(ShowKeyboard event) async* {
    yield KeyboardVisibleState();
  }

  Stream<KeyboardState> _mapHideToState(HideKeyboard event) async* {
    yield KeyboardInvisibleState();
  }
}
