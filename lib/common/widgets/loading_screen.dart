import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/sizes.dart';

class LoadingMedicalScreen extends StatelessWidget {
  const LoadingMedicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: MyColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svgs/Logo.svg',
                  width: 80,
                  height: 80,
                  color: MyColors.white,
                  fit: BoxFit.fill,
                  // Fallback to icon if image isn't available during testing
                  placeholderBuilder: (context) => const Icon(
                    Icons.medical_services_rounded,
                    size: 60,
                    color: MyColors.primary,
                  ),
                ),
              ),
            ),

            kGap40,

            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(MyColors.primary),
              ),
            ),

            kGap24,

            // App name
            const Text(
              'MedTalk',
              style: TextStyle(
                fontSize: Font.large,
                fontWeight: FontWeight.bold,
                color: MyColors.primary,
              ),
            ),

            kGap8,

            // Tagline
            const Text(
              'Connecting doctors and patients',
              style: TextStyle(
                fontSize: Font.small,
                color: MyColors.subtitleDark,
              ),
            ),

            kGap80,
          ],
        ),
      ),
    );
  }
}
