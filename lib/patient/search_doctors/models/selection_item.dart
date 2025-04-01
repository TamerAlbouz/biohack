class SelectionItem {
  final String title;
  final String subtitle;
  final Object? value;
  final int? price;

  SelectionItem({
    required this.title,
    required this.subtitle,
    this.value,
    this.price,
  });
}
