import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../styles/font.dart';
import '../base/custom_base.dart';
import '../dummy/profile_picture.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String availability;
  final List<String> timeSlots;
  final String date;
  final String month;
  final String? imageUrl;
  final Function()? onCardTap;
  final void Function(String, int)? onTimeSlotSelected;
  final int? selectedTimeSlot;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.availability,
    required this.timeSlots,
    this.date = '12',
    this.month = 'Oct',
    this.imageUrl,
    this.onCardTap,
    this.onTimeSlotSelected,
    this.selectedTimeSlot,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: CustomBase(
        padding: kPadd16,
        shadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture with shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const ProfilePicture(
                          height: 60,
                          width: 60,
                        ),
                ),
                kGap16,
                // Doctor Info
                Expanded(
                  child: _DoctorInfo(
                    name: name,
                    specialty: specialty,
                    availability: availability,
                  ),
                ),
                // Date Container
                _DateContainer(date: date, month: month),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  final String name;
  final String specialty;
  final String availability;

  const _DoctorInfo({
    required this.name,
    required this.specialty,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: Font.mediumSmall,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        kGap4,
        Row(
          children: [
            const Icon(
              Icons.medical_services_outlined,
              size: 12,
              color: MyColors.textGrey,
            ),
            kGap4,
            Text(
              specialty,
              style: const TextStyle(
                fontSize: Font.extraSmall,
                color: MyColors.textGrey,
              ),
            ),
          ],
        ),
        kGap8,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: MyColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 12,
                color: MyColors.primary,
              ),
              kGap4,
              Text(
                availability,
                style: const TextStyle(
                  fontSize: Font.extraSmall,
                  color: MyColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateContainer extends StatelessWidget {
  final String date;
  final String month;

  const _DateContainer({
    required this.date,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPaddH10V6,
      decoration: BoxDecoration(
        border: Border.all(
          color: MyColors.primary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: MyColors.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MyColors.primary,
              fontSize: Font.medium,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            width: 24,
            height: 1,
            color: MyColors.primary.withValues(alpha: 0.5),
          ),
          Text(
            month,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MyColors.primary,
              fontSize: Font.extraSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
