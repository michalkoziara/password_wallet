import '../data/daos/log_dao.dart';
import '../data/models/log.dart';

/// An log data access repository.
class LogRepository {
  /// Creates log data access repository.
  LogRepository({LogDao logDao}) : _logDao = logDao ?? LogDao();

  /// The log data access object.
  final LogDao _logDao;

  /// Gets logs with given user ID.
  Future<List<Log>> getLogsByUserId(int userId) => _logDao.getLogsByUserId(userId: userId);

  /// Gets logs with given user ID and IP address.
  Future<List<Log>> getLogsByUserIdAndIpAddress(int userId, String ipAddress) =>
      _logDao.getLogsByUserIdAndIpAddress(userId: userId, ipAddress: ipAddress);

  /// Creates log.
  Future<int> createLog(Log log) => _logDao.createLog(log);

  /// Updates log.
  Future<int> updateLog(Log log) => _logDao.updateLog(log);
}
