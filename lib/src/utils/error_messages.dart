/// A helper class containing constant error messages.
class ErrorMessages {
  /// The error message displayed when user creation failed.
  static const String userCreationFailureMessage =
      'User could not be created, please try again';

  /// The error message displayed when user already exists.
  static const String existingUserFailureMessage =
      'User with this username already exists, please try again';

  /// The error message displayed when a non-existent user attempts to sign in.
  static const String nonExistentUserFailureMessage =
      'User with this username does not exist, please try again';

  /// The error message displayed when a user passed invalid credentials.
  static const String userSigningFailureMessage =
      'Password is incorrect, please try again';
}
