// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medtalk/common/widgets/custom_input_field.dart';
// import 'package:medtalk/styles/font.dart';
// import 'package:medtalk/styles/sizes.dart';
//
// import '../../../../common/widgets/dropdown/custom_simple_dropdown.dart';
// import '../../../../common/widgets/pageview/custom_page_view.dart';
// import '../../../../styles/colors.dart';
// import '../../bloc/signup_patient_cubit.dart';
//
// class MedicalInformationPage extends StatelessWidget {
//   final CustomStepperController controller;
//   final TextEditingController heightController;
//   final TextEditingController weightController;
//
//   const MedicalInformationPage({
//     super.key,
//     required this.controller,
//     required this.heightController,
//     required this.weightController,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: kPaddH15,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Medical Information',
//               style: TextStyle(
//                 fontSize: Font.medium,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             kGap14,
//             _buildBloodGroupSelector(context),
//             kGap14,
//             _buildHeightInput(context),
//             kGap4,
//             _buildWeightInput(context),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBloodGroupSelector(BuildContext context) {
//     return BlocBuilder<SignUpPatientCubit, SignUpPatientState>(
//         builder: (context, state) {
//       return CustomSimpleDropdown(
//         items: const ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'],
//         initialValue: state.bloodGroup.value,
//         hint: 'Blood Group',
//         onChanged: (value) {
//           // Use 'A+' as default if no value selected
//           context.read<SignUpPatientCubit>().bloodGroupChanged(value ?? "A+");
//
//           _validateStep(context);
//         },
//       );
//     });
//   }
//
//   Widget _buildWeightInput(BuildContext context) {
//     return BlocBuilder<SignUpPatientCubit, SignUpPatientState>(
//       buildWhen: (previous, current) => previous.weight != current.weight,
//       builder: (context, state) {
//         return CustomInputField(
//           controller: weightController,
//           hintText: 'Weight',
//           keyboardType: TextInputType.number,
//           trailingWidget: const Text('kg',
//               style: TextStyle(
//                   fontSize: Font.mediumSmall, color: MyColors.textGrey)),
//           onChanged: (weight) {
//             context.read<SignUpPatientCubit>().weightChanged(weight);
//
//             // Validate and update stepper
//             _validateStep(context);
//           },
//           errorText:
//               state.weight.displayError != null ? "Invalid Weight" : null,
//         );
//       },
//     );
//   }
//
//   Widget _buildHeightInput(BuildContext context) {
//     return BlocBuilder<SignUpPatientCubit, SignUpPatientState>(
//       buildWhen: (previous, current) => previous.height != current.height,
//       builder: (context, state) {
//         return CustomInputField(
//           controller: heightController,
//           hintText: 'Height',
//           keyboardType: TextInputType.number,
//           trailingWidget: const Text('cm',
//               style: TextStyle(
//                   fontSize: Font.mediumSmall, color: MyColors.textGrey)),
//           onChanged: (height) {
//             context.read<SignUpPatientCubit>().heightChanged(height);
//             _validateStep(context);
//           },
//           errorText:
//               state.height.displayError != null ? "Invalid Height" : null,
//         );
//       },
//     );
//   }
//
//   void _validateStep(BuildContext context) {
//     final state = context.read<SignUpPatientCubit>().state;
//
//     final condition = state.height.isValid &&
//         state.weight.isValid &&
//         (state.bloodGroup.isValid && state.bloodGroup.value != "") &&
//         (state.dateOfBirth.isValid && state.dateOfBirth.value != "") &&
//         (state.sex.isValid && state.sex.value != "");
//
//     // Validate and update stepper
//     if (condition) {
//       controller.markStepComplete();
//     } else {
//       controller.markStepIncomplete();
//     }
//   }
// }
