import 'package:meta/meta.dart';

/// A class representing registration event.
@immutable
abstract class RegistrationEvent {}

/// A class representing registration show event.
class ShowRegistration extends RegistrationEvent {}

/// A class representing registration hide event.
class HideRegistration extends RegistrationEvent {}