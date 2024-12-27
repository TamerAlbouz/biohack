class SendResetPasswordException implements Exception {
  /// The error message.
  final String message;

  /// Creates a [SendResetPasswordException].
  SendResetPasswordException(this.message);

  @override
  String toString() => 'SendResetPasswordException: $message';
}
