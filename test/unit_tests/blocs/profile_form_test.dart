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

  group('Profile Form BLoC', () {
    blocTest<ProfileFormBloc, ProfileFormState>(
      'emits [ProfileFormCompletedState] when successful',
      build: () {
        when(mockUserService.changePassword(
          newUserPassword: anyNamed('newUserPassword'),
          oldUserPassword: anyNamed('oldUserPassword'),
          username: anyNamed('username'),
        )).thenAnswer(
          (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            const Right<Failure, void>(null),
          ),
        );

        return ProfileFormBloc(mockUserService);
      },
      act: (ProfileFormBloc bloc) => bloc.add(
        const ProfileFormEvent(
          username: 'Test Username',
          oldPassword: 'Test Old Password',
          newPassword: 'Test New Password',
        ),
      ),
      expect: <dynamic>[
        isA<ProfileFormCompletedState>(),
      ],
    );

    blocTest<ProfileFormBloc, ProfileFormState>(
      'emits [ProfileFormIncorrectState] when user update failure',
      build: () {
        when(mockUserService.changePassword(
          newUserPassword: anyNamed('newUserPassword'),
          oldUserPassword: anyNamed('oldUserPassword'),
          username: anyNamed('username'),
        )).thenAnswer(
              (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            Left<Failure, void>(UserUpdateFailure()),
          ),
        );

        return ProfileFormBloc(mockUserService);
      },
      act: (ProfileFormBloc bloc) => bloc.add(
        const ProfileFormEvent(
          username: 'Test Username',
          oldPassword: 'Test Old Password',
          newPassword: 'Test New Password',
        ),
      ),
      expect: <dynamic>[
        isA<ProfileFormIncorrectState>(),
      ],
    );

    blocTest<ProfileFormBloc, ProfileFormState>(
      'emits [ProfileFormIncorrectState] when non existent user failure',
      build: () {
        when(mockUserService.changePassword(
          newUserPassword: anyNamed('newUserPassword'),
          oldUserPassword: anyNamed('oldUserPassword'),
          username: anyNamed('username'),
        )).thenAnswer(
              (Invocation realInvocation) => Future<Either<Failure, void>>.value(
            Left<Failure, void>(NonExistentUserFailure()),
          ),
        );

        return ProfileFormBloc(mockUserService);
      },
      act: (ProfileFormBloc bloc) => bloc.add(
        const ProfileFormEvent(
          username: 'Test Username',
          oldPassword: 'Test Old Password',
          newPassword: 'Test New Password',
        ),
      ),
      expect: <dynamic>[
        isA<ProfileFormIncorrectState>(),
      ],
    );
  });
}
