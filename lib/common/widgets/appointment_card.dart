import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medtalk/common/widgets/tag.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';

class AppointmentWidget extends StatelessWidget {
  const AppointmentWidget({
    super.key,
    required this.specialty,
    required this.doctor,
    required this.date,
    required this.time,
    required this.location,
    required this.service,
    required this.fee,
    required this.onJoinCall,
  });

  final String specialty;
  final String doctor;
  final String date;
  final String time;
  final String location;
  final String service;
  final String fee;
  final void Function() onJoinCall;

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
          _AppointmentCard(
            specialty: specialty,
            doctor: doctor,
            date: date,
            time: time,
            location: location,
            onJoinCall: onJoinCall,
          ),
          kGap4,
          _CardAppointmentMetadata(
            doctor: doctor,
            service: service,
            fee: fee,
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  /// Displays primary details about the appointment, such as specialty, doctor name, date, time, and location.
  ///
  /// [CardAppointmentInfo] is a part of the [AppointmentWidget] that shows essential information
  /// along with a "Join Call" button for easy access.
  ///
  /// ### Properties:
  ///
  /// * [specialty] (required): The medical specialty of the appointment (e.g., 'Cardiology').
  /// * [doctor] (required): The name of the doctor (e.g., 'Dr. Smith').
  /// * [date] (required): The date of the appointment (e.g., 'Sep 20, 2023').
  /// * [time] (required): The time of the appointment (e.g., '10:00 AM').
  /// * [location] (required): The location of the appointment (e.g., 'Room 202').
  ///
  /// ### Build Method:
  ///
  /// The main information is arranged in a column with labels and a button to join the call.
  const _AppointmentCard(
      {required this.specialty,
      required this.doctor,
      required this.date,
      required this.time,
      required this.location,
      required this.onJoinCall});

  /// The medical specialty of the appointment (e.g., 'Cardiology').
  ///
  /// Example:
  /// ```dart
  /// 'Cardiology'
  /// ```
  final String specialty;

  /// The name of the doctor.
  ///
  /// Example:
  /// ```dart
  /// 'Dr. Smith'
  /// ```
  final String doctor;

  /// The date of the appointment.
  ///
  /// Example:
  /// ```dart
  /// 'Sep 20, 2023'
  /// ```
  final String date;

  /// The time of the appointment.
  ///
  /// Example:
  /// ```dart
  /// '10:00 AM'
  /// ```
  final String time;

  /// The location of the appointment.
  ///
  /// Example:
  /// ```dart
  /// 'Room 202'
  /// ```
  final String location;

  /// The action to take when the user taps the "Join Call" button.
  ///
  /// Example:
  /// ```dart
  /// () {
  ///  Navigator.of(context).push(AppointmentScreen.route());
  /// }
  /// ```
  final void Function() onJoinCall;

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
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 8),
              blurRadius: 12,
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
                        color: MyColors.blue,
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
                onPressed: onJoinCall,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(32),
                  // Adjust the height as needed
                  backgroundColor: MyColors.blue,
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
                    color: MyColors.buttonText,
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

class _CardAppointmentMetadata extends StatelessWidget {
  /// Displays additional metadata for the appointment, including the service type, fee, and doctor’s experience.
  ///
  /// [CardAppointmentMetadata] is a component of [AppointmentWidget] that provides extra information
  /// like the service type and fee, along with a short bio of the doctor’s experience and specialties.
  ///
  /// ### Properties:
  ///
  /// * [doctor] (required): The name of the doctor (used in informational text).
  /// * [service] (required): The type of service provided in the appointment (e.g., 'Consultation').
  /// * [fee] (required): The fee for the service (e.g., '100').
  ///
  /// ### Build Method:
  ///
  /// This section is displayed below the main appointment information and includes metadata items such as service and fee,
  /// followed by an informational section on the doctor’s background.
  const _CardAppointmentMetadata({
    required this.doctor,
    required this.service,
    required this.fee,
  });

  /// The name of the doctor (used in informational text).
  ///
  /// Example:
  /// ```dart
  /// 'Dr. John Doe'
  /// ```
  final String doctor;

  /// The type of service provided in the appointment.
  ///
  /// Example:
  /// ```dart
  /// 'Consultation'
  /// ```
  final String service;

  /// The fee for the service.
  ///
  /// Example:
  /// ```dart
  /// '100'
  /// ```
  final String fee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPaddH20V15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardAppointMetaInfo(
            svgAssetPath: 'assets/svgs/Tick.svg',
            title: service,
            text: '\$$fee',
          ),
          const _CardAppointMetaInfo(
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

class _CardAppointMetaInfo extends StatelessWidget {
  /// Path to the SVG asset for the icon.
  ///
  /// Example:
  /// ```dart
  /// 'assets/svgs/Tick.svg'
  /// ```
  final String svgAssetPath;

  /// Title for the row, such as 'Service'.
  ///
  /// Example:
  /// ```dart
  /// 'Service'
  /// ```
  final String title;

  /// Descriptive text for the row, such as the service fee or experience level.
  ///
  /// Example:
  /// ```dart
  /// '\$100'
  /// ```
  final String text;

  /// A reusable widget to display a metadata row with an icon, title, and text.
  ///
  /// [CardAppointMetaInfo] is used in [CardAppointmentMetadata] to provide a formatted row with an SVG icon, title text, and description.
  ///
  /// ### Properties:
  ///
  /// * [svgAssetPath] (required): Path to the SVG asset for the icon (e.g., 'assets/svgs/Tick.svg').
  /// * [title] (required): Title for the row, such as 'Service'.
  /// * [text] (required): Descriptive text for the row, such as the service fee or experience level.
  ///
  /// ### Build Method:
  ///
  /// Each row contains an SVG icon and two texts arranged horizontally, with the title aligned to the left and the text to the right.
  const _CardAppointMetaInfo({
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
