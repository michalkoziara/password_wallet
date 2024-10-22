import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/export.dart';

import '../data/models/models.dart' show DataChange, Password, User;
import '../repositories/repositories.dart' show PasswordRepository, UserRepository;
import '../utils/activity_type.dart';
import '../utils/failure.dart';
import '../utils/random_values_generator.dart';
import 'data_change_service.dart';

/// A password service layer.
class PasswordService {
  /// Creates password service.
  PasswordService(this._passwordRepository, this._userRepository, this._dataChangeService, this._randomValuesGenerator);

  final PasswordRepository _passwordRepository;
  final UserRepository _userRepository;

  final DataChangeService _dataChangeService;

  final RandomValuesGenerator _randomValuesGenerator;

  /// Adds new password to wallet.
  Future<Either<Failure, void>> addPassword(
      {@required String login,
      @required String webAddress,
      @required String password,
      @required String description,
      @required String username,
      @required String userPassword,
      bool isRegistered = false}) async {
    final User user = await _userRepository.getUserByUsername(username);

    /// Checks if user with given username exists.
    if (user == null) {
      return Left<Failure, void>(NonExistentUserFailure());
    }

    /// Creates new password.
    final Password newPassword = createPassword(
      login: login,
      webAddress: webAddress,
      password: password,
      description: description,
      userId: user.id,
      userPassword: userPassword,
    );

    /// Saves password data in the database.
    final int newPasswordId = await _passwordRepository.createPassword(newPassword);
    if (newPasswordId == -1) {
      return Left<Failure, void>(PasswordCreationFailure());
    }

    if (isRegistered) {
      await _dataChangeService.createDataChange(
        activityType: ActivityType.create,
        userId: user.id,
        passwordBeforeChangeId: null,
        passwordAfterChangeId: newPasswordId,
      );
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

  /// Gets active user's passwords from wallet.
  Future<Either<Failure, List<Password>>> getActivePasswords({@required String username}) async {
    final User user = await _userRepository.getUserByUsername(username);

    if (user == null) {
      return Left<Failure, List<Password>>(NonExistentUserFailure());
    }

    List<Password> passwords = await _passwordRepository.getPasswordsByUserId(user.id);
    passwords = passwords.where((Password password) => !password.isArchived && !password.isDeleted).toList();

    return Right<Failure, List<Password>>(passwords);
  }

  /// Gets user's password from wallet.
  Future<Either<Failure, String>> getPassword(
      {@required int id, @required String userPassword, bool isRegistered = false}) async {
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
      false,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(secretKeyDigestBytes), initializationVectorBytes),
        null,
      ),
    );

    final Uint8List decryptedPasswordBytes = aesCipher.process(passwordBytes);

    final String decryptedPassword = utf8.decode(decryptedPasswordBytes);

    if (isRegistered) {
      await _dataChangeService.createDataChange(
        activityType: ActivityType.view,
        userId: password.userId,
        passwordBeforeChangeId: password.id,
        passwordAfterChangeId: password.id,
      );
    }

