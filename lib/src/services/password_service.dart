import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart';

import '../data/models/models.dart' show Password, User;
import '../repositories/repositories.dart' show PasswordRepository, UserRepository;
import '../utils/failure.dart';
import '../utils/random_values_generator.dart';

/// A password service layer.
class PasswordService {
  /// Creates password service.
  PasswordService(this._passwordRepository, this._userRepository, this._randomValuesGenerator);

  final PasswordRepository _passwordRepository;
  final UserRepository _userRepository;
  final RandomValuesGenerator _randomValuesGenerator;

  /// Adds new password to wallet.
  Future<Either<Failure, void>> addPassword(
      {@required String login,
      @required String webAddress,
      @required String password,
      @required String description,
      @required String username,
      @required String userPassword}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return Left<Failure, void>(NonExistentUserFailure());
    }

    final Uint8List passwordBytes = Uint8List.fromList(utf8.encode(password));
    final Uint8List secretKeyBytes = Uint8List.fromList(utf8.encode(userPassword));
    final Uint8List initializationVectorBytes = _randomValuesGenerator.generateRandomBytes(128 ~/ 8);

    final PaddedBlockCipher aesCipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    final crypto.Digest secretKeyDigest = crypto.md5.convert(secretKeyBytes);
    final Uint8List secretKeyDigestBytes = Uint8List.fromList(secretKeyDigest.bytes);

    aesCipher.init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(secretKeyDigestBytes), initializationVectorBytes),
        null,
      ),
    );

    final Uint8List encryptedPasswordBytes = aesCipher.process(passwordBytes);

    final String encryptedPassword = base64.encode(encryptedPasswordBytes);
    final String initializationVector = base64.encode(initializationVectorBytes);

    final Password newPassword = Password(
      userId: user.id,
      password: encryptedPassword,
      vector: initializationVector,
      webAddress: webAddress,
      description: description,
      login: login,
    );

    final int result = await _passwordRepository.createPassword(newPassword);
    if (result == -1) {
      return Left<Failure, void>(PasswordCreationFailure());
    }

    return const Right<Failure, void>(null);
  }

  /// Gets user's passwords from wallet.
  Future<Either<Failure, List<Password>>> getPasswords({@required String username}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return Left<Failure, List<Password>>(NonExistentUserFailure());
    }

    final List<Password> passwords = await _passwordRepository.getPasswordsByUserId(user.id);
    return Right<Failure, List<Password>>(passwords);
  }

  /// Gets user's password from wallet.
  Future<Either<Failure, String>> getPassword({@required int id, @required String userPassword}) async {
    final Password password = await _passwordRepository.getPasswordById(id);

    if (password == null) {
      return Left<Failure, String>(NonExistentUserFailure());
    }

    final Uint8List passwordBytes = Uint8List.fromList(base64.decode(password.password));
    final Uint8List secretKeyBytes = Uint8List.fromList(utf8.encode(userPassword));
    final Uint8List initializationVectorBytes = Uint8List.fromList(base64.decode(password.vector));

    final crypto.Digest secretKeyDigest = crypto.md5.convert(secretKeyBytes);
    final Uint8List secretKeyDigestBytes = Uint8List.fromList(secretKeyDigest.bytes);

    final PaddedBlockCipher aesCipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    aesCipher.init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(secretKeyDigestBytes), initializationVectorBytes),
        null,
      ),
    );

    final Uint8List decryptedPasswordBytes = aesCipher.process(passwordBytes);

    final String decryptedPassword = utf8.decode(decryptedPasswordBytes);

    return Right<Failure, String>(decryptedPassword);
  }
}
