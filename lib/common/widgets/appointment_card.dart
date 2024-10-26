import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medtalk/common/widgets/tag.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.cardAppointmentInfo,
    required this.cardAppointmentMetadata,
  });

  final CardAppointmentInfo cardAppointmentInfo;
  final CardAppointmentMetadata cardAppointmentMetadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: kRadius20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cardAppointmentInfo,
          kGap4,
          cardAppointmentMetadata,
        ],
      ),
    );
  }
}

class CardAppointmentInfo extends StatelessWidget {
  const CardAppointmentInfo(
      {super.key,
      required this.specialty,
      required this.doctor,
      required this.date,
      required this.time,
      required this.location});

  final String specialty;
  final String doctor;
  final String date;
  final String time;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: kPadd0,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius20,
      ),
      child: Container(
        padding: kPaddH20V15,
        width: double.infinity,
        decoration: BoxDecoration(
          color: MyColors.card,
          borderRadius: kRadius20,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 2),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(specialty,
                    style: const TextStyle(
                        fontSize: Font.medium,
                        color: MyColors.purple,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                const Tag(),
              ],
            ),
            kGap2,
            Text(doctor,
                style: const TextStyle(
                    fontSize: Font.cardSubTitleSize,
                    fontWeight: FontWeight.normal,
                    color: MyColors.subtitle)),
            kGap6,
            Text("📅  $date | $time",
                style: const TextStyle(
                    fontSize: Font.extraSmall, color: Colors.black)),
            Text('🏥  $location',
                style: const TextStyle(
                    fontSize: Font.extraSmall, color: Colors.black)),
            kGap6,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.of(context).push(AppointmentScreen.route());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(32),
                  // Adjust the height as needed
                  backgroundColor: MyColors.purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: kRadiusAll,
                  ),
                ),
                child: const Text(
                  'Join Call',
                  style: TextStyle(
                    fontSize: Font.extraSmall,
                    fontWeight: FontWeight.bold,
                    color: MyColors.textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardAppointmentMetadata extends StatelessWidget {
  const CardAppointmentMetadata({
    super.key,
    required this.doctor,
    required this.service,
    required this.fee,
  });

  final String doctor;
  final String service;
  final String fee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPaddH20V15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardAppointMetaInfo(
            svgAssetPath: 'assets/svgs/Tick.svg',
            title: service,
            text: '\$$fee',
          ),
          const CardAppointMetaInfo(
            svgAssetPath: 'assets/svgs/Profile.svg',
            title: 'Doctor',
            text: 'First-Time',
          ),
          kGap6,
          const Divider(
            color: MyColors.cardDivider,
            thickness: 1,
          ),
          kGap6,
          Text("Before starting, some info on $doctor",
              style: const TextStyle(
                  fontSize: Font.extraSmall,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          // bullet points
          kGap6,
          const Text("•  10+ years of experience",
              style: TextStyle(
                  fontSize: Font.tag,
                  color: Colors.black,
                  fontWeight: FontWeight.normal)),
          const Text("•  Specializes in Glaucoma",
              style: TextStyle(
                  fontSize: Font.tag,
                  color: Colors.black,
                  fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }
}

class CardAppointMetaInfo extends StatelessWidget {
  final String svgAssetPath;
  final String title;
  final String text;

  const CardAppointMetaInfo({
    super.key,
    required this.svgAssetPath,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          svgAssetPath,
          width: 24,
          height: 24,
        ),
        Text(title,
            style: const TextStyle(
                fontSize: Font.extraSmall,
                color: MyColors.subtitle,
                fontWeight: FontWeight.normal)),
        const Spacer(),
        Text(text,
            style: const TextStyle(
                fontSize: Font.extraSmall,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
