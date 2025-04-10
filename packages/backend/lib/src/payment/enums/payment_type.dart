enum PaymentType {
  cash,
  creditCard,
  insurance,
}

extension PaymentTypeExtension on PaymentType {
  String get value {
    switch (this) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.creditCard:
        return 'Credit Card';
      case PaymentType.insurance:
        return 'Insurance';
    }
  }
}
