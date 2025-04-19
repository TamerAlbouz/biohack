import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/backend/injectable.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/patient/search_doctors/bloc/doctor_profile_bloc.dart';
import 'package:medtalk/patient/search_doctors/screens/setup_appointments/widgets/improved_doctor_profile.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

class ViewDoctorProfileScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;

  const ViewDoctorProfileScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
  });

  static Route<void> route({
    required String doctorId,
    required String doctorName,
    required String specialty,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => ViewDoctorProfileScreen(
        doctorId: doctorId,
        doctorName: doctorName,
        specialty: specialty,
      ),
    );
  }

  @override
  State<ViewDoctorProfileScreen> createState() =>
      _ViewDoctorProfileScreenState();
}

class _ViewDoctorProfileScreenState extends State<ViewDoctorProfileScreen>
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
    return BlocProvider(
      create: (context) =>
          getIt<DoctorProfileBloc>()..add(LoadDoctorProfile(widget.doctorId)),
      child: Scaffold(
        backgroundColor: MyColors.background,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: MyColors.cardBackground,
          title: const Text(
            'Doctor Profile',
            style: TextStyle(
              color: MyColors.textBlack,
              fontSize: Font.mediumSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: MyColors.textBlack,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocBuilder<DoctorProfileBloc, DoctorProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return _buildLoadingState();
            }

            return _buildProfileContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: kPaddH20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kGap20,
          // Doctor profile header skeleton
          _buildDoctorProfileSkeleton(),

          kGap30,

          // Tab bar skeleton
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          kGap20,

          // Content skeleton
          for (int i = 0; i < 3; i++) ...[
            Container(
              width: double.infinity,
              height: 16,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],

          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          kGap20,

          // Card skeleton
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorProfileSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Profile picture skeleton
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          kGap16,

          // Doctor info skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name skeleton
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                kGap8,

                // Specialty skeleton
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                kGap8,

                // Reviews skeleton
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, DoctorProfileState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: kPadd20,
        child: Column(
          children: [
            // Doctor profile header
            _buildDoctorProfileHeader(context, state),

            kGap30,

            // About tab
            _buildAboutTab(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProfileHeader(
      BuildContext context, DoctorProfileState state) {
    return ImprovedDoctorProfile(
      doctorName: widget.doctorName,
      specialty: widget.specialty,
      reviewCount: state.reviewCount,
      showArrow: false,
      onViewProfileTap: () {},
    );
  }

  Widget _buildAboutTab(BuildContext context, DoctorProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal information
        const Text(
          'Personal Information',
          style: kSectionTitle,
        ),

        kGap16,

        CustomBase(
          child: Column(
            children: [
              _buildInfoRow(
                FontAwesomeIcons.cakeCandles,
                'Age',
                '${state.doctorAge} years',
              ),
              kGap12,
              const Divider(height: 1),
              kGap12,
              _buildInfoRow(
                FontAwesomeIcons.userDoctor,
                'Gender',
                state.doctorGender ?? 'Not specified',
              ),
            ],
          ),
        ),

        kGap30,

        // Biography section
        const Text(
          'Biography',
          style: kSectionTitle,
        ),

        kGap16,

        CustomBase(
          child: Text(
            state.doctorBiography ?? 'No biography available.',
            style: const TextStyle(
              fontSize: Font.small,
              color: MyColors.textBlack,
              height: 1.5,
            ),
          ),
        ),

        kGap30,

        _buildQualificationsTab(context, state),

        // Extra space at bottom
        kGap80,
      ],
    );
  }

  Widget _buildQualificationsTab(
      BuildContext context, DoctorProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Education section
        const Text(
          'Education',
          style: kSectionTitle,
        ),

        kGap16,

        if (state.doctorQualifications?.isEmpty ?? true)
          _buildEmptyState('No education information available')
        else
          Column(
            children: state.doctorQualifications!.map((education) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomBase(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: MyColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.graduationCap,
                              color: MyColors.primary,
                              size: 16,
                            ),
                          ),
                          kGap12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  education,
                                  style: const TextStyle(
                                    fontSize: Font.mediumSmall,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.textBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: MyColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 16,
              color: MyColors.primary,
            ),
          ),
        ),
        kGap16,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Font.extraSmall,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: Font.small,
                fontWeight: FontWeight.w500,
                color: MyColors.textBlack,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return CustomBase(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              FaIcon(
                FontAwesomeIcons.folderOpen,
                size: 24,
                color: Colors.grey[400],
              ),
              kGap12,
              Text(
                message,
                style: TextStyle(
                  fontSize: Font.small,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
