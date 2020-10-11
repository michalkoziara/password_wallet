import 'package:meta/meta.dart';

/// A class representing keyboard event.
@immutable
abstract class KeyboardEvent {}

/// A class representing keyboard show event.
class ShowKeyboard extends KeyboardEvent {}

/// A class representing keyboard hide event.
class HideKeyboard extends KeyboardEvent {}