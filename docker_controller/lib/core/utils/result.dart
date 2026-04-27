
/// A functional Result type to handle success and failure states.
sealed class Result<S, E> {
  const Result();
  
  factory Result.success(S value) => Success(value);
  factory Result.failure(E exception) => Failure(exception);

  /// Returns true if this is a [Success] result.
  bool get isSuccess => this is Success<S, E>;

  /// Returns true if this is a [Failure] result.
  bool get isFailure => this is Failure<S, E>;

  /// Returns the value if this is a [Success], otherwise null.
  S? get valueOrNull => this is Success<S, E> ? (this as Success<S, E>).value : null;

  /// Returns the exception if this is a [Failure], otherwise null.
  E? get exceptionOrNull => this is Failure<S, E> ? (this as Failure<S, E>).exception : null;

  /// Executes [onSuccess] if this is a [Success], or [onFailure] if this is a [Failure].
  T fold<T>(T Function(S value) onSuccess, T Function(E exception) onFailure) {
    if (this is Success<S, E>) {
      return onSuccess((this as Success<S, E>).value);
    } else {
      return onFailure((this as Failure<S, E>).exception);
    }
  }
}

/// Represents a successful result containing [value].
final class Success<S, E> extends Result<S, E> {
  const Success(this.value);
  final S value;
}

/// Represents a failed result containing [exception].
final class Failure<S, E> extends Result<S, E> {
  const Failure(this.exception);
  final E exception;
}
