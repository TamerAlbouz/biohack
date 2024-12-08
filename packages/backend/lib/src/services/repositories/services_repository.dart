import 'package:backend/src/services/exceptions/service_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:p_logger/p_logger.dart';

import '../interfaces/services_interface.dart';
import '../models/service.dart';

@LazySingleton(as: IServiceRepository)
class ServicesRepository implements IServiceRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _doctorsCollection;

  ServicesRepository(this._firestore) {
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
  Future<Service> createService(Service service) async {
    try {
      final docRef =
          _doctorsCollection.doc(service.doctorId).collection('services').doc();

      final newService = service.copyWith(id: docRef.id);
      await docRef.set({
        'doctorId': newService.doctorId,
        'name': newService.name,
        'description': newService.description,
        'duration': newService.duration,
        'price': newService.price,
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
  Future<void> updateService(Service service) async {
    try {
      await _doctorsCollection
          .doc(service.doctorId)
          .collection('services')
          .doc(service.id)
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
  Future<void> deleteService(String doctorId, String serviceId) async {
    try {
      await _doctorsCollection
          .doc(doctorId)
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
