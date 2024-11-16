import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/patient/search_doctors/bloc/setup_appointment_bloc.dart';
import 'package:medtalk/patient/search_doctors/widgets/date_navigator.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../common/widgets/dividers/card_divider.dart';
import '../../../common/widgets/dummy/profile_picture.dart';
import '../../../common/widgets/rounded_radio_button.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/styles/text.dart';

class SetupAppointmentScreen extends StatefulWidget {
  const SetupAppointmentScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const SetupAppointmentScreen());
  }

  @override
  State<SetupAppointmentScreen> createState() => _SetupAppointmentScreenState();
}

class _SetupAppointmentScreenState extends State<SetupAppointmentScreen> {
  bool reBuild = false;
  Color unselectedColor = MyColors.blue;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SetupAppointmentBloc(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          title: const Text('Set-Up Appointment', style: kAppBarText),
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: kPaddH20V15,
            child: CustomBase(
              child: Column(
                children: [
                  const _DoctorProfile(),
                  const CardDivider(),
                  const _ChooseAppointmentDate(),
                  const CardDivider(),
                  // add a custom animation that on clicking a radio button, everything below it expands
                  BlocBuilder<SetupAppointmentBloc, SetupAppointmentState>(
                    builder: (context, state) {
                      // Determine the current state to rebuild or switch widgets
                      final bool showNewWidgets =
                          state is AppointmentRebuild && state.reBuild;

                      return AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        // Size change duration
                        curve: Curves.easeInOut,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          // Switch animation duration
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          child: showNewWidgets
                              ? const Column(
                                  key: ValueKey('NewWidgets'),
                                  // Key to differentiate widget sets
                                  children: [
                                    _ChooseServiceType(),
                                    CardDivider(),
                                    _ChooseAppointmentType(),
                                    CardDivider(),
                                    _ChoosePaymentType(),
                                    CardDivider(),
                                    _Summary(),
                                    _BookAppointmentButton(),
                                  ],
                                )
                              : const Column(
                                  key: ValueKey('OldWidgets'),
                                  // Key to differentiate widget sets
                                  children: [
                                    _Services(),
                                    CardDivider(),
                                    _ClinicLocation(),
                                    CardDivider(),
                                    _ClinicDetails(),
                                    CardDivider(),
                                    _PatientReviewsScreen(),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChooseAppointmentType extends StatelessWidget {
  const _ChooseAppointmentType();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Type',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        RadioButtonGroup(
          options: const ['In-Person', 'Online'],
          decoration: BoxDecoration(
            color: MyColors.blue,
            borderRadius: kRadiusAll,
          ),
          contentPadding: kPaddH10V2,
          selectedColor: MyColors.blue,
          unselectedColor: MyColors.grey,
          unselectedTextColor: Colors.white,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: Font.extraSmall,
          ),
          onSelected: (value) {
            context.read<SetupAppointmentBloc>().add(ToggleRebuild());
          },
          onChanged: (String) {},
        ),
      ],
    );
  }
}

class _ChooseServiceType extends StatelessWidget {
  const _ChooseServiceType();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Type',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        RadioButtonGroup(
          options: const ['Consultation', 'Treatment', 'Checkup'],
          decoration: BoxDecoration(
            color: MyColors.blue,
            borderRadius: kRadiusAll,
          ),
          contentPadding: kPaddH10V2,
          selectedColor: MyColors.blue,
          unselectedColor: MyColors.grey,
          unselectedTextColor: Colors.white,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: Font.extraSmall,
          ),
          onSelected: (value) {
            context.read<SetupAppointmentBloc>().add(ToggleRebuild());
          },
          onChanged: (String) {},
        ),
      ],
    );
  }
}

class _ChoosePaymentType extends StatelessWidget {
  const _ChoosePaymentType();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Type',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        RadioButtonGroup(
          options: const ['Cash', 'Credit Card', 'Insurance'],
          decoration: BoxDecoration(
            color: MyColors.blue,
            borderRadius: kRadiusAll,
          ),
          contentPadding: kPaddH10V2,
          selectedColor: MyColors.blue,
          unselectedColor: MyColors.grey,
          unselectedTextColor: Colors.white,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: Font.extraSmall,
          ),
          onSelected: (value) {
            context.read<SetupAppointmentBloc>().add(ToggleRebuild());
          },
          onChanged: (String) {},
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.calendarDays,
              color: MyColors.blue,
              size: 20,
            ),
            kGap10,
            Text(
              'Date: 12/12/2021',
              style: kServiceCardText,
            ),
          ],
        ),
        kGap10,
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.clock,
              color: MyColors.blue,
              size: 20,
            ),
            kGap10,
            Text(
              'Time: 11:00 AM',
              style: kServiceCardText,
            ),
          ],
        ),
        kGap10,
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.dollarSign,
              color: MyColors.blue,
              size: 20,
            ),
            kGap10,
            Text(
              'Total: \$100',
              style: kServiceCardText,
            ),
          ],
        ),
      ],
    );
  }
}

class _BookAppointmentButton extends StatelessWidget {
  const _BookAppointmentButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: kRadiusAll),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        'Book Appointment',
        style: TextStyle(
          color: Colors.white,
          fontSize: Font.medium,
        ),
      ),
    );
  }
}

