import '../models/service.dart';

abstract class IServiceRepository {
  Future<List<Service>> fetchServices(String doctorId);

  Future<Service> createService(Service service);

  Future<void> updateService(Service service);

  Future<void> deleteService(String doctorId, String serviceId);
}
