// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:formz_inputs/formz_inputs.dart';
// import 'package:medtalk/common/widgets/custom_input_field.dart';
// import 'package:medtalk/styles/font.dart';
// import 'package:medtalk/styles/sizes.dart';
//
// import '../../../../common/widgets/pageview/custom_page_view.dart';
// import '../../bloc/signup_patient_cubit.dart';
//
// class PersonalInfoPage extends StatelessWidget {
//   final CustomStepperController controller;
//   final TextEditingController fullNameController;
//   final TextEditingController biographyController;
//
//   const PersonalInfoPage({
//     super.key,
//     required this.controller,
//     required this.fullNameController,
//     required this.biographyController,
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
//               'Personal Information',
//               style: TextStyle(
//                 fontSize: Font.medium,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             kGap10,
//             _buildBiographyInput(context),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFullNameInput(BuildContext context) {
//     return BlocSelector<SignUpPatientCubit, SignUpPatientState,
//         FullNameValidationError?>(
//       selector: (state) => state.fullName.displayError,
//       builder: (context, displayError) {
//         return CustomInputField(
//           controller: fullNameController,
//           hintText: 'Full Name',
//           keyboardType: TextInputType.name,
//           errorText: displayError != null ? 'Invalid Name' : null,
//           onChanged: (name) {
//             context.read<SignUpPatientCubit>().fullNameChanged(name);
//             _validateStep(context);
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildBiographyInput(BuildContext context) {
//     return CustomInputField(
//       controller: biographyController,
//       hintText: 'Biography (Optional)',
//       keyboardType: TextInputType.multiline,
//       maxLines: 8,
//       onChanged: (bio) {
//         context.read<SignUpPatientCubit>().biographyChanged(bio);
//       },
//     );
//   }
//
//   void _validateStep(BuildContext context) {
//     final bloc = context.read<SignUpPatientCubit>();
//     final state = bloc.state;
//
//     final isValid = state.fullName.isValid;
//
//     if (isValid) {
//       controller.markStepComplete();
//     } else {
//       controller.markStepIncomplete();
//     }
//   }
// }
