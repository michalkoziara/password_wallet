import 'dart:convert';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart';

import '../data/models/models.dart';
import '../repositories/repositories.dart';
import '../utils/constants.dart';
import '../utils/failure.dart';
import '../utils/random_values_generator.dart';

/// A user service layer.
class UserService {
  /// Creates user service.
  UserService(this._userRepository, this._passwordRepository, this._logRepository, this._ipAddressRepository,
      this._randomValuesGenerator,
      {Clock clock})
      : _clock = clock ?? const Clock();

  final UserRepository _userRepository;
  final PasswordRepository _passwordRepository;
  final LogRepository _logRepository;
  final IpAddressRepository _ipAddressRepository;
  final RandomValuesGenerator _randomValuesGenerator;
  final Clock _clock;

  /// Validates user's credentials.
  Future<Either<Failure, void>> checkCredentials({@required String username, @required String password}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return Left<Failure, void>(NonExistentUserFailure());
    }

    final bool isUserBlocked = await checkUserBlock(username: username);
    if (isUserBlocked) {
      return Left<Failure, void>(BlockedUserLoginFailure());
    }

    final String ipAddress = await _ipAddressRepository.getPublicIpAddress();
    if (ipAddress == null) {
      return Left<Failure, void>(IpAddressNotFoundFailure());
    }

    final bool isUserIpBlocked = await checkIpBlock(username: username, ipAddress: ipAddress);
    if (isUserIpBlocked) {
      return Left<Failure, void>(BlockedIpAddressLoginFailure());
    }

    String hash = '';
    if (user.isPasswordKeptAsHash) {
      hash = _calculateSha512(password + user.salt + Constants.pepper);
    } else {
      hash = _calculateHmacSha512(password + Constants.pepper, user.salt);
    }

    if (hash != user.passwordHash) {
      await addLog(userId: user.id, isSuccessful: false, ipAddress: ipAddress);
      return Left<Failure, void>(UserSigningFailure());
    }

    final bool isLogCreated = await addLog(userId: user.id, isSuccessful: true, ipAddress: ipAddress);
    if (!isLogCreated) {
      return Left<Failure, void>(LogCreationFailure());
    }

