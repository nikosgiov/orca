class AppError {
  final String message;
  final String? type;
  final StackTrace? stackTrace;

  AppError({required this.message, this.type, this.stackTrace});

  @override
  String toString() => 'AppError(type: $type, message: $message)';
} 