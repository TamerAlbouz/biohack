import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/backend/appointment/models/appointment.dart';
import 'package:medtalk/backend/patient/models/patient.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/doctor/patients/screens/patient_details.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';

import '../bloc/patients_list_bloc.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PatientsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const PatientsView();
  }
}

class PatientsView extends StatefulWidget {
  const PatientsView({super.key});

  @override
  State<PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<PatientsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PatientFilter _currentFilter = PatientFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      // Trigger search if using debounced search through BLoC
      context.read<PatientsBloc>().add(SearchPatients(_searchQuery));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: MyColors.background,
        foregroundColor: MyColors.primary,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.sort),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: kPadd12,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: Font.mediumSmall,
                color: MyColors.primary,
              ),
              decoration: InputDecoration(
                hintText: 'Search patients...',
                fillColor: MyColors.cardBackground,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: Font.mediumSmall,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: MyColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                filled: true,
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: kPaddH12,
            child: Row(
              children: [
                _buildFilterChip(PatientFilter.all, 'All'),
                kGap8,
                _buildFilterChip(PatientFilter.recent, 'Recent'),
                kGap8,
                _buildFilterChip(PatientFilter.upcoming, 'Upcoming'),
                kGap8,
                _buildFilterChip(PatientFilter.newPatients, 'New'),
                kGap8,
                _buildFilterChip(PatientFilter.highValue, 'High Value'),
              ],
            ),
          ),

          // Patient list
          Expanded(
            child: BlocConsumer<PatientsBloc, PatientsState>(
              listener: (context, state) {
                if (state is PatientsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is PatientsInitial) {
                  context
                      .read<PatientsBloc>()
                      .add(LoadPatients(_currentFilter));
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PatientsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PatientsLoaded) {
                  // Filter patients based on search query
                  final filteredPatients = state.patients.where((patient) {
                    final name = patient.name?.toLowerCase() ?? '';
                    final query = _searchQuery.toLowerCase();
                    return query.isEmpty || name.contains(query);
                  }).toList();

                  if (filteredPatients.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.userLarge,
                            size: 48,
                            color: Colors.grey,
                          ),
                          kGap20,
                          Text(
                            'No patients found',
                            style: TextStyle(
                              fontSize: Font.medium,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<PatientsBloc>()
                          .add(LoadPatients(_currentFilter));
                    },
                    child: ListView.separated(
                      padding: kPadd12,
                      itemCount: filteredPatients.length,
                      separatorBuilder: (context, index) => kGap8,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        return _PatientListItem(
                          patient: patient,
                          nextAppointment:
                              state.upcomingAppointments[patient.uid],
                          onTap: () {
                            Navigator.of(context).push(
                              PatientDetailsScreen.route(patient.uid),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                // Error state
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
                      const Text(
                        'Error loading patients',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: Font.medium,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      kGap20,
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<PatientsBloc>()
                              .add(LoadPatients(_currentFilter));
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(PatientFilter filter, String label) {
    final isSelected = _currentFilter == filter;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: Font.small,
          color: isSelected ? Colors.white : MyColors.primary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
        context.read<PatientsBloc>().add(LoadPatients(filter));
      },
      backgroundColor: MyColors.cardBackground,
      selectedColor: MyColors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? MyColors.primary : Colors.grey[300]!,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // This could be expanded to a more advanced filter dialog
    // with date range, patient types, etc.
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: kPadd20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort Patients By',
                style: TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap20,
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.arrowDownAZ),
                title: const Text('Name (A-Z)'),
                onTap: () {
                  context
                      .read<PatientsBloc>()
                      .add(SortPatients(SortOrder.nameAsc));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.arrowDownZA),
                title: const Text('Name (Z-A)'),
                onTap: () {
                  context
                      .read<PatientsBloc>()
                      .add(SortPatients(SortOrder.nameDesc));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.clock),
                title: const Text('Recent Visit'),
                onTap: () {
                  context
                      .read<PatientsBloc>()
                      .add(SortPatients(SortOrder.recentVisit));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.dollarSign),
                title: const Text('Revenue (High to Low)'),
                onTap: () {
                  context
                      .read<PatientsBloc>()
                      .add(SortPatients(SortOrder.revenue));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PatientListItem extends StatelessWidget {
  final Patient patient;
  final Appointment? nextAppointment;
  final VoidCallback onTap;

  const _PatientListItem({
    required this.patient,
    this.nextAppointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUpcomingAppointment = nextAppointment != null;

    return GestureDetector(
      onTap: onTap,
      child: CustomBase(
        shadow: false,
        child: Row(
          children: [
            // Patient avatar or initials
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: MyColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  _getInitials(patient.name ?? 'Unknown'),
                  style: const TextStyle(
                    fontSize: Font.medium,
                    fontWeight: FontWeight.bold,
                    color: MyColors.primary,
                  ),
                ),
              ),
            ),
            kGap12,

            // Patient info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name ?? 'Unknown Patient',
                    style: const TextStyle(
                      fontSize: Font.smallExtra,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (patient.dateOfBirth != null)
                    Text(
                      '${_calculateAge(patient.dateOfBirth!)} years • ${patient.sex ?? 'Not specified'}',
                      style: const TextStyle(
                        fontSize: Font.extraSmall,
                        color: MyColors.subtitleDark,
                      ),
                    ),
                  if (hasUpcomingAppointment)
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.calendar,
                          size: 12,
                          color: MyColors.primary,
                        ),
                        kGap4,
                        Text(
                          DateFormat('MMM dd, h:mm a')
                              .format(nextAppointment!.appointmentDate),
                          style: const TextStyle(
                            fontSize: Font.extraSmall,
                            color: MyColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Action buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.solidMessage,
                    size: 18,
                    color: MyColors.primary,
                  ),
                  onPressed: () {
                    // Message patient
                  },
                ),
              ],
            ),
          ],
        ),
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