    return const Right<Failure, void>(null);
  }

  /// Registers new user.
  Future<Either<Failure, void>> registerUser(
      {@required String username, @required String password, @required bool isEncryptingAlgorithmSha}) async {
    final String ipAddress = await _ipAddressRepository.getPublicIpAddress();

    if (ipAddress == null) {
      return Left<Failure, void>(IpAddressNotFoundFailure());
    }

    final User oldUser = await _userRepository.getUserByUsername(username);

    /// Checks if user with given username already exists.
    if (oldUser != null) {
      return Left<Failure, void>(AlreadyExistingUserFailure());
    }

    /// Randomly generates 256 bits.
    final String randomKey = base64.encode(_randomValuesGenerator.generateRandomBytes(256 ~/ 8));

    /// Calculates password's hash using a chosen encryption algorithm.
    String hash = '';
    if (isEncryptingAlgorithmSha) {
      /// Calculates the hash using SHA512 algorithm with random salt and pepper.
      hash = _calculateSha512(password + randomKey + Constants.pepper);
    } else {
      /// Calculates the hash using HMAC-SHA512 algorithm with random salt and pepper.
      hash = _calculateHmacSha512(password + Constants.pepper, randomKey);
    }

    /// Creates user data object.
    final User user = User(
      username: username,
      passwordHash: hash,
      salt: randomKey,
      isPasswordKeptAsHash: isEncryptingAlgorithmSha,
    );

    /// Saves user data in the database.
    final int result = await _userRepository.createUser(user);
    if (result == -1) {
      return Left<Failure, void>(UserCreationFailure());
    }

    final User registeredUser = await _userRepository.getUserByUsername(username);
    if (registeredUser == null) {
      return Left<Failure, void>(LogCreationFailure());
    }

    final bool isLogCreated = await addLog(userId: registeredUser.id, isSuccessful: true, ipAddress: ipAddress);
    if (!isLogCreated) {
      return Left<Failure, void>(LogCreationFailure());
    }

    return const Right<Failure, void>(null);
  }

  /// Changes user's profile password.
  Future<Either<Failure, void>> changePassword(
      {@required String username, @required String oldUserPassword, @required String newUserPassword}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return Left<Failure, void>(NonExistentUserFailure());
    }

    final String randomKey = base64.encode(_randomValuesGenerator.generateRandomBytes(256 ~/ 8));
    String hash = '';

    if (user.isPasswordKeptAsHash) {
      hash = _calculateSha512(newUserPassword + randomKey + Constants.pepper);
    } else {
      hash = _calculateHmacSha512(newUserPassword + Constants.pepper, randomKey);
    }

    user.passwordHash = hash;
    user.salt = randomKey;

    final int userUpdateResult = await _userRepository.updateUser(user);
    if (userUpdateResult == -1) {
      return Left<Failure, void>(UserUpdateFailure());
    }

    final List<Password> passwords = await _passwordRepository.getPasswordsByUserId(user.id);
    for (final Password password in passwords) {
      final Uint8List oldPasswordBytes = Uint8List.fromList(base64.decode(password.password));
      final Uint8List oldSecretKeyBytes = Uint8List.fromList(utf8.encode(oldUserPassword));
      final Uint8List oldInitializationVectorBytes = Uint8List.fromList(base64.decode(password.vector));

      final crypto.Digest oldSecretKeyDigest = crypto.md5.convert(oldSecretKeyBytes);
      final Uint8List oldSecretKeyDigestBytes = Uint8List.fromList(oldSecretKeyDigest.bytes);

      final PaddedBlockCipher decryptAesCipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESFastEngine()),
      );

      decryptAesCipher.init(
        false,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          ParametersWithIV<KeyParameter>(
            KeyParameter(oldSecretKeyDigestBytes),
            oldInitializationVectorBytes,
          ),
          null,
        ),
      );

      final Uint8List decryptedOldPasswordBytes = decryptAesCipher.process(oldPasswordBytes);

      final Uint8List newSecretKeyBytes = Uint8List.fromList(utf8.encode(newUserPassword));
      final Uint8List newInitializationVectorBytes = _randomValuesGenerator.generateRandomBytes(128 ~/ 8);

      final crypto.Digest newSecretKeyDigest = crypto.md5.convert(newSecretKeyBytes);
      final Uint8List newSecretKeyDigestBytes = Uint8List.fromList(newSecretKeyDigest.bytes);

      final PaddedBlockCipher encryptAesCipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESFastEngine()),
      );

      encryptAesCipher.init(
        true,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          ParametersWithIV<KeyParameter>(KeyParameter(newSecretKeyDigestBytes), newInitializationVectorBytes),
          null,
        ),
      );

      final Uint8List encryptedNewPasswordBytes = encryptAesCipher.process(decryptedOldPasswordBytes);

      password.password = base64.encode(encryptedNewPasswordBytes);
      password.vector = base64.encode(newInitializationVectorBytes);
    }

    final List<dynamic> passwordsUpdateResults = await _passwordRepository.updatePasswords(passwords);

    for (final dynamic result in passwordsUpdateResults) {
      if (result != 1) {
        return Left<Failure, void>(UserUpdateFailure());
      }
    }

    return const Right<Failure, void>(null);
  }

  /// Calculates hash using SHA512 algorithm.
  String _calculateSha512(String text) {
    /// Creates bytes from a given text value.
    final List<int> bytes = utf8.encode(text);

    /// Hashes bytes using SHA512 algorithm.
    final crypto.Digest digest = crypto.sha512.convert(bytes);

    /// Returns the message digest as a string of hexadecimal digits.
    return digest.toString();
  }

  /// Calculates hash using HMAC-SHA512 algorithm.
  String _calculateHmacSha512(String text, String key) {
    /// Creates bytes from given text values.
    final List<int> keyBytes = utf8.encode(key);
    final List<int> textBytes = utf8.encode(text);

    /// Creates HMAC-SHA512 algorithm with a given secret key bytes.
    final crypto.Hmac hmacSha512 = crypto.Hmac(crypto.sha512, keyBytes);

    /// Hashes bytes using HMAC-SHA512 algorithm.
    final crypto.Digest digest = hmacSha512.convert(textBytes);

    /// Returns the message digest as a string of hexadecimal digits.
    return digest.toString();
  }

  /// Adds a user login log.
  Future<bool> addLog({@required int userId, @required bool isSuccessful, @required String ipAddress}) async {
    final int millisecondsSinceEpoch = _clock.now().millisecondsSinceEpoch;

    final Log log = Log(
        userId: userId,
        isSuccessful: isSuccessful,
        ipAddress: ipAddress,
        isUnblocked: false,
        loginTime: millisecondsSinceEpoch);

    final int result = await _logRepository.createLog(log);

    return result != -1;
  }

  /// Gets user login logs.
  Future<List<Log>> getUserLogs({@required String username}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return <Log>[];
    }

    final List<Log> userLogs = await _logRepository.getLogsByUserId(user.id);

    return userLogs;
  }

  /// Gets a list of IP addresses that are block.
  Future<List<String>> getBlockedIpAddresses({@required String username}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return <String>[];
    }

    final List<Log> userLogs = await _logRepository.getLogsByUserId(user.id);

    /// Values of this map represent number of recent invalid logins
    /// and a flag that indicates if the most recent login was valid.
    final Map<String, List<int>> ipAddressByNumberOfRecentInvalidLogins = <String, List<int>>{};
    for (final Log log in userLogs) {
      /// Checks if the IP address related to this log have been already added.
      if (ipAddressByNumberOfRecentInvalidLogins.containsKey(log.ipAddress)) {
        /// Checks if log is invalid login and there was no valid logins before.
        if (!log.isSuccessful && !log.isUnblocked && ipAddressByNumberOfRecentInvalidLogins[log.ipAddress][1] != 1) {
          ipAddressByNumberOfRecentInvalidLogins[log.ipAddress][0]++;
          ipAddressByNumberOfRecentInvalidLogins[log.ipAddress][1] = 0;
        } else {
          /// Sets flag which indicates that next invalid logs should not be counted.
          ipAddressByNumberOfRecentInvalidLogins[log.ipAddress][1] = 1;
        }
      } else {
        /// Checks if first log is invalid login.
        if (!log.isSuccessful && !log.isUnblocked) {
          /// Sets first invalid login log.
          ipAddressByNumberOfRecentInvalidLogins[log.ipAddress] = <int>[1, 0];
        } else {
          /// Sets first valid login log. Next invalid logs should not be counted.
          ipAddressByNumberOfRecentInvalidLogins[log.ipAddress] = <int>[0, 1];
        }
      }
    }

    final Map<String, List<int>> blockedIpByNumberOfRecentInvalidLogins = ipAddressByNumberOfRecentInvalidLogins
      ..removeWhere((_, List<int> value) => value[0] < 4);

    final List<String> blockedIps = blockedIpByNumberOfRecentInvalidLogins.keys.toList();
    return blockedIps;
  }

  /// Checks if user is blocked.
  Future<bool> checkUserBlock({@required String username}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return true;
    }

    final List<Log> userLogs = await _logRepository.getLogsByUserId(user.id)
      ..reversed.toList();

    int numberOfRecentInvalidLogins = 0;
    Log firstInvalidLogin;
    for (final Log log in userLogs) {
      if (!log.isSuccessful) {
        numberOfRecentInvalidLogins++;

        firstInvalidLogin ??= log;
      } else {
        break;
      }
    }

    if (firstInvalidLogin != null) {
      final DateTime firstInvalidLoginTime = DateTime.fromMillisecondsSinceEpoch(firstInvalidLogin.loginTime);
      final Duration timeDifference = _clock.now().difference(firstInvalidLoginTime);
      if ((numberOfRecentInvalidLogins == 2 && timeDifference.inSeconds < 5) ||
          (numberOfRecentInvalidLogins == 3 && timeDifference.inSeconds < 10) ||
          (numberOfRecentInvalidLogins >= 4 && timeDifference.inMinutes < 2)) {
        if (numberOfRecentInvalidLogins == 2 && timeDifference.inSeconds < 5) {
          print('User Account Blocked For 5 seconds');
        }

        if (numberOfRecentInvalidLogins == 3 && timeDifference.inSeconds < 10) {
          print('User Account Blocked For 10 seconds');
        }

        if (numberOfRecentInvalidLogins >= 4 && timeDifference.inMinutes < 2) {
          print('User Account Blocked For 2 minutes');
        }

        print('User Account Blocked Time: ${timeDifference.inSeconds}s');

        return true;
      }
    }

    return false;
  }

  /// Checks if user's IP address is blocked.
  Future<bool> checkIpBlock({@required String username, @required String ipAddress}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return true;
    }

    final List<Log> userLogs = await _logRepository.getLogsByUserIdAndIpAddress(user.id, ipAddress)
      ..reversed.toList();

    int numberOfRecentInvalidLogins = 0;
    Log firstInvalidLogin;
    for (final Log log in userLogs) {
      if (!log.isSuccessful && !log.isUnblocked) {
        numberOfRecentInvalidLogins++;

        firstInvalidLogin ??= log;
      } else {
        break;
      }
    }

    if (firstInvalidLogin != null) {
      final DateTime firstInvalidLoginTime = DateTime.fromMillisecondsSinceEpoch(firstInvalidLogin.loginTime);
      final Duration timeDifference = _clock.now().difference(firstInvalidLoginTime);
      if ((numberOfRecentInvalidLogins == 2 && timeDifference.inSeconds < 5) ||
          (numberOfRecentInvalidLogins == 3 && timeDifference.inSeconds < 10) ||
          (numberOfRecentInvalidLogins >= 4)) {
        if (numberOfRecentInvalidLogins == 2 && timeDifference.inSeconds < 5) {
          print('IP Address Blocked For 5 seconds');
        }

        if (numberOfRecentInvalidLogins == 3 && timeDifference.inSeconds < 10) {
          print('IP Address Blocked For 10 seconds');
        }

        if (numberOfRecentInvalidLogins >= 4) {
          print('IP Address Blocked permanently');
        }

        print('IP Address Blocked Time: ${timeDifference.inSeconds}s');

        return true;
      }
    }

    return false;
  }

  /// Unblocks IP address.
  Future<bool> unblockIp({@required String username, @required String blockedIpAddress}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return false;
    }

    final List<Log> userLogs = await _logRepository.getLogsByUserIdAndIpAddress(user.id, blockedIpAddress)
      ..reversed.toList();

    if (userLogs.isNotEmpty) {
      final Log lastLogToUnblock = userLogs[0];
      lastLogToUnblock.isUnblocked = true;

      if (await _logRepository.updateLog(lastLogToUnblock) == -1) {
        return false;
      }
    }

    return true;
  }
}
