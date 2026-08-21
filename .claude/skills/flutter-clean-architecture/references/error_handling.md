# Error Handling Pattern

## Failure classes (domain layer)

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
```

## Exceptions (data layer)

Datasources throw plain exceptions — they never know about `Failure`:

```dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
```

## Mapping in the repository

The repository is the single place exceptions become failures:

```dart
@override
Future<Either<Failure, User>> getUser(String id) async {
  try {
    final model = await remoteDataSource.getUser(id);
    return Right(model.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  }
}
```

## Consuming in the Cubit

```dart
Future<void> fetchUser(String id) async {
  emit(const UserState.loading());
  final result = await getUserUseCase(id);
  result.fold(
    (failure) => emit(UserState.error(failure.message)),
    (user) => emit(UserState.loaded(user)),
  );
}
```

## When to skip Either

For a genuinely trivial operation with no meaningful failure mode (e.g. toggling a local UI-only flag), a plain try-catch or no error handling at all is fine — don't wrap everything in `Either` reflexively. Use judgment: if it crosses a network/disk/Firebase boundary, use `Either`.
