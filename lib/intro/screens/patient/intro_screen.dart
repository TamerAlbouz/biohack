import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const IntroScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
