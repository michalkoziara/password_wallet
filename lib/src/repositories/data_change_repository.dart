import '../data/daos/data_change_dao.dart';
import '../data/models/data_change.dart';

/// A data change access repository.
class DataChangeRepository {
  /// Creates data change access repository.
  DataChangeRepository({DataChangeDao dataChangeDao}) : _dataChangeDao = dataChangeDao ?? DataChangeDao();

  /// The data change access object.
  final DataChangeDao _dataChangeDao;

  /// Gets data changes with given user ID.
  Future<List<DataChange>> getDataChangesByUserId(int userId) => _dataChangeDao.getDataChangesByUserId(userId: userId);

  /// Gets data changes with given password ID.
  Future<List<DataChange>> getDataChangesByPasswordId(int passwordId) =>
      _dataChangeDao.getDataChangesByPasswordId(passwordId: passwordId);

  /// Creates data change.
  Future<int> createDataChange(DataChange dataChange) => _dataChangeDao.createDataChange(dataChange);

  /// Updates data change.
  Future<int> updateDataChange(DataChange dataChange) => _dataChangeDao.updateDataChange(dataChange);
}
