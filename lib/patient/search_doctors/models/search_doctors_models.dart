class PatientReview {
  final String author;
  final String text;
  final DateTime date;

  PatientReview({
    required this.author,
    required this.text,
    required this.date,
  });
}

class SavedCreditCard {
  final String id;
  final String cardNumber; // Last 4 digits only
  final String cardholderName;
  final String expiryDate;
  final String cardType; // Visa, Mastercard, etc.
  final bool isDefault;

  SavedCreditCard({
    required this.id,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cardType,
    this.isDefault = false,
  });
}
