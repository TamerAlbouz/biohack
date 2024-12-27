import 'package:flutter/material.dart';
import 'package:medtalk/common/widgets/random_hexagons.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoadingScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          HexagonPatternBox(
            height: 200,
            width: double.infinity,
          )
        ],
      ),
    );
  }
}
