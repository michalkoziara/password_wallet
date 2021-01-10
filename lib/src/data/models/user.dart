/// A class representing a user.
class User {
  /// Creates user.
  User({
    this.id,
    this.username,
    this.passwordHash,
    this.salt,
    this.isPasswordKeptAsHash,
  });

  /// Creates user from map.
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] as int,
      username: data['username'] as String,
      passwordHash: data['passwordHash'] as String,
      salt: data['salt'] as String,
      isPasswordKeptAsHash: data['isPasswordKeptAsHash'] == 'true',
    );
  }

  /// Clones this user.
  User.copy(User other)
      : this(
          id: other.id,
          username: other.username,
          passwordHash: other.passwordHash,
          salt: other.salt,
          isPasswordKeptAsHash: other.isPasswordKeptAsHash,
        );

  /// Creates map based on this user.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'salt': salt,
      'isPasswordKeptAsHash': isPasswordKeptAsHash.toString()
    };
  }

  /// The index of this user.
  int id;

  /// The name of this user.
  String username;

  /// The hash of this user's password.
  String passwordHash;

  /// The salt that was used to encrypt this user's password.
  String salt;

  /// The flag that represents if password is kept as a hash.
  bool isPasswordKeptAsHash;

  @override
  String toString() {
    return 'User{'
        'id: $id, '
        'username: $username, '
        'passwordHash: $passwordHash, '
        'salt: $salt, '
        'isPasswordKeptAsHash: $isPasswordKeptAsHash'
        '}';
  }
}
