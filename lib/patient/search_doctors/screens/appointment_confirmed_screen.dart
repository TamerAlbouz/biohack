import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/patient/search_doctors/widgets/summary_entry.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../styles/colors.dart';
import '../../../styles/font.dart';

class AppointmentConfirmedScreen extends StatelessWidget {
  const AppointmentConfirmedScreen({super.key});

  // route function
  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const AppointmentConfirmedScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30.0,
        leading: IconButton(
          // "x" icon
          icon: const Icon(Icons.close),
          onPressed: () {
            AppGlobal.navigatorKey.currentState!.pop();
          },
        ),
      ),
      body: Padding(
        padding: kPadd20,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.solidCalendarCheck,
                color: MyColors.buttonGreen,
                size: 45.0,
              ),
              kGap12,
              const Text(
                'Appointment Booked',
                style: TextStyle(
                  fontFamily: Font.family,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap20,
              // date, service, price
              const SummaryEntry(title: 'Date', value: 'Sep 20, 2023'),
              const SummaryEntry(title: 'Service', value: 'Eye Checkup'),
              const SummaryEntry(title: 'Price', value: '\$100'),
              kGap20,
              ElevatedButton(
                onPressed: () {
                  AppGlobal.navigatorKey.currentState!.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
