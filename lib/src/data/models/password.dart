/// A class representing stored password.
class Password {
  /// Creates password.
  Password({
    this.id,
    this.userId,
    this.ownerPasswordId,
    this.isSharedUpdated,
    this.isArchived,
    this.isDeleted,
    this.password,
    this.vector,
    this.webAddress,
    this.description,
    this.login,
  });

  /// Creates password from map.
  factory Password.fromMap(Map<String, dynamic> data) {
    return Password(
      id: data['id'] as int,
      userId: data['userId'] as int,
      ownerPasswordId: data['ownerPasswordId'] as int,
      isSharedUpdated: data['isSharedUpdated'] == 'true',
      isArchived: data['isArchived'] == 'true',
      isDeleted: data['isDeleted'] == 'true',
      password: data['password'] as String,
      vector: data['vector'] as String,
      webAddress: data['webAddress'] as String,
      description: data['description'] as String,
      login: data['login'] as String,
    );
  }

  /// Clones this password.
  Password.copy(Password other)
      : this(
          id: other.id,
          userId: other.userId,
          ownerPasswordId: other.ownerPasswordId,
          isSharedUpdated: other.isSharedUpdated,
          isArchived: other.isArchived,
          isDeleted: other.isDeleted,
          password: other.password,
          vector: other.vector,
          webAddress: other.webAddress,
          description: other.description,
          login: other.login,
        );

  /// Creates map based on this password.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'ownerPasswordId': ownerPasswordId,
      'isSharedUpdated': isSharedUpdated.toString(),
      'isArchived': isArchived.toString(),
      'isDeleted': isDeleted.toString(),
      'password': password,
      'vector': vector,
      'webAddress': webAddress,
      'description': description,
      'login': login
    };
  }

  /// The index of this password.
  int id;

  /// The index of related user.
  int userId;

  /// The index of related owner's password.
  int ownerPasswordId;

  /// The flag that indicated if shared password should be updated.
  bool isSharedUpdated;

  /// The flag that indicated if password is archived.
  bool isArchived;

  /// The flag that indicated if password is deleted.
  bool isDeleted;

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

  @override
  String toString() {
    return '$webAddress\n'
        '$login\n'
        '$description';
  }
}
