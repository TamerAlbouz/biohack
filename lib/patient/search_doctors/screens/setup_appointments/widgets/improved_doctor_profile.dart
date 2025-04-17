import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';

import '../../../../../common/widgets/dummy/profile_picture.dart';
import '../../../../../styles/colors.dart';
import '../../../../../styles/font.dart';
import '../../../../../styles/sizes.dart';

class ImprovedDoctorProfile extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String imageUrl;
  final int reviewCount;
  final VoidCallback onViewProfileTap;
  final bool? showArrow;

  const ImprovedDoctorProfile({
    super.key,
    required this.doctorName,
    required this.specialty,
    this.imageUrl = '',
    this.reviewCount = 0,
    required this.onViewProfileTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewProfileTap,
      child: CustomBase(
        padding: kPaddH20V14,
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: kRadiusAll,
                    border: Border.all(color: MyColors.primary, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : const ProfilePicture(width: 70, height: 70),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MyColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
            kGap16,
            // Doctor info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: Font.mediumSmall,
                      color: MyColors.textBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  kGap4,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MyColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: Font.extraSmall,
                        color: MyColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  kGap8,
                  // Rating and reviews

                  Text(
                    '($reviewCount reviews)',
                    style: TextStyle(
                      fontSize: Font.extraSmall,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // View profile button
            if (showArrow == true)
              InkWell(
                onTap: onViewProfileTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.arrowRight,
                    color: MyColors.primary,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
