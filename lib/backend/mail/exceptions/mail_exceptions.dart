class MailException implements Exception {
  final String message;

  MailException(this.message);

  @override
  String toString() => 'MailException: $message';
}

class MailSendException extends MailException {
  MailSendException(super.message);
}

class TemplateNotFoundException extends MailException {
  TemplateNotFoundException(super.message);
}
