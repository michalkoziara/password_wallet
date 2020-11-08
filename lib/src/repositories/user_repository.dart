import '../data/daos/daos.dart' show UserDao;
import '../data/models/models.dart' show User;

/// A user data access repository.
class UserRepository {
  /// Creates user data access repository.
  UserRepository({UserDao userDao}) : _userDao = userDao ?? UserDao();

  /// The user data access object.
  final UserDao _userDao;

  /// Gets user with given username.
  Future<User> getUserByUsername(String username) => _userDao.getUserByUsername(username: username);

  /// Creates user.
  Future<int> createUser(User user) => _userDao.createUser(user);

  /// Updates user.
  Future<int> updateUser(User user) => _userDao.updateUser(user);
}
