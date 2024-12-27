class ResetPasswordException implements Exception {
  /// The error message.
  final String message;

  /// Creates a [ResetPasswordException].
  ResetPasswordException(this.message);

  @override
  String toString() => 'ResetPasswordException: $message';
}
