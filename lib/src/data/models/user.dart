/// A class representing a user.
class User {
  /// Creates user.
  User({this.id, this.login, this.passwordHash, this.salt, this.isPasswordKeptAsHash});

  /// Creates user from map.
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] as int,
      login: data['login'] as String,
      passwordHash: data['passwordHash'] as String,
      salt: data['salt'] as String,
      isPasswordKeptAsHash: data['isPasswordKeptAsHash'] as bool,
    );
  }

  /// Creates map based on this user.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'login': login,
      'passwordHash': passwordHash,
      'salt': salt,
      'isPasswordKeptAsHash': isPasswordKeptAsHash
    };
  }

  /// The index of this user.
  int id;

  /// The login of this user.
  String login;

  /// The hash of this user's password.
  String passwordHash;

  /// The salt that was used to encrypt this user's password.
  String salt;

  /// The flag that represents if password is kept as a hash.
  bool isPasswordKeptAsHash;
}
