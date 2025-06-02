import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/agora/screens/call.dart';
import 'package:medtalk/backend/appointment/enums/appointment_status.dart';
import 'package:medtalk/backend/doctor/models/doctor.dart';
import 'package:medtalk/backend/medical_doc/models/medical_doc.dart';
import 'package:medtalk/backend/patient/models/patient.dart';
import 'package:medtalk/common/globals/globals.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../backend/medical_doc/enums/medical_doc_type.dart';
import '../../../common/widgets/cards/appointment_patient_card.dart';
import '../../../styles/colors.dart';
import '../../../styles/sizes.dart';
import '../bloc/appointment/appointment_bloc.dart';
import '../bloc/doctor/doctor_bloc.dart';
import '../bloc/document/document_bloc.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PatientBloc>().add(LoadPatient());
          // Refresh other data as needed
        },
        child: Padding(
          padding: kPaddH20,
          child: BlocBuilder<PatientBloc, PatientState>(
            builder: (context, patientState) {
              switch (patientState) {
                case PatientInitial() || PatientLoading():
                  return Skeletonizer(
                    enabled: true,
                    enableSwitchAnimation: true,
                    switchAnimationConfig: const SwitchAnimationConfig(
                      duration: Duration(milliseconds: 500),
                    ),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Skeleton welcome section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      height: 16,
                                      width: 120,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.1)),
                                  Container(
                                      height: 24,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: theme.primaryColor),
                                        borderRadius: kRadius10,
                                      )),
                                ],
                              ),
                              kGap4,
                              Container(
                                  height: 24,
                                  width: 180,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.1)),
                              kGap4,
                              Container(
                                  height: 14,
                                  width: 150,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.1)),
                              kGap20,

                              // Skeleton upcoming appointment
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          height: 20,
                                          width: 180,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.1)),
                                      Container(
                                          height: 16,
                                          width: 50,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.1)),
                                    ],
                                  ),
                                  kGap10,
                                  AppointmentWidgetPatient(
                                    specialty: 'sdfsdf',
                                    name: "Dr. John Doe",
                                    appointmentDate: DateTime.now(),
                                    location: 'dsfdfsdfsdf',
                                    serviceName: 'sdfsdfsdf',
                                    fee: 0,
                                    status: AppointmentStatus.scheduled,
                                    isReady: true,
                                    onJoinCall: null,
                                  ),
                                  kGap20,

                                  // Skeleton doctors section
                                  Container(
                                      height: 20,
                                      width: 120,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.1)),
                                  kGap10,
                                  CustomBase(
                                    shadow: false,
                                    fixedHeight: 130,
                                    child: Center(
                                      child: Text(
                                        'Loading doctors...',
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5)),
                                      ),
                                    ),
                                  ),
                                  kGap20,

                                  // Skeleton documents section
                                  Container(
                                      height: 20,
                                      width: 160,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.1)),
                                  kGap10,
                                  CustomBase(
                                    shadow: false,
                                    fixedHeight: 130,
                                    child: Center(
                                      child: Text(
                                        'Loading docs...',
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5)),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                case PatientLoaded():
                  return _buildDashboardContent(context, patientState.patient);
                case PatientError():
                  return _DashboardError(message: patientState.message);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, Patient patient) {
    // Load necessary data for the dashboard
    context
        .read<PatientAppointmentBloc>()
        .add(LoadPatientAppointment(patient.uid));

    // Load patient documents
    context.read<PatientDocumentBloc>().add(LoadPatientDocuments(patient.uid));

    // Load patient doctors
    context.read<PatientDoctorBloc>().add(LoadPatientDoctors(patient.uid));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _WelcomeSection(patientName: patient.name ?? 'Patient'),
          kGap20,

          // Upcoming appointment section
          const _UpcomingAppointmentSection(),
          kGap20,

          // My Doctors Section
          const _MyDoctorsSection(),
          kGap20,

          // Recent Documents Section
          const _RecentDocumentsSection(),
          kGap20,
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final String patientName;

  const _WelcomeSection({required this.patientName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.brightness == Brightness.light
                        ? MyColors.subtitleDark
                        : MyColors.textGrey,
                  ),
                ),
                Text(
                  patientName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const _LogoutButton(),
          ],
        ),
        Text(
          DateFormat('EEEE, MMM dd, yyyy').format(now),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.brightness == Brightness.light
                ? MyColors.subtitleDark
                : MyColors.textGrey,
          ),
        ),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }
}

class _UpcomingAppointmentSection extends StatelessWidget {
  const _UpcomingAppointmentSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PatientAppointmentBloc, PatientAppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upcoming Appointments",
                    style: theme.textTheme.titleSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to appointments list
                    },
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              AppointmentWidgetPatient(
                  specialty: state.appointment.specialty,
                  name: "Dr. John Doe",
                  appointmentDate: state.appointment.appointmentDate,
                  location: state.appointment.location ?? "Online Consultation",
                  serviceName: state.appointment.serviceName,
                  fee: state.appointment.fee,
                  isReady:
                      _isAppointmentReady(state.appointment.appointmentDate),
                  onJoinCall: () => {
                        _isAppointmentReady(state.appointment.appointmentDate)
                            ? () => AppGlobal.navigatorKey.currentState!.push(
                                  VideoCallScreen.route(),
                                )
                            : null,
                      }),
            ],
          );
        }

        // Show loading or placeholder
        return Skeletonizer(
          enabled: true,
          child: AppointmentWidgetPatient(
            specialty: 'sdfsdf',
            name: "Dr. John Doe",
            appointmentDate: DateTime.now(),
            location: 'dsfdfsdfsdf',
            serviceName: 'sdfsdfsdf',
            fee: 0,
            status: AppointmentStatus.scheduled,
            isReady: true,
            onJoinCall: null,
          ),
        );
      },
    );
  }

  bool _isAppointmentReady(DateTime appointmentTime) {
    final now = DateTime.now();
    // Allow joining 10 minutes before appointment
    return now.isAfter(appointmentTime.subtract(const Duration(minutes: 10))) &&
        now.isBefore(appointmentTime.add(const Duration(minutes: 30)));
  }
}

