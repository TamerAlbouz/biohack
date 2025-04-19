sealed class CryptoData {}

class StringData extends CryptoData {
  final String value;

  StringData(this.value);
}

class BinaryData extends CryptoData {
  final List<int> value;

  BinaryData(this.value);
}

class CryptoResult {
  final bool status;
  final CryptoData? data;
  final String? error;

  CryptoResult({this.data, required this.status, this.error});
}
