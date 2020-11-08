import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/blocs/blocs.dart';
import 'package:password_wallet/src/services/services.dart';
import 'package:password_wallet/src/utils/failure.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  final MockUserService mockUserService = MockUserService();

  setUp(() {
    reset(mockUserService);
  });

  group('Registration BLoC', () {
    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationVisibleState] when show registration',
      build: () {
        return RegistrationBloc(mockUserService);
      },
      act: (RegistrationBloc bloc) => bloc.add(ShowRegistration()),
      expect: <dynamic>[
        isA<RegistrationVisibleState>(),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationInvisibleState] when hide registration',
      build: () {
        return RegistrationBloc(mockUserService);
      },
      act: (RegistrationBloc bloc) => bloc.add(HideRegistration()),
      expect: <dynamic>[
        isA<RegistrationInvisibleState>(),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationCompletionState] when successful registration',
      build: () {
        when(
          mockUserService.registerUser(
            password: anyNamed('password'),
            username: anyNamed('username'),
            isEncryptingAlgorithmSha: anyNamed('isEncryptingAlgorithmSha'),
          ),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            const Right<Failure, void>(null),
          ),
        );

        return RegistrationBloc(mockUserService);
      },
      act: (RegistrationBloc bloc) => bloc.add(
        CompleteRegistration(
          username: 'Test username',
          password: 'Test password',
          isEncryptingAlgorithmSha: true,
        ),
      ),
      expect: <dynamic>[
        isA<RegistrationCompletionState>(),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'emits [RegistrationErrorState] when already existing user failure',
      build: () {
        when(
          mockUserService.registerUser(
            password: anyNamed('password'),
            username: anyNamed('username'),
            isEncryptingAlgorithmSha: anyNamed('isEncryptingAlgorithmSha'),
          ),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            Left<Failure, void>(AlreadyExistingUserFailure()),
          ),
        );

        return RegistrationBloc(mockUserService);
      },
      act: (RegistrationBloc bloc) => bloc.add(
        CompleteRegistration(
          username: 'Test username',
          password: 'Test password',
          isEncryptingAlgorithmSha: true,
        ),
      ),
      expect: <dynamic>[
        isA<RegistrationErrorState>(),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'emits [UserCreationFailure] when user creation failure',
      build: () {
        when(
          mockUserService.registerUser(
            password: anyNamed('password'),
            username: anyNamed('username'),
            isEncryptingAlgorithmSha: anyNamed('isEncryptingAlgorithmSha'),
          ),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            Left<Failure, void>(UserCreationFailure()),
          ),
        );

        return RegistrationBloc(mockUserService);
      },
      act: (RegistrationBloc bloc) => bloc.add(
        CompleteRegistration(
          username: 'Test username',
          password: 'Test password',
          isEncryptingAlgorithmSha: true,
        ),
      ),
      expect: <dynamic>[
        isA<RegistrationErrorState>(),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'emits [LoginCompletionState] when successful credentials check',
      build: () {
        when(
          mockUserService.checkCredentials(
            password: anyNamed('password'),
            username: anyNamed('username'),
          ),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            const Right<Failure, void>(null),
          ),
        );

        return RegistrationBloc(mockUserService);
      },
      act: (RegistrationBloc bloc) => bloc.add(
        CompleteLogin(
          username: 'Test username',
          password: 'Test password',
        ),
      ),
      expect: <dynamic>[
        isA<LoginCompletionState>(),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'emits [LoginErrorState] when non existent user failure',
      build: () {
        when(
          mockUserService.checkCredentials(
            password: anyNamed('password'),
            username: anyNamed('username'),
          ),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            Left<Failure, void>(NonExistentUserFailure()),
          ),
        );

        return RegistrationBloc(mockUserService);
      },
      act: (RegistrationBloc bloc) => bloc.add(
        CompleteLogin(
          username: 'Test username',
          password: 'Test password',
        ),
      ),
      expect: <dynamic>[
        isA<LoginErrorState>(),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'emits [LoginErrorState] when user signing failure',
      build: () {
        when(
          mockUserService.checkCredentials(
            password: anyNamed('password'),
            username: anyNamed('username'),
          ),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            Left<Failure, void>(UserSigningFailure()),
          ),
        );

        return RegistrationBloc(mockUserService);
      },
      act: (RegistrationBloc bloc) => bloc.add(
        CompleteLogin(
          username: 'Test username',
          password: 'Test password',
        ),
      ),
      expect: <dynamic>[
        isA<LoginErrorState>(),
      ],
    );
  });
}