class _MyDoctorsSection extends StatelessWidget {
  const _MyDoctorsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PatientDoctorBloc, PatientDoctorState>(
      builder: (context, state) {
        if (state is PatientDocumentsLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Doctors',
                    style: theme.textTheme.titleSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to doctors list
                    },
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              kGap4,
              Skeletonizer(
                enabled: true,
                enableSwitchAnimation: true,
                switchAnimationConfig: const SwitchAnimationConfig(
                  duration: Duration(milliseconds: 500),
                ),
                child: CustomBase(
                  shadow: false,
                  fixedHeight: 130,
                  child: Center(
                    child: Text(
                      'Loading doctors...',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              )
            ],
          );
        }

        List<Doctor> doctors = [];
        if (state is PatientDoctorsLoaded) {
          doctors = state.doctors;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Doctors',
                  style: theme.textTheme.titleSmall,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to doctors list
                  },
                  child: Text(
                    'View All',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            kGap4,
            SizedBox(
              height: 130,
              child: doctors.isEmpty
                  ? _emptyDoctorsWidget(context)
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        return _DoctorCard(doctor: doctors[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyDoctorsWidget(BuildContext context) {
    final theme = Theme.of(context);

    return CustomBase(
      shadow: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.userDoctor,
              size: 30,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            kGap10,
            Text(
              'No doctors yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      child: CustomBase(
        shadow: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(alpha: 0.1),
              ),
              child: doctor.profilePictureUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        doctor.profilePictureUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: FaIcon(
                            FontAwesomeIcons.userDoctor,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: FaIcon(
                        FontAwesomeIcons.userDoctor,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
            ),
            kGap6,
            Text(
              'Dr. ${doctor.name ?? "Unknown"}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            kGap4,
            Text(
              doctor.specialties?.isNotEmpty ?? false
                  ? doctor.specialties!.first
                  : 'General',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentDocumentsSection extends StatelessWidget {
  const _RecentDocumentsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PatientDocumentBloc, PatientDocumentState>(
      builder: (context, state) {
        if (state is PatientDocumentsLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Documents',
                    style: theme.textTheme.titleSmall,
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              kGap4,
              Skeletonizer(
                enabled: true,
                enableSwitchAnimation: true,
                switchAnimationConfig: const SwitchAnimationConfig(
                  duration: Duration(milliseconds: 500),
                ),
                child: CustomBase(
                  shadow: false,
                  fixedHeight: 130,
                  child: Center(
                    child: Text(
                      'Loading docs...',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        List<MedicalDocument> documents = [];
        if (state is PatientDocumentsLoaded) {
          documents = state.documents;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Documents',
                  style: theme.textTheme.titleSmall,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to documents list
                  },
                  child: Text(
                    'View All',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            kGap4,
            documents.isEmpty
                ? _emptyDocumentsWidget(context)
                : Column(
                    children: documents
                        .take(3)
                        .map((doc) => _DocumentItem(document: doc))
                        .toList(),
                  ),
          ],
        );
      },
    );
  }

  Widget _emptyDocumentsWidget(BuildContext context) {
    final theme = Theme.of(context);

    return CustomBase(
      shadow: false,
      fixedHeight: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.fileLines,
              size: 30,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            kGap10,
            Text(
              'No documents yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final MedicalDocument document;

  const _DocumentItem({required this.document});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData typeIcon;
    Color typeColor;

    // Determine icon and color based on document type
    switch (document.type) {
      case MedicalDocumentType.prescription:
        typeIcon = FontAwesomeIcons.prescriptionBottleMedical;
        typeColor = Colors.green;
        break;
      case MedicalDocumentType.labReport:
        typeIcon = FontAwesomeIcons.flaskVial;
        typeColor = Colors.blue;
        break;
      case MedicalDocumentType.imaging:
        typeIcon = FontAwesomeIcons.xRay;
        typeColor = Colors.purple;
        break;
      default:
        typeIcon = FontAwesomeIcons.fileLines;
        typeColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    }

    return InkWell(
      onTap: () {
        // View document
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: kPadd10,
        decoration: BoxDecoration(
          border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: FaIcon(
                  typeIcon,
                  color: typeColor,
                  size: 18,
                ),
              ),
            ),
            kGap10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title ?? 'Unnamed Document',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (document.createdAt != null)
                    Text(
                      DateFormat('MMM dd, yyyy').format(document.createdAt!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.download,
                size: 16,
                color: theme.primaryColor,
              ),
              onPressed: () {
                // Download document
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius10,
        ),
        side: BorderSide(color: theme.primaryColor),
        padding: kPaddH10V0,
      ),
      onPressed: () {
        context.read<RouteBloc>().add(AuthLogoutPressed());
      },
      child: Text(
        'Logout',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.primaryColor,
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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.circleExclamation,
            size: 48,
            color: Colors.red[300],
          ),
          kGap20,
          Text(
            'Error: $message',
            style: TextStyle(color: Colors.red),
          ),
          kGap20,
          ElevatedButton(
            onPressed: () {
              context.read<PatientBloc>().add(LoadPatient());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Required Bloc files
