import 'dart:convert';
import 'dart:math' show Random;

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:random_string/random_string.dart';

import '../data/models/models.dart' show User;
import '../repositories/repositories.dart' show UserRepository;
import '../utils/constants.dart';
import '../utils/failure.dart';

/// A user service layer.
class UserService {
  /// Creates user service.
  UserService(this._userRepository);

  final UserRepository _userRepository;

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
      return Left<Failure, void>(ExistingUserFailure());
    }

    final String randomKey = _generateSecureRandomString(30);
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
      return Left<Failure, void>(ExistingUserFailure());
    }

    return const Right<Failure, void>(null);
  }

  String _calculateSha512(String text) {
    final List<int> bytes = utf8.encode(text);
    final Digest digest = sha256.convert(bytes);

    return digest.toString();
  }

  String _calculateHmacSha512(String text, String key) {
    final List<int> keyBytes = utf8.encode(key);
    final List<int> textBytes = utf8.encode(text);

    final Hmac hmacSha512 = Hmac(sha512, keyBytes);
    final Digest digest = hmacSha512.convert(textBytes);

    return digest.toString();
  }

  String _generateSecureRandomString(int length) {
    return randomString(10, provider: CoreRandomProvider.from(Random.secure()));
  }
}
