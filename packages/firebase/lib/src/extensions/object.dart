extension FirebaseMapping on Object? {
  Map<String, dynamic> toMap() {
    try {
      return this as Map<String, dynamic>;
    } on Exception catch (e) {
      rethrow;
    }
  }
}
