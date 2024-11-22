import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/agora/screens/call.dart';
import 'package:medtalk/common/globals/globals.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../common/widgets/cards/appointment_card.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../bloc/appointment/appointment_bloc.dart';
import '../bloc/patient/patient_bloc.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const PatientDashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const DashboardView();
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, patientState) {
          switch (patientState) {
            case PatientInitial():
            case PatientLoading():
              return const Center(child: CircularProgressIndicator());
            case PatientLoaded():
              // Load appointment data when patient data is loaded
              if (patientState.patient.appointments?.isEmpty ?? false) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: kPadd15,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const _AppointmentSection(),
                        kGap6,
                        AppointmentWidget(
                          specialty: 'Ophthalmology',
                          doctor: 'Dr. John Doe',
                          date: 'Sep 20, 2023',
                          time: '10:00 AM',
                          location: 'Room 402',
                          service: 'Eye Checkup',
                          fee: '100',
                          onJoinCall: () =>
                              AppGlobal.navigatorKey.currentState!.push(
                            VideoCallScreen.route(),
                          ),
                        ),
                        kGap6,
                        const _LogoutButton(),
                      ],
                    ),
                  ),
                );
              }
              context.read<AppointmentBloc>().add(
                  LoadAppointment(patientState.patient.appointments!.first));
              return AppointmentBuilder(
                  appointmentId: patientState.patient.appointments!.first);
            case PatientError():
              return _DashboardError(message: patientState.message);
            default:
              return const Center(child: Text('Unexpected state'));
          }
        },
      ),
    );
  }
}

class AppointmentBuilder extends StatelessWidget {
  const AppointmentBuilder({
    super.key,
    required this.appointmentId,
  });

  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, appointmentState) {
        switch (appointmentState) {
          case AppointmentInitial():
          case AppointmentLoading():
            return const Center(child: CircularProgressIndicator());
          case AppointmentLoaded():
            return _AppointmentContent(
                appointment: appointmentState.appointment);
          case AppointmentError():
            return _DashboardError(message: appointmentState.message);
          default:
            return const Center(child: Text('Unexpected state'));
        }
      },
    );
  }
}

class _AppointmentContent extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentContent({
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: kPaddH20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const _AppointmentSection(),
              kGap6,
              AppointmentWidget(
                date: DateFormat('yyyy-MM-dd')
                    .format(appointment.appointmentDate),
                time: DateFormat('HH:mm').format(appointment.appointmentDate),
                location: appointment.location ?? "Online Consultation",
                specialty:
                    appointment.specialtyId == "1" ? "Cardiology" : "Dentistry",
                doctor: "Dr. John Doe",
                service: appointment.serviceName,
                fee: appointment.fee.toString(),
                onJoinCall: () {
                  AppGlobal.navigatorKey.currentState!.push(
                    VideoCallScreen.route(),
                  );
                },
              ),
              kGap6,
              // _WelcomeMessage(patientName: patient.name),
              const _LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;

  const _DashboardError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red),
          ),
          kGap6,
          ElevatedButton(
            onPressed: () {
              context.read<PatientBloc>().add(LoadPatient());
            },
            child: const Text('Retry'),
          ),
          kGap6,
          const _LogoutButton(),
        ],
      ),
    );
  }
}

class _AppointmentSection extends StatelessWidget {
  const _AppointmentSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Appointments",
            style: TextStyle(
                fontSize: Font.sectionTitleSize, fontWeight: FontWeight.bold)),
        const Spacer(),
        TextButton(
          onPressed: () {
            // Navigator.of(context).push(AppointmentScreen.route());
          },
          child: const Text(
            'View All',
            style: TextStyle(
              color: MyColors.textGrey,
              fontSize: Font.mediumSmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Logout'),
      onPressed: () {
        context.read<RouteBloc>().add(AuthLogoutPressed());
        // navigate to the auth screen
      },
    );
  }
}
