import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/styles/colors.dart';

import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../dummy/profile_picture.dart';
import '../rounded_radio_button.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String availability;
  final List<String> timeSlots;
  final Function()? onCardTap;
  final void Function(String)? onTimeSlotSelected;

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
          padding: kPaddH20V15,
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
                  // faicon right arrow
                  const FaIcon(
                    FontAwesomeIcons.chevronRight,
                    color: Colors.black,
                  ),
                ],
              ),
              kGap14,
              RadioButtonGroup(
                options: timeSlots,
                decoration: BoxDecoration(
                  color: MyColors.blue,
                  borderRadius: kRadiusAll,
                ),
                contentPadding: kPaddH10V2,
                selectedColor: MyColors.blue,
                unselectedColor: MyColors.blue,
                unselectedTextColor: Colors.white,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: Font.extraSmall,
                ),
                onChanged: onTimeSlotSelected ?? (value) {},
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
    super.key,
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
            fontSize: Font.medium,
            color: MyColors.blue,
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
        kGap4,
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
