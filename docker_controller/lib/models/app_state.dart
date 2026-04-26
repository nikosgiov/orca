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

final class AppError<T> extends AppState<T> {
  const AppError({required this.message, this.error, this.stackTrace});
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppError(message: $message, error: $error)';
}
