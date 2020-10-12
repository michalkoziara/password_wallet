import 'package:meta/meta.dart';

/// A class representing registration state.
@immutable
abstract class RegistrationState {}

/// A class representing registration visibility state.
class RegistrationVisibleState extends RegistrationState {}

/// A class representing registration invisibility state.
class RegistrationInvisibleState extends RegistrationState {}
