/// A class representing stored data change.
class DataChange {
  /// Creates data change.
  DataChange({
    this.id,
    this.userId,
    this.passwordId,
    this.previousRecordId,
    this.presentRecordId,
    this.actionType,
    this.changeTime,
  });

  /// Creates data change from map.
  factory DataChange.fromMap(Map<String, dynamic> data) {
    return DataChange(
      id: data['id'] as int,
      userId: data['userId'] as int,
      passwordId: data['passwordId'] as int,
      previousRecordId: data['previousRecordId'] as int,
      presentRecordId: data['presentRecordId'] as int,
      actionType: data['actionType'] as String,
      changeTime: data['changeTime'] as int,
    );
  }

  /// Clones this data change.
  DataChange.copy(DataChange other)
      : this(
    id: other.id,
    userId: other.userId,
    passwordId: other.passwordId,
    previousRecordId: other.previousRecordId,
    presentRecordId: other.presentRecordId,
    actionType: other.actionType,
    changeTime: other.changeTime,
  );

  /// Creates map based on this data change.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'passwordId': passwordId,
      'previousRecordId': previousRecordId,
      'presentRecordId': presentRecordId,
      'actionType': actionType,
      'changeTime': changeTime,
    };
  }

  /// The index of this data change.
  int id;

  /// The index of related user.
  int userId;

  /// The index of related password.
  int passwordId;

  /// The index of related password before change.
  int previousRecordId;

  /// The index of related password after change.
  int presentRecordId;

  /// The type of user activity.
  String actionType;

  /// The time and date of the user activity.
  int changeTime;

  @override
  String toString() {
    return 'DataChange{'
        'id: $id, '
        'userId: $userId, '
        'passwordId: $passwordId, '
        'previousRecordId: $previousRecordId, '
        'presentRecordId: $presentRecordId, '
        'actionType: $actionType, '
        'changeTime: $changeTime'
        '}';
  }
}
