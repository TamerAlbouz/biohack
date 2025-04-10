class SelectionItem {
  final String title;
  final String subtitle;
  final Object? value;
  final int? price;
  final String? description;
  final bool hasOnline;
  final bool hasInPerson;
  final bool hasHomeVisit;
  final String? preAppointmentInstructions;

  SelectionItem({
    required this.title,
    required this.subtitle,
    this.value,
    this.price,
    this.description = '',
    this.hasOnline = false,
    this.hasInPerson = false,
    this.hasHomeVisit = false,
    this.preAppointmentInstructions,
  });
}
