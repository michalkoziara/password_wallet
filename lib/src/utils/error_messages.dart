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
  static const String passwordCreationFailureMessage = 'Provided information is incorrect, please try again.';

  /// The error message displayed when user is incorrect during password creation.
  static const String incorrectUserPasswordCreationFailureMessage =
      'Your user profile is incorrect, please log in again.';

  /// The error message displayed when user profile update failed.
  static const String userProfileUpdateFailureMessage = 'User profile update failed, please try again.';

  /// The error message displayed when public IP address cannot be obtained.
  static const String ipAddressNotFoundFailureMessage =
      'Please ensure that device is connected to the Internet and try again.';

  /// The error message displayed when a login log could not be added.
  static const String loginLogCreationFailureMessage =
      'Application could not provide a safe connection, please try again.';

  /// The error message displayed when an IP address is blocked.
  static const String blockedIpAddressMessage = 'Network that you are using is prohibited, please try again.';

  /// The error message displayed when a user is blocked.
  static const String blockedUserMessage = 'Your user account is blocked, please try again later.';

  /// The error message displayed when unblocking an IP address failed.
  static const String unblockingIpAddressFailureMessage = 'IP address could not be unblocked, please try again later.';
}
