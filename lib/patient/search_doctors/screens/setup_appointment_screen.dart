import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/patient/search_doctors/bloc/setup_appointment_bloc.dart';
import 'package:medtalk/patient/search_doctors/widgets/date_navigator.dart';
import 'package:medtalk/patient/search_doctors/widgets/summary_entry.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../common/widgets/dividers/card_divider.dart';
import '../../../common/widgets/dummy/profile_picture.dart';
import '../../../common/widgets/rounded_radio_button.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/styles/button.dart';
import '../../../styles/styles/text.dart';
import '../models/selection_item.dart';
import '../widgets/selection_group.dart';
import '../widgets/services_widget.dart';

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
            padding: kPaddT15,
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

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
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
                                  kGap20,
                                  _BookAppointmentButton(),
                                ],
                              )
                            : const Column(
                                key: ValueKey('OldWidgets'),
                                // Key to differentiate widget sets
                                children: [
                                  Services(),
                                  CardDivider(),
                                  _ClinicLocation(),
                                  CardDivider(),
                                  _ClinicDetails(),
                                  CardDivider(),
                                  _PatientReviewsScreen(),
                                ],
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
        SelectionGroup(
          items: [
            SelectionItem(
              title: 'In-Person',
              subtitle: '1234 Clinic St, Portland, OR 97205',
            ),
            SelectionItem(
              title: 'Online',
              subtitle: 'Video Call',
            ),
          ],
          onSelected: (item) {},
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
        SelectionGroup(
          items: [
            SelectionItem(
              title: 'Treatment',
              subtitle: '1 hr',
              price: 100,
            ),
            SelectionItem(
              title: 'Consultation',
              subtitle: '30 mins',
              price: 50,
            ),
            SelectionItem(
              title: 'Checkup',
              subtitle: '15 mins',
              price: 30,
            ),
          ],
          onSelected: (item) {},
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
        SelectionGroup(
          items: [
            SelectionItem(
              title: 'Cash',
              subtitle: 'Pay at the clinic',
            ),
            SelectionItem(
              title: 'Credit Card',
              subtitle: 'Pay online',
            ),
          ],
          onSelected: (item) {},
        ),
        // add card button
        kGap10,
        ElevatedButton(
          onPressed: () {},
          style: kElevatedButtonAddCardStyle,
          child: const Text(
            'Add Card',
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  final double padding = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: kAppointmentSetupSectionTitle,
        ),
        kGap14,
        // note warning rich text
        RichText(
          text: const TextSpan(
            style: kServiceCardText,
            children: [
              TextSpan(
                text: 'Note: ',
                style: TextStyle(
                  fontFamily: Font.family,
                  color: MyColors.cancel,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'You will ',
                style: kServiceCardText,
              ),
              TextSpan(
                text: 'NOT',
                style: TextStyle(
                  fontFamily: Font.family,
                  color: MyColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    ' be charged until the consultation was completed. If the meeting was canceled or not conducted, no charge will be made.',
                style: kServiceCardText,
              ),
            ],
          ),
        ),
        kGap10,
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: false,
                onChanged: (value) {},
              ),
            ),
            kGap8,
            const Text(
              'I agree to the ',
              style: kServiceCardText,
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: kPadd0,
              ),
              onPressed: () {},
              child: const Text(
                'Terms and Conditions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MyColors.blue,
                  fontSize: Font.small,
                ),
              ),
            ),
          ],
        ),
        kGap10,
        const SummaryEntry(
          icon: FaIcon(FontAwesomeIcons.calendarDays,
              size: 20, color: MyColors.blue),
          title: 'Date',
          value: '12/12/2021 • 11:00 AM',
        ),
        CardDivider(
          height: 24,
          padding: padding,
        ),
        const SummaryEntry(
          icon: FaIcon(FontAwesomeIcons.handshakeSimple,
              size: 18, color: MyColors.blue),
          title: 'Appointment',
          value: 'Consultation',
        ),
        kGap10,
        const SummaryEntry(
          icon: FaIcon(FontAwesomeIcons.clock, size: 20, color: MyColors.blue),
          title: 'Time',
          value: '1 hr',
        ),
        CardDivider(
          height: 24,
          padding: padding,
        ),
        const SummaryEntry(
          icon: FaIcon(FontAwesomeIcons.mapLocationDot,
              size: 20, color: MyColors.blue),
          title: 'Location',
          value: '1234 Clinic St, Portland, OR 97205',
        ),
        CardDivider(
          height: 24,
          padding: padding,
        ),
        const SummaryEntry(
          icon: FaIcon(FontAwesomeIcons.moneyBill,
              size: 20, color: MyColors.blue),
          title: 'Payment',
          value: 'Cash',
        ),
        kGap10,
        const SummaryEntry(
          icon: FaIcon(FontAwesomeIcons.creditCard,
              size: 20, color: MyColors.blue),
          title: 'Total',
          value: '\$100',
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
      style: kElevatedButtonBookAppointmentStyle,
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
  const _PatientReviewsScreen();

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
          height: 300,
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
  bool _loading = true;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _loading = false;
    });
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
        Skeletonizer(
          enabled: _loading,
          child: Skeleton.leaf(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.grey, width: 1.5),
                borderRadius: kRadius10,
                color: Colors.grey[300],
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
          ),
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
              unselectedColor = selected ? MyColors.grey : MyColors.blue;
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
