import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/utils/random_values_generator.dart';

class FakeRandom extends Fake implements Random {
  @override
  int nextInt(int max) {
    return 25;
  }
}

void main() {
  setUp(() {});
  tearDown(() {});

  group(
    'Generate Random Bytes',
    () {
      test(
        'Given number of bytes When generate random bytes is called Then return given number of bytes',
        () {
          /// Given
          const int numberOfBytes = 16;
          final Uint8List testBytes =
              Uint8List.fromList(<int>[214, 133, 152, 94, 253, 24, 240, 68, 95, 28, 150, 101, 72, 174, 85, 93]);

          final RandomValuesGenerator randomValuesGenerator = RandomValuesGenerator(seedSource: FakeRandom());

          /// When
          final Uint8List result = randomValuesGenerator.generateRandomBytes(numberOfBytes);

          /// Then
          expect(result, testBytes);
        },
      );
    },
  );
}
