/// A class representing a login log.
class Log {
  /// Creates a log.
  Log({this.id, this.userId, this.isSuccessful, this.ipAddress, this.isUnblocked, this.loginTime});

  /// Creates log from map.
  factory Log.fromMap(Map<String, dynamic> data) {
    return Log(
      id: data['id'] as int,
      userId: data['userId'] as int,
      isSuccessful: data['isSuccessful'] == 'true',
      ipAddress: data['ipAddress'] as String,
      isUnblocked: data['isUnblocked'] == 'true',
      loginTime: data['loginTime'] as int,
    );
  }

  /// Clones this log.
  Log.copy(Log other)
      : this(
          id: other.id,
          userId: other.userId,
          isSuccessful: other.isSuccessful,
          ipAddress: other.ipAddress,
          isUnblocked: other.isUnblocked,
          loginTime: other.loginTime,
        );

  /// Creates map based on this log.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'isSuccessful': isSuccessful.toString(),
      'ipAddress': ipAddress,
      'isUnblocked': isUnblocked.toString(),
      'loginTime': loginTime
    };
  }

  /// The index of this user.
  int id;

  /// The index of this user.
  int userId;

  /// The flag that indicates if a login was successful.
  bool isSuccessful;

  /// The IP address that user connected from.
  String ipAddress;

  /// The flag that indicates if an IP address is unblocked.
  bool isUnblocked;

  /// The time and date of the login.
  int loginTime;

  @override
  String toString() {
    return 'Password{'
        'id: $id, '
        'userId: $userId, '
        'isSuccessful: $isSuccessful, '
        'ipAddress: $ipAddress, '
        'isUnblocked: $isUnblocked, '
        'loginTime: $loginTime'
        '}';
  }
}
