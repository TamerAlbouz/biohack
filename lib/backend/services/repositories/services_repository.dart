import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/services/exceptions/service_exception.dart';

import '../interfaces/services_interface.dart';
import '../models/service.dart';

@LazySingleton(as: IServiceRepository)
class ServicesRepository implements IServiceRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _doctorsCollection;
  final Logger logger;

  ServicesRepository(this._firestore, this.logger) {
    _doctorsCollection = _firestore.collection('doctors');
  }

  @override
  Future<List<Service>> fetchServices(String doctorId) async {
    try {
      final querySnapshot =
          await _doctorsCollection.doc(doctorId).collection('services').get();

      return querySnapshot.docs
          .map((doc) => Service.fromDocument(doc))
          .toList();
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw ServiceException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<Service> createService(String docId, Service service) async {
    try {
      final docRef = _doctorsCollection.doc(docId).collection('services').doc();

      final newService = service.copyWith(uid: docRef.id);
      await docRef.set({
        'title': newService.title,
        'description': newService.description,
        'duration': newService.duration,
        'price': newService.price,
        'isOnline': newService.isOnline,
        'isInPerson': newService.isInPerson,
        'isHomeVisit': newService.isHomeVisit,
        'preAppointmentInstructions':
            newService.preAppointmentInstructions ?? '',
        'customAvailability': newService.customAvailability?.toJson(),
      });

      return newService;
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw ServiceException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> updateService(String docId, Service service) async {
    try {
      await _doctorsCollection
          .doc(docId)
          .collection('services')
          .doc(service.uid)
          .update(service.toJson());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw ServiceException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteService(String docId, String serviceId) async {
    try {
      await _doctorsCollection
          .doc(docId)
          .collection('services')
          .doc(serviceId)
          .delete();
    } on FirebaseException catch (e) {
      logger.e(e.message);
      throw ServiceException.fromCode(e.code);
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
