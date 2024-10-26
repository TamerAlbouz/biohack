import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:models/models.dart';

import '../../../app/bloc/auth/auth_bloc.dart';
import '../../../common/widgets/appointment_card.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../bloc/appointment/appointment_bloc.dart';
import '../bloc/patient/patient_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const DashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PatientBloc(
            patientRepo: getIt<IPatientRepository>(),
            authRepo: getIt<IAuthenticationRepository>(),
          )..add(LoadPatient()),
        ),
        BlocProvider(
          create: (_) => AppointmentBloc(
            appointmentRepo: getIt<IAppointmentRepository>(),
          ),
        ),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, patientState) {
          switch (patientState) {
            case PatientInitial():
            case PatientLoading():
              return const Center(child: CircularProgressIndicator());
            case PatientLoaded():
              // Load appointment data when patient data is loaded
              context.read<AppointmentBloc>().add(LoadAppointment(
                  patientState.patient.appointments!.isNotEmpty
                      ? patientState.patient.appointments![0]
                      : "123"));
              return AppointmentBuilder(
                  appointmentId: patientState.patient.appointments![0]);
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
              AppointmentCard(
                cardAppointmentInfo: CardAppointmentInfo(
                  specialty: appointment.specialtyId == "1"
                      ? "Cardiology"
                      : "Dentistry",
                  doctor: "Dr. John Doe",
                  date: DateFormat('yyyy-MM-dd')
                      .format(appointment.appointmentDate),
                  time: DateFormat('HH:mm').format(appointment.appointmentDate),
                  location: appointment.location ?? "Online Consultation",
                ),
                cardAppointmentMetadata: CardAppointmentMetadata(
                  doctor: "Dr. John Doe",
                  fee: appointment.fee.toString(),
                  service: appointment.serviceName,
                ),
              ),
              kGap6,
              // _WelcomeMessage(patientName: patient.name),
              const _UserId(),
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
              color: MyColors.textButtonGrey,
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
        context.read<AuthBloc>().add(AuthLogoutPressed());
        // navigate to the auth screen
      },
    );
  }
}

class _UserId extends StatelessWidget {
  const _UserId();

  @override
  Widget build(BuildContext context) {
    return Text('UserID: 1', style: Theme.of(context).textTheme.labelSmall);
  }
}
