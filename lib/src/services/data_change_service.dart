import 'package:clock/clock.dart';
import 'package:meta/meta.dart';

import '../data/models/models.dart';
import '../repositories/data_change_repository.dart';
import '../repositories/repositories.dart';
import '../utils/activity_type.dart';

/// A data change service layer.
class DataChangeService {
  /// Creates the data change service.
  DataChangeService(this._dataChangeRepository, this._userRepository, {Clock clock})
      : _clock = clock ?? const Clock();

  final DataChangeRepository _dataChangeRepository;
  final UserRepository _userRepository;

  final Clock _clock;

  /// Creates new data change.
  Future<bool> createDataChange({@required ActivityType activityType,
    @required int userId,
    @required int passwordAfterChangeId,
    @required int passwordBeforeChangeId}) async {
    final int millisecondsSinceEpoch = _clock
        .now()
        .millisecondsSinceEpoch;

    if (passwordBeforeChangeId != null) {
      final List<DataChange> dataChanges = await _dataChangeRepository.getDataChangesByPasswordId(passwordBeforeChangeId);
      for (final DataChange dataChange in dataChanges) {
        dataChange.passwordId = passwordAfterChangeId;

        if (await _dataChangeRepository.updateDataChange(dataChange) == -1) {
          return false;
        }
      }
    }

    final int createdDataChangeId = await _dataChangeRepository.createDataChange(
      DataChange(
        userId: userId,
        passwordId: passwordAfterChangeId,
        presentRecordId: passwordAfterChangeId,
        previousRecordId: passwordBeforeChangeId,
        actionType: activityType.parseValueToString(),
        changeTime: millisecondsSinceEpoch,
      ),
    );

    return createdDataChangeId > 0;
  }

  /// Gets user data changes.
  Future<List<DataChange>> getUserDataChanges({@required String username}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return <DataChange>[];
    }

    final List<DataChange> userDataChanges = await _dataChangeRepository.getDataChangesByUserId(user.id);

    return userDataChanges;
  }

  /// Gets password data changes.
  Future<List<DataChange>> getPasswordChanges({@required int passwordId}) async {
    return await _dataChangeRepository.getDataChangesByPasswordId(passwordId);
  }
}
