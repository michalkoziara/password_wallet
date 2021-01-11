import '../data/daos/daos.dart' show PasswordDao;
import '../data/models/models.dart' show Password;

/// A password data access repository.
class PasswordRepository {
  /// Creates password data access repository.
  PasswordRepository({PasswordDao passwordDao}) : _passwordDao = passwordDao ?? PasswordDao();

  /// The password data access object.
  final PasswordDao _passwordDao;

  /// Gets passwords with given user ID.
  Future<List<Password>> getPasswordsByUserId(int userId) => _passwordDao.getPasswordsByUserId(userId: userId);

  /// Gets password with given ID.
  Future<Password> getPasswordById(int id) => _passwordDao.getPasswordById(id: id);

  /// Creates password.
  Future<int> createPassword(Password password) => _passwordDao.createPassword(password);

  /// Updates passwords.
  Future<List<dynamic>> updatePasswords(List<Password> passwords) => _passwordDao.updatePasswords(passwords);

  /// Deletes password with given ID.
  Future<int> deletePasswordById(int id) => _passwordDao.deletePasswordById(id: id);

  /// Updates password.
  Future<int> updatePassword(Password password) => _passwordDao.updatePassword(password);

  /// Gets passwords with given user ID that need update.
  Future<List<Password>> getPasswordsByUserIdAndUpdateStatus(int userId) =>
      _passwordDao.getPasswordsByUserIdAndUpdateStatus(userId: userId);

  /// Gets passwords by owner password's ID.
  Future<List<Password>> getPasswordsByOwnerPasswordId(int ownerPasswordId) =>
      _passwordDao.getPasswordsByOwnerPasswordId(ownerPasswordId: ownerPasswordId);
}
