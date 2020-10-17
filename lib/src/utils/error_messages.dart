/// A helper class containing constant error messages.
class ErrorMessages {
  /// The error message displayed when user creation failed.
  static const String userCreationFailureMessage = 'User could not be created, please try again.';

  /// The error message displayed when user already exists.
  static const String alreadyExistingUserFailureMessage = 'User with this username already exists, please try again.';

  /// The error message displayed when a non-existent user attempts to sign in.
  static const String nonExistentUserFailureMessage = 'User with this username does not exist, please try again.';

  /// The error message displayed when a user passed invalid credentials.
  static const String userSigningFailureMessage = 'Password is incorrect, please try again.';

  /// The error message displayed when user incorrectly completed password form.
  static const String passwordCreationFailure = 'Provided information is incorrect, please try again.';

  /// The error message displayed when user is incorrect during password creation.
  static const String incorrectUserPasswordCreationFailure = 'Your user profile is incorrect, please log in again.';
}
