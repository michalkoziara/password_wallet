import '../data/daos/daos.dart' show UserDao;
import '../data/models/models.dart' show User;

/// A user data access repository.
class UserRepository {
  /// The user data access object.
  final UserDao _userDao = UserDao();

  /// Gets users based on query.
  Future<List<User>> getUsers({String query}) => _userDao.getUsers(query: query);

  /// Gets users with given ID.
  Future<User> getUser(int id) => _userDao.getUser(id: id);

  /// Creates user.
  Future<int> createUser(User user) => _userDao.createUser(user);

  /// Updates user.
  Future<int> updateUser(User user) => _userDao.updateUser(user);

  /// Deletes user with given ID.
  Future<int> deleteUser(int id) => _userDao.deleteUser(id);
}
