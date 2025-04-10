import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/cards/appointment_doctor_card.dart';
import 'package:medtalk/common/widgets/dividers/section_divider.dart';
import 'package:medtalk/doctor/patients/screens/chat_screen.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../../common/widgets/custom_tab.dart';
import '../bloc/patient_details_bloc.dart';
import '../models/patients_models.dart';
import 'add_patient_note_screen.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
  });

  static Route<void> route(String patientId) {
    return MaterialPageRoute<void>(
      builder: (_) => PatientDetailsScreen(patientId: patientId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientDetailsBloc(
        patientId: patientId,
        patientRepository: getIt<IPatientRepository>(),
        appointmentRepository: getIt<IAppointmentRepository>(),
        // Add other repositories as needed
      )..add(LoadPatientDetails()),
      child: const PatientDetailsView(),
    );
  }
}

class PatientDetailsView extends StatefulWidget {
  const PatientDetailsView({super.key});

  @override
  State<PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<PatientDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PatientDetailsBloc, PatientDetailsState>(
        listener: (context, state) {
          if (state is PatientDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PatientDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatientDetailsLoaded) {
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: MyColors.primary,
                    foregroundColor: Colors.white,
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        state.patient.name ?? 'Patient Details',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: Font.medium,
                        ),
                      ),
                      background: Container(
                        color: MyColors.primary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30), // Space for app bar
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Text(
                                _getInitials(state.patient.name ?? 'Unknown'),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: MyColors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: MyColors.primary,
                        isScrollable: true,
                        tabs: const [
                          CustomTab(
                              text: 'Info', icon: FontAwesomeIcons.circleInfo),
                          CustomTab(
                              text: 'Appointments', icon: Icons.calendar_today),
                          CustomTab(
                              text: 'Documents', icon: FontAwesomeIcons.file),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _PatientInfoTab(patient: state.patient),
                  _AppointmentsTab(
                    appointments: state.appointments,
                    patient: state.patient,
                  ),
                  _DocumentsTab(
                    documents: state.documents,
                    patient: state.patient,
                  ),
                ],
              ),
            );
          }

          // Error state or initial state
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[300],
                ),
                kGap20,
                const Text(
                  'Unable to load patient details',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: Font.medium,
                  ),
                ),
                kGap20,
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<PatientDetailsBloc>()
                        .add(LoadPatientDetails());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<PatientDetailsBloc, PatientDetailsState>(
        builder: (context, state) {
          if (state is PatientDetailsLoaded) {
            return BottomAppBar(
              color: MyColors.cardBackground,
              elevation: 8,
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Remove appointment scheduling button
                  _ActionButton(
                    icon: FontAwesomeIcons.notesMedical,
                    label: 'Add Note',
                    onTap: () {
                      // Add medical note
                      _showAddNoteDialog(context, state.patient);
                    },
                  ),
                  // Replace video call with View History
                  _ActionButton(
                    icon: FontAwesomeIcons.clockRotateLeft,
                    label: 'View History',
                    onTap: () {
                      // View patient history
                      _showPatientHistoryDialog(context, state.patient);
                    },
                  ),
                  _ActionButton(
                    icon: FontAwesomeIcons.solidMessage,
                    label: 'Message',
                    onTap: () {
                      // Message patient
                      _navigateToChat(context, state.patient);
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else {
      return name[0];
    }
  }

  // New methods to handle the actions
  void _showAddNoteDialog(BuildContext context, Patient patient) {
    // Navigate to the new Add Note screen instead of showing a dialog
    Navigator.of(context).push(AddPatientNoteScreen.route(patient));
  }

  void _showPatientHistoryDialog(BuildContext context, Patient patient) {
    // Navigate to patient history or show a dialog with history
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _PatientHistorySheet(
            patient: patient,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void _navigateToChat(BuildContext context, Patient patient) {
    // Navigate to chat screen
    Navigator.of(context).push(ChatScreen.route(patient));
  }
}

// Updated Appointments Tab to remove scheduling options
class _AppointmentsTab extends StatelessWidget {
  final List<Appointment> appointments;
  final Patient patient;

  const _AppointmentsTab({
    required this.appointments,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    // Group appointments by status
    final upcomingAppointments = <Appointment>[];
    final pastAppointments = <Appointment>[];
    final canceledAppointments = <Appointment>[];

    final now = DateTime.now();

    for (final appointment in appointments) {
      if (appointment.status == AppointmentStatus.cancelled) {
        canceledAppointments.add(appointment);
      } else if (appointment.appointmentDate.isAfter(now)) {
        upcomingAppointments.add(appointment);
      } else {
        pastAppointments.add(appointment);
      }
    }

    // Sort appointments by date
    upcomingAppointments
        .sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    pastAppointments.sort((a, b) =>
        b.appointmentDate.compareTo(a.appointmentDate)); // Most recent first
    canceledAppointments
        .sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

    return SingleChildScrollView(
      padding: kPadd16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming appointments section - removed scheduling button
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Appointments',
                style: kSectionTitle,
              ),
            ],
          ),
          kGap12,

          if (upcomingAppointments.isEmpty)
            const CustomBase(
              shadow: false,
              child: Padding(
                padding: kPadd16,
                child: Center(
                  child: Text(
                    'No upcoming appointments',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.subtitleDark,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: kPadd0,
              itemCount: upcomingAppointments.length,
              separatorBuilder: (context, index) => kGap8,
              itemBuilder: (context, index) {
                return AppointmentWidgetDoctor(
                  appointmentDate: upcomingAppointments[index].appointmentDate,
                  status: upcomingAppointments[index].status,
                  serviceName: upcomingAppointments[index].serviceName,
                  location: upcomingAppointments[index].location ??
                      'Online Consultation',
                  fee: upcomingAppointments[index].fee,
                  name: patient.name ?? 'Unknown',
                  specialty: upcomingAppointments[index].specialty,
                  isPast: false,
                  isReady: false,
                  showButton: false,
                );
              },
            ),

          kGap20,

          // Past appointments section
          const Text(
            'Past Appointments',
            style: TextStyle(
              fontSize: Font.medium,
              fontWeight: FontWeight.bold,
            ),
          ),
          kGap12,

          if (pastAppointments.isEmpty)
            const CustomBase(
              shadow: false,
              child: Padding(
                padding: kPadd16,
                child: Center(
                  child: Text(
                    'No past appointments',
                    style: TextStyle(
                      fontSize: Font.small,
                      color: MyColors.subtitleDark,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: pastAppointments.length.clamp(0, 5),
              padding: kPadd0,
              separatorBuilder: (context, index) => kGap8,
              itemBuilder: (context, index) {
                return AppointmentWidgetDoctor(
                  isPast: true,
                  showButton: false,
                  status: pastAppointments[index].status,
                  specialty: pastAppointments[index].specialty,
                  name: patient.name ?? 'Unknown',
                  appointmentDate: pastAppointments[index].appointmentDate,
                  location:
                      pastAppointments[index].location ?? 'Online Consultation',
                  serviceName: pastAppointments[index].serviceName,
                  fee: pastAppointments[index].fee,
                  isReady: false,
                );
              },
            ),

          if (pastAppointments.length > 5) ...[
            kGap12,
            Center(
              child: TextButton(
                onPressed: () {
                  // Show all past appointments
                },
                child: const Text('View All Past Appointments'),
              ),
            ),
          ],

          kGap20,

          // Canceled appointments section
          if (canceledAppointments.isNotEmpty) ...[
            const Text(
              'Canceled Appointments',
              style: TextStyle(
                fontSize: Font.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
            kGap12,
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: kPadd0,
              itemCount: canceledAppointments.length.clamp(0, 3),
              separatorBuilder: (context, index) => kGap8,
              itemBuilder: (context, index) {
                return AppointmentWidgetDoctor(
                  appointmentDate: canceledAppointments[index].appointmentDate,
                  status: canceledAppointments[index].status,
                  serviceName: canceledAppointments[index].serviceName,
                  location: canceledAppointments[index].location ??
                      'Online Consultation',
                  fee: canceledAppointments[index].fee,
                  name: patient.name ?? 'Unknown',
                  specialty: canceledAppointments[index].specialty,
                  isPast: true,
                  showButton: false,
                  isReady: false,
                );
              },
            ),
            if (canceledAppointments.length > 3) ...[
              kGap12,
              Center(
                child: TextButton(
                  onPressed: () {
                    // Show all canceled appointments
                  },
                  child: const Text('View All Canceled Appointments'),
                ),
              ),
            ],
            kGap20,
          ],
        ],
      ),
    );
  }
}

// New Patient History Sheet widget
class _PatientHistorySheet extends StatelessWidget {
  final Patient patient;
  final ScrollController scrollController;

  const _PatientHistorySheet({
    required this.patient,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kPadd20,
      decoration: const BoxDecoration(
        color: MyColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          kGap20,
          const Text(
            'Patient History',
            style: TextStyle(
              fontSize: Font.mediumLarge,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          kGap10,
          Text(
            'Summary for ${patient.name}',
            style: TextStyle(
              fontSize: Font.mediumSmall,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          kGap20,

          // Visit History
          const Text(
            'Visit History',
            style: kSectionTitle,
          ),
          kGap10,
          CustomBase(
            shadow: false,
            child: Padding(
              padding: kPadd6,
              child: Column(
                children: [
                  _buildHistoryItem(
                    date: 'Mar 10, 2023',
                    title: 'Follow-up Consultation',
                    details:
                        'Discussed treatment progress and adjusted medication dosage.',
                  ),
                  kGap10,
                  const Divider(),
                  kGap10,
                  _buildHistoryItem(
                    date: 'Feb 15, 2023',
                    title: 'Medical Examination',
                    details:
                        'Conducted full physical examination and ordered blood tests.',
                  ),
                  kGap10,
                  const Divider(),
                  kGap10,
                  _buildHistoryItem(
                    date: 'Jan 15, 2023',
                    title: 'Initial Consultation',
                    details:
                        'Patient presented with symptoms of fatigue and headaches.',
                  ),
                ],
              ),
            ),
          ),
          kGap20,

          // Medical Notes
          const Text(
            'Medical Notes',
            style: kSectionTitle,
          ),
          kGap10,
          CustomBase(
            shadow: false,
            child: Padding(
              padding: kPadd6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNoteItem(
                    date: 'Mar 15, 2023',
                    content:
                        'Patient reports improved sleep patterns and reduced headache frequency.',
                  ),
                  kGap10,
                  const Divider(),
                  kGap10,
                  _buildNoteItem(
                    date: 'Feb 28, 2023',
                    content:
                        'Reviewed lab results. All values within normal range except slightly elevated cholesterol.',
                  ),
                  kGap10,
                  const Divider(),
                  kGap10,
                  _buildNoteItem(
                    date: 'Feb 20, 2023',
                    content:
                        'Patient called to report mild side effects from new medication. Advised to continue and monitor symptoms.',
                  ),
                ],
              ),
            ),
          ),
          kGap20,

          // Add Note button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(AddPatientNoteScreen.route(patient));
              },
              icon: const FaIcon(FontAwesomeIcons.notesMedical, size: 16),
              label: const Text('Add New Note',
                  style: TextStyle(
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                  )),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: MyColors.primary,
                side: const BorderSide(color: MyColors.primary),
                padding: kPaddV12,
              ),
            ),
          ),
          kGap20,
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String title,
    required String details,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: kPadd8,
          decoration: BoxDecoration(
            color: MyColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const FaIcon(
            FontAwesomeIcons.calendarCheck,
            size: 16,
            color: MyColors.primary,
          ),
        ),
        kGap10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: Font.small,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: Font.extraSmall,
                      color: MyColors.subtitleDark,
                    ),
                  ),
                ],
              ),
              kGap4,
              Text(
                details,
                style: const TextStyle(
                  fontSize: Font.small,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteItem({
    required String date,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.noteSticky,
              size: 14,
              color: MyColors.primary,
            ),
            kGap8,
            Text(
              date,
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        kGap8,
        Text(
          content,
          style: const TextStyle(
            fontSize: Font.small,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: MyColors.cardBackground,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 20,
            color: MyColors.primary,
          ),
          kGap4,
          Text(
            label,
            style: const TextStyle(
              fontSize: Font.extraSmall,
              color: MyColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Tabs
class _PatientInfoTab extends StatelessWidget {
  final Patient patient;

  const _PatientInfoTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: kPadd16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information', style: kSectionTitle),
          kGap12,
          CustomBase(
            shadow: false,
            child: Column(
              children: [
                _buildInfoRow(
                  'Name',
                  patient.name ?? 'Not provided',
                  FontAwesomeIcons.user,
                ),
                kGap12,
                _buildInfoRow(
                  'Sex',
                  patient.sex ?? 'Not provided',
                  FontAwesomeIcons.venusMars,
                ),
                kGap12,
                _buildInfoRow(
                  'Age',
                  patient.dateOfBirth != null
                      ? '${_calculateAge(patient.dateOfBirth!)} years'
                      : 'Not provided',
                  FontAwesomeIcons.solidHourglass,
                ),
              ],
            ),
          ),
          kGap20,

          const Text('Contact Information', style: kSectionTitle),
          kGap12,
          CustomBase(
            shadow: false,
            child: Column(
              children: [
                _buildInfoRow(
                  'Email',
                  patient.email,
                  FontAwesomeIcons.envelope,
                ),
              ],
            ),
          ),
          kGap20,

          const Text('Medical Information', style: kSectionTitle),
          kGap12,
          CustomBase(
            shadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biography & Notes',
                  style: TextStyle(
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                    color: MyColors.subtitleDark,
                  ),
                ),
                kGap8,
                Text(
                  patient.biography ??
                      'No patient biography or notes available.',
                  style: const TextStyle(
                    fontSize: Font.small,
                  ),
                ),
                // You could add more medical info like allergies, medications, etc.
              ],
            ),
          ),
          kGap20,

          const Text('Patient Statistics', style: kSectionTitle),
          kGap12,
          CustomBase(
            shadow: false,
            child: Column(
              children: [
                _buildStatRow(
                  'First Visit',
                  'Jan 15, 2023',
                  FontAwesomeIcons.calendarPlus,
                ),
                kGap12,
                _buildStatRow(
                  'Last Visit',
                  'Mar 10, 2023',
                  FontAwesomeIcons.calendarCheck,
                ),
                kGap12,
                _buildStatRow(
                  'Total Visits',
                  '8 appointments',
                  FontAwesomeIcons.solidCalendar,
                ),
                kGap12,
                _buildStatRow(
                  'Total Revenue',
                  '\$1,245.00',
                  FontAwesomeIcons.dollarSign,
                ),
              ],
            ),
          ),
          kGap20,

          // Add edit button at the bottom
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to edit patient screen
              },
              icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
              label: const Text('Edit Patient Information',
                  style: TextStyle(fontSize: Font.small)),
              style: OutlinedButton.styleFrom(
                padding: kPaddV12,
                side: const BorderSide(color: MyColors.primary),
                foregroundColor: MyColors.primary,
              ),
            ),
          ),
          kGap20,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 16,
          child: FaIcon(
            icon,
            size: 16,
            color: MyColors.primary,
          ),
        ),
        kGap12,
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.subtitleDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: Font.small,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        FaIcon(
          icon,
          size: 16,
          color: MyColors.primary,
        ),
        kGap12,
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.subtitleDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: Font.small,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

class _DocumentsTab extends StatelessWidget {
  final List<PatientDocument> documents;
  final Patient patient;

  const _DocumentsTab({
    required this.documents,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    // Group documents by type
    final medicalRecords = <PatientDocument>[];
    final labReports = <PatientDocument>[];
    final prescriptions = <PatientDocument>[];
    final other = <PatientDocument>[];

    for (final doc in documents) {
      switch (doc.type) {
        case DocumentType.medicalRecord:
          medicalRecords.add(doc);
          break;
        case DocumentType.labReport:
          labReports.add(doc);
          break;
        case DocumentType.prescription:
          prescriptions.add(doc);
          break;
        default:
          other.add(doc);
          break;
      }
    }

    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.folderOpen,
              size: 48,
              color: Colors.grey,
            ),
            kGap20,
            const Text(
              'No documents yet',
              style: TextStyle(
                fontSize: Font.medium,
                color: Colors.grey,
              ),
            ),
            kGap10,
            ElevatedButton(
              onPressed: () {
                // Upload document
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upload Document'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: kPadd16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patient Documents',
                style: kSectionTitle,
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // Upload document
                },
                icon: const FaIcon(FontAwesomeIcons.fileArrowUp, size: 14),
                label: const Text('Upload',
                    style: TextStyle(fontSize: Font.small)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MyColors.primary,
                  side: const BorderSide(color: MyColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 30),
                ),
              ),
            ],
          ),
          kGap16,

          // Medical Records
          if (medicalRecords.isNotEmpty) ...[
            const Text(
              'Medical Records',
              style: TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
                color: MyColors.subtitleDark,
              ),
            ),
            kGap20,
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: kPadd0,
              itemCount: medicalRecords.length,
              separatorBuilder: (context, index) => kGap8,
              itemBuilder: (context, index) {
                return _DocumentCard(document: medicalRecords[index]);
              },
            ),
            kGap10,
            const SectionDivider(),
            kGap10,
          ],

          // Lab Reports
          if (labReports.isNotEmpty) ...[
            const Text(
              'Lab Reports',
              style: TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
                color: MyColors.subtitleDark,
              ),
            ),
            kGap8,
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: kPadd0,
              itemCount: labReports.length,
              separatorBuilder: (context, index) => kGap8,
              itemBuilder: (context, index) {
                return _DocumentCard(document: labReports[index]);
              },
            ),
            kGap10,
            const SectionDivider(),
            kGap10,
          ],

          // Prescriptions
          if (prescriptions.isNotEmpty) ...[
            const Text(
              'Prescriptions',
              style: TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
                color: MyColors.subtitleDark,
              ),
            ),
            kGap8,
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: kPadd0,
              itemCount: prescriptions.length,
              separatorBuilder: (context, index) => kGap8,
              itemBuilder: (context, index) {
                return _DocumentCard(document: prescriptions[index]);
              },
            ),
            kGap10,
            const SectionDivider(),
            kGap10,
          ],

          // Other Documents
          if (other.isNotEmpty) ...[
            const Text(
              'Other Documents',
              style: TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.bold,
                color: MyColors.subtitleDark,
              ),
            ),
            kGap8,
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: other.length,
              separatorBuilder: (context, index) => kGap8,
              itemBuilder: (context, index) {
                return _DocumentCard(document: other[index]);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final PatientDocument document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return CustomBase(
      shadow: false,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                _getDocumentIcon(document.type),
                size: 20,
                color: _getDocumentColor(document.type),
              ),
            ),
          ),
          kGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: Font.small,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(document.uploadDate),
                  style: const TextStyle(
                    fontSize: Font.extraSmall,
                    color: MyColors.subtitleDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.download,
              size: 16,
            ),
            onPressed: () {
              // Download document
            },
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.medicalRecord:
        return FontAwesomeIcons.notesMedical;
      case DocumentType.labReport:
        return FontAwesomeIcons.flask;
      case DocumentType.prescription:
        return FontAwesomeIcons.prescription;
      default:
        return FontAwesomeIcons.file;
    }
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.medicalRecord:
        return Colors.blue;
      case DocumentType.labReport:
        return Colors.purple;
      case DocumentType.prescription:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
