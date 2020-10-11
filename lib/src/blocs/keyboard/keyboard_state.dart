import 'package:meta/meta.dart';

/// A class representing keyboard state.
@immutable
abstract class KeyboardState {}

/// A class representing keyboard visibility state.
class KeyboardVisibleState extends KeyboardState {}

/// A class representing keyboard invisibility state.
class KeyboardInvisibleState extends KeyboardState {}