class _PatientReviewsScreen extends StatelessWidget {
  const _PatientReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Patient Reviews',
              style: kAppointmentSetupSectionTitle,
            ),
            TextButton(
              onPressed: null,
              child: Text(
                '256',
                style: kButtonHint,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 400,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 8,
            separatorBuilder: (context, index) => kGap14,
            itemBuilder: (context, index) {
              return const _ReviewCard(
                author: 'John Doe',
                review:
                    'Dr. Marissa is a great dentist. She is very professional and friendly. I highly recommend her.',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String author;
  final String review;

  const _ReviewCard({
    required this.author,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ProfilePicture(
              width: 30,
              height: 30,
            ),
            kGap10,
            Text(
              author,
              style: kServiceCardText.copyWith(
                color: MyColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // flag
            const FaIcon(
              FontAwesomeIcons.flag,
              color: MyColors.buttonRed,
              size: 20,
            ),
          ],
        ),
        kGap10,
        Text(
          review,
          style: kServiceCardText,
        ),
      ],
    );
  }
}

class _ClinicDetails extends StatelessWidget {
  const _ClinicDetails();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinic Details',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        Row(
          children: [
            SizedBox(
              width: 20,
              child: FaIcon(
                FontAwesomeIcons.phone,
                color: MyColors.blue,
                size: 18,
              ),
            ),
            kGap10,
            Text(
              '+1 123 456 7890',
              style: kServiceCardText,
            ),
          ],
        ),
        kGap10,
        Row(
          children: [
            SizedBox(
              width: 20,
              child: FaIcon(
                FontAwesomeIcons.mapLocation,
                color: MyColors.blue,
                size: 18,
              ),
            ),
            kGap10,
            Text(
              '1234 Clinic St, Portland, OR 97205',
              style: kServiceCardText,
            ),
          ],
        ),
        kGap10,
        // extra notes
        Row(
          children: [
            SizedBox(
              width: 20,
              child: FaIcon(
                FontAwesomeIcons.circleInfo,
                color: MyColors.blue,
                size: 18,
              ),
            ),
            kGap10,
            Text(
              'Ask for Marwan Azzam',
              style: kServiceCardText,
            ),
          ],
        ),
      ],
    );
  }
}

class _ClinicLocation extends StatefulWidget {
  const _ClinicLocation();

  @override
  State<_ClinicLocation> createState() => _ClinicLocationState();
}

class _ClinicLocationState extends State<_ClinicLocation> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MyColors.grey, width: 1.5),
            borderRadius: kRadius10,
          ),
          height: 150,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: kRadius10,
            child: GoogleMap(
              // disable dragging
              scrollGesturesEnabled: false,
              // initial location
              markers: {
                Marker(
                  markerId: const MarkerId('clinic'),
                  position: _center,
                  infoWindow: const InfoWindow(
                    title: 'Clinic',
                    snippet: '1234 Clinic St, Portland, OR 97205',
                  ),
                ),
              },
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Services extends StatelessWidget {
  const _Services();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        ListView.separated(
          shrinkWrap: true,
          itemCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => kGap8,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // change color of check icon
              },
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.check,
                    color: MyColors.green,
                    size: 20,
                  ),
                  kGap10,
                  Text('Service $index', style: kServiceCardText),
                  const Spacer(),
                  Text(
                    '\$100',
                    style: kServiceCardText.copyWith(color: MyColors.textBlack),
                  ),
                  kGap10,
                  const FaIcon(
                    FontAwesomeIcons.chevronRight,
                    color: MyColors.black,
                    size: 18,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ChooseAppointmentDate extends StatefulWidget {
  const _ChooseAppointmentDate();

  @override
  State<_ChooseAppointmentDate> createState() => _ChooseAppointmentDateState();
}

class _ChooseAppointmentDateState extends State<_ChooseAppointmentDate> {
  Color unselectedColor = MyColors.blue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Book an Appointment',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap24,
        DateNavigationWidget(
          onDateChanged: (date) {},
        ),
        kGap24,
        RadioButtonGroup(
          options: const [
            '11:00 AM',
            '12:00 PM',
            '01:00 PM',
            '02:00 PM',
            '03:00 PM',
            '04:00 PM',
            '05:00 PM'
          ],
          decoration: BoxDecoration(
            color: MyColors.blue,
            borderRadius: kRadiusAll,
          ),
          contentPadding: kPaddH10V2,
          selectedColor: MyColors.blue,
          unselectedColor: unselectedColor,
          unselectedTextColor: Colors.white,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: Font.extraSmall,
          ),
          onSelected: (selected) {
            setState(() {
              unselectedColor = selected ? MyColors.blue : MyColors.grey;
            });
            // if already selected, do not rebuild
            context.read<SetupAppointmentBloc>().add(ToggleRebuild());
          },
          onChanged: (value) {
            setState(() {
              unselectedColor = MyColors.grey;
            });
            print(value);
          },
        ),
      ],
    );
  }
}

class _DoctorProfile extends StatelessWidget {
  const _DoctorProfile();

  @override
  Widget build(BuildContext context) {
    return const Row(
      // space between
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ProfilePicture(width: 50, height: 50),
        kGap20,
        _DoctorInfo(
          name: "Dr. Marissa Doe",
          specialty: "Dentist",
        ),
        Spacer(),
        // faicon right arrow
        FaIcon(
          FontAwesomeIcons.upRightFromSquare,
          color: Colors.black,
          size: 20,
        ),
      ],
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  final String name;
  final String specialty;

  const _DoctorInfo({
    required this.name,
    required this.specialty,
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
      ],
    );
  }
}
