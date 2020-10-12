/// A class representing stored password.
class Password {
  /// Creates password.
  Password(this.password, this.webAddress, this.description, this.login);

  /// The hash of this password.
  String password;

  /// The web address of page that this password is used to.
  String webAddress;

  /// The description of this password.
  String description;

  /// The login that is used with this password.
  String login;
}