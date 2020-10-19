import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart';

import '../data/models/models.dart' show Password, User;
import '../repositories/repositories.dart' show PasswordRepository, UserRepository;
import '../utils/constants.dart';
import '../utils/failure.dart';
import '../utils/random_values_generator.dart';

/// A user service layer.
class UserService {
  /// Creates user service.
  UserService(this._userRepository, this._passwordRepository, this._randomValuesGenerator);

  final UserRepository _userRepository;
  final PasswordRepository _passwordRepository;
  final RandomValuesGenerator _randomValuesGenerator;

  /// Validates user's credentials.
  Future<Either<Failure, void>> checkCredentials({@required String username, @required String password}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return Left<Failure, void>(NonExistentUserFailure());
    }

    String hash = '';
    if (user.isPasswordKeptAsHash) {
      hash = _calculateSha512(password + user.salt + Constants.pepper);
    } else {
      hash = _calculateHmacSha512(password + Constants.pepper, user.salt);
    }

    if (hash != user.passwordHash) {
      return Left<Failure, void>(UserSigningFailure());
    }

    return const Right<Failure, void>(null);
  }

  /// Registers new user.
  Future<Either<Failure, void>> registerUser(
      {@required String username, @required String password, @required bool isEncryptingAlgorithmSha}) async {
    final User oldUser = await _userRepository.getUserByUsername(username);

    if (oldUser != null) {
      return Left<Failure, void>(AlreadyExistingUserFailure());
    }

    final String randomKey = base64.encode(_randomValuesGenerator.generateRandomBytes(256 ~/ 8));
    String hash = '';

    if (isEncryptingAlgorithmSha) {
      hash = _calculateSha512(password + randomKey + Constants.pepper);
    } else {
      hash = _calculateHmacSha512(password + Constants.pepper, randomKey);
    }

    final User user =
        User(username: username, passwordHash: hash, salt: randomKey, isPasswordKeptAsHash: isEncryptingAlgorithmSha);

    final int result = await _userRepository.createUser(user);
    if (result == -1) {
      return Left<Failure, void>(UserCreationFailure());
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

  String _calculateSha512(String text) {
    final List<int> bytes = utf8.encode(text);
    final crypto.Digest digest = crypto.sha512.convert(bytes);

    return digest.toString();
  }

  String _calculateHmacSha512(String text, String key) {
    final List<int> keyBytes = utf8.encode(key);
    final List<int> textBytes = utf8.encode(text);

    final crypto.Hmac hmacSha512 = crypto.Hmac(crypto.sha512, keyBytes);
    final crypto.Digest digest = hmacSha512.convert(textBytes);

    return digest.toString();
  }
}
