part of 'intro_patient_cubit.dart';

final class IntroPatientState extends Equatable {
  const IntroPatientState({
    this.fullName = const FullName.pure(),
    this.dateOfBirth = const DateOfBirth.pure(),
    this.sex = const Sex.pure(),
    this.bloodGroup = const BloodGroup.pure(),
    this.height = const Height.pure(),
    this.weight = const Weight.pure(),
    this.biography = const Biography.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  final FullName fullName;
  final DateOfBirth dateOfBirth;
  final Sex sex;
  final BloodGroup bloodGroup;
  final Height height;
  final Weight weight;
  final Biography biography;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        fullName,
        dateOfBirth,
        sex,
        bloodGroup,
        height,
        weight,
        biography,
        status,
        isValid,
        errorMessage
      ];

  IntroPatientState copyWith({
    FullName? fullName,
    DateOfBirth? dateOfBirth,
    Sex? sex,
    BloodGroup? bloodGroup,
    Height? height,
    Weight? weight,
    Biography? biography,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return IntroPatientState(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      biography: biography ?? this.biography,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
