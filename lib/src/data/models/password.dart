/// A class representing stored password.
class Password {
  /// Creates password.
  Password({this.id, this.userId, this.password, this.vector, this.webAddress, this.description, this.login});

  /// Creates password from map.
  factory Password.fromMap(Map<String, dynamic> data) {
    return Password(
      id: data['id'] as int,
      userId: data['userId'] as int,
      password: data['password'] as String,
      vector: data['vector'] as String,
      webAddress: data['webAddress'] as String,
      description: data['description'] as String,
      login: data['login'] as String,
    );
  }

  /// Creates map based on this password.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'password': password,
      'vector': vector,
      'webAddress': webAddress,
      'description': description,
      'login': login
    };
  }

  /// The index of this user.
  int id;

  /// The index of this user.
  int userId;

  /// The hash of this password.
  String password;

  /// The initialization vector used in encrypting.
  String vector;

  /// The web address of page that this password is used to.
  String webAddress;

  /// The description of this password.
  String description;

  /// The login that is used with this password.
  String login;
}
