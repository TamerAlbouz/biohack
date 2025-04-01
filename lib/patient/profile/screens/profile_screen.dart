import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/dividers/card_divider.dart';
import 'package:medtalk/common/widgets/dummy/profile_picture.dart';
import 'package:medtalk/styles/colors.dart';

import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../bloc/patient_profile_bloc.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PatientProfileBloc, PatientProfileState>(
        builder: (context, state) {
          if (state is PatientProfileLoading ||
              state is PatientProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatientProfileError) {
            return Center(child: Text(state.message));
          }

          state as PatientProfileLoaded;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomBase(
                  shadow: false,
                  child: Row(
                    children: [
                      const ProfilePicture(),
                      kGap16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.patient.name ?? '',
                              style: const TextStyle(
                                fontSize: Font.medium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_calculateAge(state.patient.dateOfBirth)} yrs • ${state.patient.sex}',
                              style: const TextStyle(
                                color: MyColors.textGrey,
                                fontSize: Font.small,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // edit button
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                kGap10,
                CustomBase(
                  shadow: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCard('Blood', state.patient.bloodType ?? 'N/A',
                          MyColors.textGrey),
                      // vertical divider
                      const SizedBox(
                        height: 60,
                        child: VerticalDivider(
                          color: MyColors.softStroke,
                        ),
                      ),
                      _buildInfoCard(
                          'Height',
                          '${state.patient.height ?? 'N/A'} ${state.patient.height == null ? '' : 'cm'}',
                          MyColors.textGrey),
                      // vertical divider
                      const SizedBox(
                        height: 60,
                        child: VerticalDivider(
                          color: MyColors.softStroke,
                        ),
                      ),
                      _buildInfoCard(
                          'Weight',
                          '${state.patient.weight ?? 'N/A'} ${state.patient.weight == null ? '' : 'Kg'}',
                          MyColors.textGrey),
                    ],
                  ),
                ),
                kGap10,
                CustomBase(
                  shadow: false,
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Biography',
                            style: TextStyle(
                              fontSize: Font.medium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      kGap12,
                      Container(
                        height: 100,
                        padding: kPadd12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: MyColors.selectionCardEmpty,
                          borderRadius: kRadius12,
                          border:
                              Border.all(color: MyColors.selectionCardStroke),
                        ),
                        // write a long text for patient
                        child: Text(
                          state.patient.biography ?? 'No biography',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: const TextStyle(
                            fontFamily: Font.family,
                            color: MyColors.textBlack,
                            fontSize: Font.smallExtra,
                          ),
                        ),
                      ),
                      kGap5
                    ],
                  ),
                ),
                kGap10,
                CustomBase(
                  shadow: false,
                  child: Column(
                    children: [
                      kGap5,
                      _buildActionButton(
                          'Appointment History', Icons.calendar_today),
                      kGap12,
                      _buildActionButton('Payment Methods', Icons.payment),
                      kGap12,
                      _buildActionButton('Payment History', Icons.history),
                      kGap12,
                      _buildActionButton(
                          'Contact Support', Icons.support_agent),
                      kGap12,
                      _buildActionButton(
                          'Terms & Conditions', Icons.description),
                    ],
                  ),
                ),
                kGap10
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: kPadd0,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MyColors.primary,
              fontFamily: Font.family,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      return age - 1;
    }
    return age;
  }

  Widget _buildActionButton(String title, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: kPadd6,
            decoration: BoxDecoration(
              color: MyColors.primary.withOpacity(0.20),
              borderRadius: kRadius10,
            ),
            child: Icon(
              icon,
              color: MyColors.primary,
            ),
          ),
          kGap10,
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: MyColors.textBlack,
                        fontSize: Font.smallExtra,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                const CardDivider(
                  height: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
