import 'package:flutter/material.dart';
import 'package:medtalk/styles/colors.dart';

import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../dummy/profile_picture.dart';
import '../radio/rounded_radio_button.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String availability;
  final List<String> timeSlots;
  final Function()? onCardTap;
  final void Function(String, int)? onTimeSlotSelected;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.availability,
    required this.timeSlots,
    this.onCardTap,
    this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Card(
        margin: kPadd0,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius20,
        ),
        elevation: 0,
        child: Padding(
          padding: kPadd15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // space between
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const ProfilePicture(),
                  kGap20,
                  _DoctorInfo(
                    name: name,
                    specialty: specialty,
                    availability: availability,
                  ),
                  const Spacer(),
                  // show date
                  Container(
                    // outlined
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: MyColors.green,
                        width: 1,
                      ),
                      borderRadius: kRadius10,
                    ),
                    width: 50,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '12',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: MyColors.green,
                            fontSize: Font.medium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(
                          color: MyColors.green.withOpacity(0.5),
                          thickness: 1,
                          height: 3,
                        ),
                        const Text(
                          'Oct',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: MyColors.green,
                            fontSize: Font.extraSmall,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              kGap14,
              RadioButtonGroup(
                options: timeSlots,
                decoration: BoxDecoration(
                  color: MyColors.primary,
                  borderRadius: kRadiusAll,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 1.5,
                ),
                selectedColor: MyColors.primary,
                unselectedColor: MyColors.primary,
                unselectedTextColor: Colors.white,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: Font.extraSmall,
                ),
                onChanged: onTimeSlotSelected ?? (value, index) {},
              ),
            ],
          ),
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
            color: MyColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          specialty,
          style: const TextStyle(
            fontSize: Font.extraSmall,
            color: MyColors.textGrey,
          ),
        ),
        kGap8,
        Text(
          availability,
          style: const TextStyle(
            fontSize: Font.extraSmall,
            color: MyColors.green,
          ),
        ),
      ],
    );
  }
}
