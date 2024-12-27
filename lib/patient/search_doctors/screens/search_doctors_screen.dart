import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/dividers/section_divider.dart';
import 'package:medtalk/common/widgets/dropdown/custom_complex_dropdown.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointment_screen.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../common/globals/globals.dart';
import '../../../common/widgets/cards/doctor_card.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';

class SearchDoctorsScreen extends StatelessWidget {
  const SearchDoctorsScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SearchDoctorsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Search Doctors',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: Font.sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Find the right doctor for you',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: Font.small,
                color: MyColors.subtitleDark,
              ),
            ),
            const SectionDivider(),
            kGap10,
            CustomComplexDropDown(
              title: 'Specialty',
              items: const [
                'Cardiology',
                'Dermatology',
                'Endocrinology',
                'Gastroenterology',
                'General Practice',
                'Geriatrics',
                'Hematology',
                'Infectious Disease',
                'Internal Medicine',
                'Nephrology',
                'Neurology',
                'Obstetrics and Gynecology',
                'Oncology',
                'Ophthalmology',
                'Orthopedics',
                'Otolaryngology',
                'Pediatrics',
                'Physical Medicine and Rehabilitation',
                'Plastic Surgery',
                'Podiatry',
                'Psychiatry',
                'Pulmonology',
                'Radiology',
                'Rheumatology',
                'Surgery',
                'Urology'
              ],
              onChanged: (value) {},
              borderRadius: kRadiusAll,
              defaultOption: "All Specialties",
              icon: const FaIcon(FontAwesomeIcons.stethoscope,
                  color: MyColors.primary),
            ),
            kGap10,
            CustomComplexDropDown(
              title: 'Availability',
              items: const [
                'Tomorrow, Oct 12',
                'Wednesday, Oct 13',
                'Thursday, Oct 14',
                'Friday, Oct 15',
                'Saturday, Oct 16',
                'Sunday, Oct 17',
                'Monday, Oct 18',
                'Tuesday, Oct 19',
                'Wednesday, Oct 20',
                'Thursday, Oct 21',
                'Friday, Oct 22',
                'Saturday, Oct 23',
                'Sunday, Oct 24',
                'Monday, Oct 25',
                'Tuesday, Oct 26',
                'Wednesday, Oct 27',
                'Thursday, Oct 28',
                'Friday, Oct 29',
              ],
              onChanged: (value) {},
              borderRadius: kRadiusAll,
              defaultOption: "Today, Oct 11",
              icon: const FaIcon(FontAwesomeIcons.calendar,
                  color: MyColors.primary),
            ),
            kGap20,
            CustomInputField(
              hintText: 'Search by name',
              onChanged: (value) {},
              keyboardType: TextInputType.text,
              errorText: null,
              height: 50,
              borderRadius: kRadiusAll,
            ),
            kGap10,
            const SectionDivider(),
            kGap10,
            DoctorCard(
              name: 'Dr. John Doe',
              specialty: 'Cardiologist',
              availability: 'Available Today',
              timeSlots: const [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
              onCardTap: () {
                AppGlobal.navigatorKey.currentState
                    ?.push<void>(SetupAppointmentScreen.route());
              },
            ),
            kGap10,
            const DoctorCard(
              name: 'Dr. Jane Clarisa',
              specialty: 'Dermatologist',
              availability: 'Available Tomorrow',
              timeSlots: [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
            ),
            kGap10,
            const DoctorCard(
              name: 'Dr. Sam Wilson',
              specialty: 'General Practice',
              availability: 'Available Today',
              timeSlots: [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
            ),
            kGap10,
            const DoctorCard(
              name: 'Dr. Sarah Jane',
              specialty: 'Pediatrician',
              availability: 'Available Tomorrow',
              timeSlots: [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
            ),
            kGap10,
            const DoctorCard(
              name: 'Dr. John Doe',
              specialty: 'Cardiologist',
              availability: 'Available Today',
              timeSlots: [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
            ),
            kGap10,
            const DoctorCard(
              name: 'Dr. John Doe',
              specialty: 'Cardiologist',
              availability: 'Available Today',
              timeSlots: [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
            ),
            kGap10,
            const DoctorCard(
              name: 'Dr. John Doe',
              specialty: 'Cardiologist',
              availability: 'Available Today',
              timeSlots: [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
            ),
            kGap10,
            const DoctorCard(
              name: 'Dr. John Doe',
              specialty: 'Cardiologist',
              availability: 'Available Today',
              timeSlots: [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
            ),
            kGap10,
            const DoctorCard(
              name: 'Dr. John Doe',
              specialty: 'Cardiologist',
              availability: 'Available Today',
              timeSlots: [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '12:00 PM',
                '1:00 PM'
              ],
            ),
          ],
        ),
      ),
    );
  }
}
