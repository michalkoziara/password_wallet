import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// A helper class allowing generate random values.
class RandomValuesGenerator {
  /// Creates random values generator.
  RandomValuesGenerator({Random seedSource}) : seedSource = seedSource ?? Random.secure();

  /// The secure random seed generator.
  final Random seedSource;

  /// Generates random bytes using Fortuna (PRNG).
  Uint8List generateRandomBytes(int numBytes) {
    final FortunaRandom _secureRandom = FortunaRandom();

    final List<int> seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }

    _secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final Uint8List randomBytes = _secureRandom.nextBytes(numBytes);
    return randomBytes;
  }
}
