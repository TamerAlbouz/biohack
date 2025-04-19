import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../exceptions/mail_exceptions.dart';
import '../interfaces/mail_interface.dart';
import '../models/mail_model.dart';

@LazySingleton(as: IMailRepository)
class MailRepository implements IMailRepository {
  final FirebaseFirestore _firestore;
  final Logger logger;

  MailRepository(this._firestore, this.logger);

  @override
  Future<void> sendMail({
    required String to,
    required String templateName,
    required Map<String, dynamic> templateData,
  }) async {
    try {
      final mail = Mail(
        to: to,
        templateName: templateName,
        templateData: templateData,
      );

      logger.i('Sending mail: ${mail.to}');
      await _firestore.collection('mail').add(mail.toFirestore());
    } catch (e) {
      logger.e('Failed to send mail: $e');
      throw MailSendException('Failed to send mail: $e');
    }
  }
}
