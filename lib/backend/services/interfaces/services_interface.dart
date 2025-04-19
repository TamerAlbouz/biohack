import '../models/service.dart';

abstract class IServiceRepository {
  Future<List<Service>> fetchServices(String doctorId);

  Future<Service> createService(String docId, Service service);

  Future<void> updateService(String docId, Service service);

  Future<void> deleteService(String docId, String serviceId);
}
