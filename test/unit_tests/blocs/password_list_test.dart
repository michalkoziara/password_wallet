import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/blocs/blocs.dart';
import 'package:password_wallet/src/data/models/models.dart';
import 'package:password_wallet/src/services/password_service.dart';
import 'package:password_wallet/src/utils/failure.dart';

class MockPasswordService extends Mock implements PasswordService {}

void main() {
  final MockPasswordService mockPasswordService = MockPasswordService();

  setUp(() {
    reset(mockPasswordService);
  });

  group('Password List BLoC', () {
    blocTest<PasswordListBloc, PasswordListState>(
      'emits [PasswordListPopulatedState] when successful',
      build: () {
        when(
          mockPasswordService.getPasswords(username: anyNamed('username')),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, List<Password>>>.value(
            const Right<Failure, List<Password>>(<Password>[]),
          ),
        );

        return PasswordListBloc(mockPasswordService);
      },
      act: (PasswordListBloc bloc) => bloc.add(PasswordListOpenEvent(username: 'Test Username')),
      expect: <dynamic>[
        isA<PasswordListPopulatedState>(),
      ],
    );

    blocTest<PasswordListBloc, PasswordListState>(
      'emits [PasswordListErrorState] when non existent user failure',
      build: () {
        when(
          mockPasswordService.getPasswords(username: anyNamed('username')),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, List<Password>>>.value(
            Left<Failure, List<Password>>(NonExistentUserFailure()),
          ),
        );

        return PasswordListBloc(mockPasswordService);
      },
      act: (PasswordListBloc bloc) => bloc.add(PasswordListOpenEvent(username: 'Test Username')),
      expect: <dynamic>[
        isA<PasswordListErrorState>(),
      ],
    );

    blocTest<PasswordListBloc, PasswordListState>(
      'emits [PasswordListVisiblePasswordState] when successfully displayed password',
      build: () {
        when(
          mockPasswordService.getPassword(id: anyNamed('id'), userPassword: anyNamed('userPassword')),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, String>>.value(
            const Right<Failure, String>('Test Password'),
          ),
        );

        return PasswordListBloc(mockPasswordService);
      },
      act: (PasswordListBloc bloc) => bloc.add(
        PasswordDisplayEvent(
          passwords: const <Password>[],
          index: 1,
          id: 1,
          password: 'Test Password',
        ),
      ),
      expect: <dynamic>[
        isA<PasswordListVisiblePasswordState>(),
      ],
    );

    blocTest<PasswordListBloc, PasswordListState>(
      'emits [PasswordListErrorState] when non existent user failure',
      build: () {
        when(
          mockPasswordService.getPassword(id: anyNamed('id'), userPassword: anyNamed('userPassword')),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, String>>.value(
            Left<Failure, String>(NonExistentUserFailure()),
          ),
        );

        return PasswordListBloc(mockPasswordService);
      },
      act: (PasswordListBloc bloc) => bloc.add(
        PasswordDisplayEvent(
          passwords: const <Password>[],
          index: 1,
          id: 1,
          password: 'Test Password',
        ),
      ),
      expect: <dynamic>[
        isA<PasswordListErrorState>(),
      ],
    );

    blocTest<PasswordListBloc, PasswordListState>(
      'emits [PasswordListItemExpandedState] when successfully expanded password',
      build: () {
        return PasswordListBloc(mockPasswordService);
      },
      act: (PasswordListBloc bloc) => bloc.add(
        PasswordListItemExtendedEvent(
          passwords: const <Password>[],
          index: 1,
        ),
      ),
      expect: <dynamic>[
        isA<PasswordListItemExpandedState>(),
      ],
    );
  });
}
