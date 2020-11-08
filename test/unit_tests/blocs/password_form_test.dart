import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/blocs/blocs.dart';
import 'package:password_wallet/src/services/password_service.dart';
import 'package:password_wallet/src/utils/failure.dart';

class MockPasswordService extends Mock implements PasswordService {}

void main() {
  final MockPasswordService mockPasswordService = MockPasswordService();

  setUp(() {
    reset(mockPasswordService);
  });

  group('Password Form BLoC', () {
    blocTest<PasswordFormBloc, PasswordFormState>(
      'emits [PasswordFormCompletedState] when successful',
      build: () {
        when(
          mockPasswordService.addPassword(
              login: anyNamed('login'),
              webAddress: anyNamed('webAddress'),
              password: anyNamed('password'),
              description: anyNamed('description'),
              username: anyNamed('username'),
              userPassword: anyNamed('userPassword')),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(const Right<Failure, void>(null)),
        );

        return PasswordFormBloc(mockPasswordService);
      },
      act: (PasswordFormBloc bloc) => bloc.add(const PasswordFormEvent(
        login: 'Test Login',
        webAddress: 'google.com',
        password: 'test',
        description: 'My test password.',
        username: 'test',
        userPassword: 'test',
      )),
      expect: <dynamic>[
        isA<PasswordFormCompletedState>(),
      ],
    );

    blocTest<PasswordFormBloc, PasswordFormState>(
      'emits [PasswordFormIncorrectState] when non existent user failure',
      build: () {
        when(
          mockPasswordService.addPassword(
              login: anyNamed('login'),
              webAddress: anyNamed('webAddress'),
              password: anyNamed('password'),
              description: anyNamed('description'),
              username: anyNamed('username'),
              userPassword: anyNamed('userPassword')),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            Left<Failure, void>(NonExistentUserFailure()),
          ),
        );

        return PasswordFormBloc(mockPasswordService);
      },
      act: (PasswordFormBloc bloc) => bloc.add(const PasswordFormEvent(
        login: 'Test Login',
        webAddress: 'google.com',
        password: 'test',
        description: 'My test password.',
        username: 'test',
        userPassword: 'test',
      )),
      expect: <dynamic>[
        isA<PasswordFormIncorrectState>(),
      ],
    );

    blocTest<PasswordFormBloc, PasswordFormState>(
      'emits [PasswordFormIncorrectState] when password creation failure',
      build: () {
        when(
          mockPasswordService.addPassword(
              login: anyNamed('login'),
              webAddress: anyNamed('webAddress'),
              password: anyNamed('password'),
              description: anyNamed('description'),
              username: anyNamed('username'),
              userPassword: anyNamed('userPassword')),
        ).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            Left<Failure, void>(PasswordCreationFailure()),
          ),
        );

        return PasswordFormBloc(mockPasswordService);
      },
      act: (PasswordFormBloc bloc) => bloc.add(const PasswordFormEvent(
        login: 'Test Login',
        webAddress: 'google.com',
        password: 'test',
        description: 'My test password.',
        username: 'test',
        userPassword: 'test',
      )),
      expect: <dynamic>[
        isA<PasswordFormIncorrectState>(),
      ],
    );
  });
}
