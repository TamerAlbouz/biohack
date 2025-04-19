class Mail {
  final String to;
  final String templateName;
  final Map<String, dynamic> templateData;

  const Mail({
    required this.to,
    required this.templateName,
    required this.templateData,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'to': [to],
      'template': {
        'name': templateName,
        'data': templateData,
      },
    };
  }
}
