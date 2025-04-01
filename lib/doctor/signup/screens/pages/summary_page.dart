// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medtalk/common/widgets/pageview/custom_page_view.dart';
// import 'package:medtalk/styles/colors.dart';
// import 'package:medtalk/styles/font.dart';
// import 'package:medtalk/styles/sizes.dart';
// import 'package:medtalk/styles/styles/button.dart';
//
// import '../../bloc/signup_patient_cubit.dart';
//
// class SummaryPage extends StatelessWidget {
//   final CustomStepperController controller;
//   final Map<String, TextEditingController> controllers;
//
//   const SummaryPage({
//     super.key,
//     required this.controller,
//     required this.controllers,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<SignUpPatientCubit, SignUpPatientState>(
//       builder: (context, state) {
//         return SingleChildScrollView(
//           child: Padding(
//             padding: kPaddH20,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Summary',
//                   style: TextStyle(
//                     fontSize: Font.medium,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 kGap20,
//                 _buildSummarySection('Account Information', [
//                   _buildSummaryRow('Email', controllers['email']!.text),
//                 ]),
//                 kGap14,
//                 _buildSummarySection('Personal Information', [
//                   _buildSummaryRow('Full Name', controllers['fullName']!.text),
//                   _buildSummaryRow('Biography', controllers['biography']!.text),
//                 ]),
//                 kGap14,
//                 _buildSummarySection('Medical Information', [
//                   _buildSummaryRow(
//                       'Blood Group',
//                       state.bloodGroup.value != ""
//                           ? state.bloodGroup.value
//                           : 'Not Selected'),
//                   _buildSummaryRow(
//                       'Height', '${controllers['height']!.text} cm'),
//                   _buildSummaryRow(
//                       'Weight', '${controllers['weight']!.text} kg'),
//                   _buildSummaryRow('Date of Birth', state.dateOfBirth.value),
//                   _buildSummaryRow('Sex', state.sex.value),
//                 ]),
//                 kGap20,
//                 _buildConfirmationSection(context),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSummarySection(String title, List<Widget> rows) {
//     return Container(
//       decoration: BoxDecoration(
//         color: MyColors.cardBackground,
//         borderRadius: kRadius10,
//         // very very light shadow
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             offset: const Offset(0, 2),
//             blurRadius: 4,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: Font.mediumSmall,
//               fontWeight: FontWeight.bold,
//               color: MyColors.primary,
//             ),
//           ),
//           kGap10,
//           ...rows,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: Font.small,
//               color: MyColors.textGrey,
//             ),
//           ),
//           Container(
//             alignment: Alignment.centerRight,
//             width: 200,
//             child: Text(
//               value.isNotEmpty ? value : 'Not provided',
//               style: const TextStyle(
//                 fontSize: Font.small,
//                 fontWeight: FontWeight.bold,
//               ),
//               // add ellipsis if value is too long
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildConfirmationSection(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () {
//           // Validate all required fields
//           final bloc = context.read<SignUpPatientCubit>();
//           final state = bloc.state;
//
//           final isAllValid = state.signUpEmail.isValid &&
//               state.signUpPassword.isValid &&
//               state.signUpConfirmPassword.isValid &&
//               controllers['fullName']!.text.isNotEmpty &&
//               state.bloodGroup.value != "" &&
//               controllers['height']!.text.isNotEmpty &&
//               controllers['weight']!.text.isNotEmpty;
//
//           if (isAllValid) {
//             // Trigger account creation
//             // bloc.submitSignUp();
//             controller.markStepComplete();
//           } else {
//             // Show error or prevent proceeding
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Please complete all required fields'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         style: kElevatedButtonCommonStyle,
//         child: const Text(
//           'Create Account',
//           style: TextStyle(
//             fontSize: Font.mediumSmall,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
