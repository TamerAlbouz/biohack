abstract class IHashRepository {
  Future<String> hash(String password);

  Future<bool> verify(String password, String storedHash);
}
