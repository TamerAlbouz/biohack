abstract class IMailRepository {
  Future<void> sendMail({
    required String to,
    required String templateName,
    required Map<String, dynamic> templateData,
  });
}
