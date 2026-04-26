class AppError {
  AppError({required this.message, this.type, this.stackTrace});
  final String message;
  final String? type;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppError(type: $type, message: $message)';
}
