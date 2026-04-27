import 'app_error.dart';

sealed class AppState<T> {
  const AppState();
}

final class AppInitial<T> extends AppState<T> {
  const AppInitial();
}

final class AppLoading<T> extends AppState<T> {
  const AppLoading({this.message});
  final String? message;
}

final class AppSuccess<T> extends AppState<T> {
  const AppSuccess(this.data);
  final T data;
}

final class AppStateError<T> extends AppState<T> {
  const AppStateError(this.failure);
  final AppError failure;

  @override
  String toString() => 'AppStateError(failure: $failure)';
}
