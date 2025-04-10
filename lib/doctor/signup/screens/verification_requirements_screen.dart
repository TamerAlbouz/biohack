import 'package:flutter/material.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/doctor/signup/screens/signup_doctor_screen.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../../styles/font.dart';
import '../../../styles/styles/button.dart';

class VerificationRequirementsScreen extends StatefulWidget {
  const VerificationRequirementsScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const VerificationRequirementsScreen(),
    );
  }

  @override
  State<VerificationRequirementsScreen> createState() =>
      _VerificationRequirementsScreenState();
}

class _VerificationRequirementsScreenState
    extends State<VerificationRequirementsScreen> {
  bool _isCheckboxChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        centerTitle: false,
        title: const Text(
          'Healthcare Provider Verification',
          style: TextStyle(
            fontSize: Font.medium,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: kPaddH20V10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please review the requirements below and prepare the necessary documentation for verification.',
                style: kAppIntroSubtitle,
              ),

              kGap14,

              // Rest of the existing content...
              const _RequirementSection(
                icon: Icons.shield_outlined,
                color: Colors.red,
                title: 'Required Documentation',
                items: [
                  'CPSNS License Number (College of Physicians and Surgeons of Nova Scotia)',
                  'Government-issued photo ID (ID, passport, or driver\'s license)',
                  'Medical Credentials (Degree and Training Documents)',
                  'Specialty (Orthopedic Surgeon, Family Physician, etc.)',
                ],
              ),

              kGap14,

              const CustomBase(
                shadow: false,
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.blue, size: 24),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Most verifications are completed within 2-3 business days when all documentation is provided.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              kGap14,

              CheckboxListTile(
                activeColor: MyColors.primary,
                value: _isCheckboxChecked,
                onChanged: (value) {
                  setState(() {
                    _isCheckboxChecked = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I have read and understood the requirements',
                  style: TextStyle(fontSize: 14),
                ),
                dense: true,
                contentPadding: kPadd0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),

              kGap14,
              ElevatedButton(
                style: kElevatedButtonCommonStyle,
                onPressed: _isCheckboxChecked
                    ? () {
                        // push and remove only this screen
                        AppGlobal.navigatorKey.currentState!.pushReplacement(
                          SignUpDoctorScreen.route(),
                        );
                      }
                    : null,
                child: const Text('Proceed'),
              ),
              kGap10,
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final List<String> items;

  const _RequirementSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.items,
    // ignore: unused_element_parameter
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBase(
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              kGap8,
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: Font.smallExtra,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            kGap8,
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: Font.extraSmall,
                color: Colors.black87,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
