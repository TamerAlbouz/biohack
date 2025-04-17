part of 'doctor_profile_bloc.dart';

class DoctorProfileState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? doctorProfilePicture;
  final String? doctorBiography;
  final double doctorRating;
  final int reviewCount;
  final int? doctorAge;
  final String? doctorGender;
  final List<String>? doctorQualifications;

  const DoctorProfileState({
    this.isLoading = true,
    this.error,
    this.doctorProfilePicture,
    this.doctorBiography,
    this.doctorRating = 0.0,
    this.reviewCount = 0,
    this.doctorAge,
    this.doctorGender,
    this.doctorQualifications,
  });

  DoctorProfileState copyWith({
    bool? isLoading,
    String? error,
    String? doctorProfilePicture,
    String? doctorBiography,
    double? doctorRating,
    int? reviewCount,
    int? doctorAge,
    String? doctorGender,
    List<String>? doctorQualifications,
  }) {
    return DoctorProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      doctorProfilePicture: doctorProfilePicture ?? this.doctorProfilePicture,
      doctorBiography: doctorBiography ?? this.doctorBiography,
      doctorRating: doctorRating ?? this.doctorRating,
      reviewCount: reviewCount ?? this.reviewCount,
      doctorAge: doctorAge ?? this.doctorAge,
      doctorGender: doctorGender ?? this.doctorGender,
      doctorQualifications: doctorQualifications ?? this.doctorQualifications,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        doctorProfilePicture,
        doctorBiography,
        doctorRating,
        reviewCount,
        doctorAge,
        doctorGender,
        doctorQualifications,
      ];
}