    return Right<Failure, String>(decryptedPassword);
  }

  /// Creates new password.
  Password createPassword(
      {@required String login,
      @required String webAddress,
      @required String password,
      @required String description,
      @required int userId,
      @required String userPassword}) {
    /// Creates bytes from text values.
    final Uint8List passwordBytes = Uint8List.fromList(utf8.encode(password));
    final Uint8List secretKeyBytes = Uint8List.fromList(utf8.encode(userPassword));
    final Uint8List initializationVectorBytes = _randomValuesGenerator.generateRandomBytes(128 ~/ 8);

    /// Hashes user password with MD5 algorithm.
    final crypto.Digest secretKeyDigest = crypto.md5.convert(secretKeyBytes);
    final Uint8List secretKeyDigestBytes = Uint8List.fromList(secretKeyDigest.bytes);

    /// Creates AES in CBC mode with PKCS7 padding.
    final PaddedBlockCipher aesCipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    /// Initializes algorithm with secret key and initialization vector.
    aesCipher.init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(secretKeyDigestBytes), initializationVectorBytes),
        null,
      ),
    );

    /// Encrypts password.
    final Uint8List encryptedPasswordBytes = aesCipher.process(passwordBytes);

    /// Creates text from bytes.
    final String encryptedPassword = base64.encode(encryptedPasswordBytes);
    final String initializationVector = base64.encode(initializationVectorBytes);

    /// Creates password data object.
    final Password newPassword = Password(
      userId: userId,
      password: encryptedPassword,
      vector: initializationVector,
      webAddress: webAddress,
      description: description,
      login: login,
    );

    return newPassword;
  }

  /// Removes password from wallet.
  Future<bool> removePassword({@required Password password}) async {
    final List<Password> sharedPasswords = await _passwordRepository.getPasswordsByOwnerPasswordId(password.id);
    for (final Password sharedPassword in sharedPasswords) {
      sharedPassword.isDeleted = true;
      final int deletedSharedPasswordId = await _passwordRepository.updatePassword(sharedPassword);

      if (deletedSharedPasswordId == -1) {
        return false;
      }
    }

    password.isDeleted = true;
    final int deletedPasswordId = await recreatePasswordWithChanges(Password.copy(password));

    if (!await _dataChangeService.createDataChange(
      activityType: ActivityType.delete,
      userId: password.userId,
      passwordBeforeChangeId: password.id,
      passwordAfterChangeId: deletedPasswordId,
    )) {
      return false;
    }

    return true;
  }

  /// Archives old password and creates a new one with given changes.
  Future<int> recreatePasswordWithChanges(Password changedPassword) async {
    final Password oldPassword = await _passwordRepository.getPasswordById(changedPassword.id);
    oldPassword.isArchived = true;
    if (await _passwordRepository.updatePassword(oldPassword) == -1) {
      return -1;
    }

    final List<Password> sharedPasswords = await _passwordRepository.getPasswordsByOwnerPasswordId(changedPassword.id);

    changedPassword.id = null;
    final int changedPasswordId = await _passwordRepository.createPassword(changedPassword);

    for (final Password sharedPassword in sharedPasswords) {
      sharedPassword.ownerPasswordId = changedPasswordId;

      if (await _passwordRepository.updatePassword(sharedPassword) == -1) {
        return -1;
      }
    }

    return changedPasswordId;
  }

  /// Updates password by ID.
  Future<bool> updatePassword(
      {@required Password password, @required String userPassword, bool isRegistered = false}) async {
    final String updatedPasswordValue = password.password;

    /// Creates bytes from text values.
    final Uint8List passwordBytes = Uint8List.fromList(utf8.encode(updatedPasswordValue));
    final Uint8List secretKeyBytes = Uint8List.fromList(utf8.encode(userPassword));
    final Uint8List initializationVectorBytes = _randomValuesGenerator.generateRandomBytes(128 ~/ 8);

    /// Hashes user password with MD5 algorithm.
    final crypto.Digest secretKeyDigest = crypto.md5.convert(secretKeyBytes);
    final Uint8List secretKeyDigestBytes = Uint8List.fromList(secretKeyDigest.bytes);

    /// Creates AES in CBC mode with PKCS7 padding.
    final PaddedBlockCipher aesCipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    /// Initializes algorithm with secret key and initialization vector.
    aesCipher.init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(secretKeyDigestBytes), initializationVectorBytes),
        null,
      ),
    );

    /// Encrypts password.
    final Uint8List encryptedPasswordBytes = aesCipher.process(passwordBytes);

    /// Creates text from bytes.
    final String encryptedPassword = base64.encode(encryptedPasswordBytes);
    final String initializationVector = base64.encode(initializationVectorBytes);

    password.password = encryptedPassword;
    password.vector = initializationVector;

    final List<Password> sharedPasswords = await _passwordRepository.getPasswordsByOwnerPasswordId(password.id);
    for (final Password sharedPassword in sharedPasswords) {
      final User user = await _userRepository.getUserById(sharedPassword.userId);

      if (user == null) {
        return false;
      }

      /// Creates bytes from text values.
      final Uint8List sharedSecretKeyBytes = Uint8List.fromList(utf8.encode(user.passwordHash));
      final Uint8List sharedInitializationVectorBytes = _randomValuesGenerator.generateRandomBytes(128 ~/ 8);

      /// Hashes user password with MD5 algorithm.
      final crypto.Digest sharedSecretKeyDigest = crypto.md5.convert(sharedSecretKeyBytes);
      final Uint8List sharedSecretKeyDigestBytes = Uint8List.fromList(sharedSecretKeyDigest.bytes);

      /// Creates AES in CBC mode with PKCS7 padding.
      final PaddedBlockCipher aesCipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESFastEngine()),
      );

      /// Initializes algorithm with secret key and initialization vector.
      aesCipher.init(
        true,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          ParametersWithIV<KeyParameter>(KeyParameter(sharedSecretKeyDigestBytes), sharedInitializationVectorBytes),
          null,
        ),
      );

      /// Encrypts password.
      final Uint8List encryptedSharedPasswordBytes = aesCipher.process(passwordBytes);

      /// Creates text from bytes.
      final String encryptedSharedPassword = base64.encode(encryptedSharedPasswordBytes);
      final String sharedInitializationVector = base64.encode(sharedInitializationVectorBytes);

      sharedPassword.password = encryptedSharedPassword;
      sharedPassword.vector = sharedInitializationVector;
      sharedPassword.isSharedUpdated = true;

      if (await _passwordRepository.updatePassword(sharedPassword) == -1) {
        return false;
      }
    }

    final List<Password> updatedSharedPasswords = await _passwordRepository.getPasswordsByOwnerPasswordId(password.id);

    int updatedPasswordId;
    if (isRegistered) {
      updatedPasswordId = await recreatePasswordWithChanges(Password.copy(password));
      if (updatedPasswordId == -1) {
        return false;
      }

      if (!await _dataChangeService.createDataChange(
        activityType: ActivityType.modify,
        userId: password.userId,
        passwordBeforeChangeId: password.id,
        passwordAfterChangeId: updatedPasswordId,
      )) {
        return false;
      }
    } else {
      updatedPasswordId = await _passwordRepository.updatePassword(password);
    }

    if (updatedPasswordId == null || updatedPasswordId == -1) {
      return false;
    }

    for (final Password updatedSharedPassword in updatedSharedPasswords) {
      updatedSharedPassword.ownerPasswordId = updatedPasswordId;

      if (await _passwordRepository.updatePassword(updatedSharedPassword) == -1) {
        return false;
      }
    }

    return true;
  }

  /// Shares password with other user.
  Future<bool> sharePassword(
      {@required Password password, @required String username, @required String ownerPassword}) async {
    final User sharedUser = await _userRepository.getUserByUsername(username);

    if (sharedUser == null) {
      return false;
    }

    final List<Password> ownedPasswords = await _passwordRepository.getPasswordsByUserId(sharedUser.id);
    if (ownedPasswords.isNotEmpty) {
      final List<Password> alreadySharedPasswords = ownedPasswords
          .where(
            (Password ownedPassword) => ownedPassword.ownerPasswordId == password.id,
          )
          .toList();

      if (alreadySharedPasswords.isNotEmpty) {
        return false;
      }
    }

    final Either<Failure, String> result = await getPassword(id: password.id, userPassword: ownerPassword);
    final String textPassword = result.getOrElse(null);
    if (textPassword == null) {
      return false;
    }

    /// Creates bytes from text values.
    final Uint8List passwordBytes = Uint8List.fromList(utf8.encode(textPassword));
    final Uint8List secretKeyBytes = Uint8List.fromList(utf8.encode(sharedUser.passwordHash));
    final Uint8List initializationVectorBytes = _randomValuesGenerator.generateRandomBytes(128 ~/ 8);

    /// Hashes user password with MD5 algorithm.
    final crypto.Digest secretKeyDigest = crypto.md5.convert(secretKeyBytes);
    final Uint8List secretKeyDigestBytes = Uint8List.fromList(secretKeyDigest.bytes);

    /// Creates AES in CBC mode with PKCS7 padding.
    final PaddedBlockCipher aesCipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    /// Initializes algorithm with secret key and initialization vector.
    aesCipher.init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(secretKeyDigestBytes), initializationVectorBytes),
        null,
      ),
    );

    /// Encrypts password.
    final Uint8List encryptedPasswordBytes = aesCipher.process(passwordBytes);

    /// Creates text from bytes.
    final String encryptedPassword = base64.encode(encryptedPasswordBytes);
    final String initializationVector = base64.encode(initializationVectorBytes);

    password.password = encryptedPassword;
    password.vector = initializationVector;

    password.ownerPasswordId = password.id;
    password.id = null;
    password.userId = sharedUser.id;
    password.isSharedUpdated = true;

    return await _passwordRepository.createPassword(password) > 0;
  }

  /// Restores password to state before its data change.
  Future<int> restorePassword({@required DataChange dataChange, @required String userPassword}) async {
    final Password currentPassword = await _passwordRepository.getPasswordById(dataChange.passwordId);

    currentPassword.isArchived = true;
    if (await _passwordRepository.updatePassword(currentPassword) == -1) {
      return -1;
    }

    final List<Password> sharedPasswords = await _passwordRepository.getPasswordsByOwnerPasswordId(currentPassword.id);

    final Password previousPassword = await _passwordRepository.getPasswordById(dataChange.previousRecordId);
    previousPassword.id = null;
    previousPassword.isArchived = false;

    final int restoredPasswordId = await _passwordRepository.createPassword(previousPassword);
    if (restoredPasswordId == -1) {
      return -1;
    }

    final Either<Failure, String> restoredPasswordResult =
        await getPassword(id: restoredPasswordId, userPassword: userPassword);
    final String restoredPasswordValue = restoredPasswordResult.getOrElse(() => null);

    for (final Password sharedPassword in sharedPasswords) {
      if (restoredPasswordValue == null) {
        return -1;
      }

      final User user = await _userRepository.getUserById(sharedPassword.userId);

      if (user == null) {
        return -1;
      }

      /// Creates bytes from text values.
      final Uint8List passwordBytes = Uint8List.fromList(utf8.encode(restoredPasswordValue));
      final Uint8List sharedSecretKeyBytes = Uint8List.fromList(utf8.encode(user.passwordHash));
      final Uint8List sharedInitializationVectorBytes = _randomValuesGenerator.generateRandomBytes(128 ~/ 8);

      /// Hashes user password with MD5 algorithm.
      final crypto.Digest sharedSecretKeyDigest = crypto.md5.convert(sharedSecretKeyBytes);
      final Uint8List sharedSecretKeyDigestBytes = Uint8List.fromList(sharedSecretKeyDigest.bytes);

      /// Creates AES in CBC mode with PKCS7 padding.
      final PaddedBlockCipher aesCipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESFastEngine()),
      );

      /// Initializes algorithm with secret key and initialization vector.
      aesCipher.init(
        true,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          ParametersWithIV<KeyParameter>(KeyParameter(sharedSecretKeyDigestBytes), sharedInitializationVectorBytes),
          null,
        ),
      );

      /// Encrypts password.
      final Uint8List encryptedSharedPasswordBytes = aesCipher.process(passwordBytes);

      /// Creates text from bytes.
      final String encryptedSharedPassword = base64.encode(encryptedSharedPasswordBytes);
      final String sharedInitializationVector = base64.encode(sharedInitializationVectorBytes);

      sharedPassword.password = encryptedSharedPassword;
      sharedPassword.vector = sharedInitializationVector;
      sharedPassword.isSharedUpdated = true;
      sharedPassword.ownerPasswordId = restoredPasswordId;

      sharedPassword.login = previousPassword.login;
      sharedPassword.webAddress = previousPassword.webAddress;
      sharedPassword.description = previousPassword.description;

      if (await _passwordRepository.updatePassword(sharedPassword) == -1) {
        return -1;
      }
    }

    await _dataChangeService.createDataChange(
      userId: dataChange.userId,
      activityType: ActivityType.restore,
      passwordAfterChangeId: restoredPasswordId,
      passwordBeforeChangeId: dataChange.passwordId,
    );

    return restoredPasswordId;
  }
}
