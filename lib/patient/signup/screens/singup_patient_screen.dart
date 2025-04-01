// import 'package:backend/backend.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medtalk/common/widgets/pageview/custom_page_view.dart';
// import 'package:medtalk/patient/signup/screens/pages/account_info_page.dart';
// import 'package:medtalk/patient/signup/screens/pages/medical_info_page.dart';
// import 'package:medtalk/patient/signup/screens/pages/personal_info_page.dart';
// import 'package:medtalk/patient/signup/screens/pages/summary_page.dart';
// import 'package:medtalk/styles/colors.dart';
// import 'package:medtalk/styles/font.dart';
// import 'package:medtalk/styles/sizes.dart';
//
// import '../../../common/widgets/wave_gradient.dart';
// import '../bloc/signup_patient_cubit.dart';
//
// class SignUpPatientScreen extends StatefulWidget {
//   const SignUpPatientScreen({super.key});
//
//   static Route<void> route() {
//     return MaterialPageRoute<void>(builder: (_) => const SignUpPatientScreen());
//   }
//
//   @override
//   State<SignUpPatientScreen> createState() => _SignUpPatientScreenState();
// }
//
// class _SignUpPatientScreenState extends State<SignUpPatientScreen> {
//   late final CustomStepperController _stepperController;
//
//   // Controllers for text inputs
//   final _controllers = {
//     'email': TextEditingController(),
//     'password': TextEditingController(),
//     'confirmPassword': TextEditingController(),
//     'fullName': TextEditingController(),
//     'biography': TextEditingController(),
//     'height': TextEditingController(),
//     'weight': TextEditingController(),
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _stepperController = CustomStepperController(
//       canSkipSteps: [false, false, false, false],
//       stepCount: 4,
//     );
//   }
//
//   @override
//   void dispose() {
//     // Dispose all controllers
//     _controllers.forEach((_, controller) => controller.dispose());
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => SignUpPatientCubit(
//         getIt<IPatientRepository>(),
//         getIt<IHashRepository>(),
//         getIt<IEncryptionRepository>(),
//         getIt<IAuthenticationRepository>(),
//       ),
//       child: Scaffold(
//         appBar: AppBar(
//           toolbarHeight: 50,
//           // change leading color
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           centerTitle: true,
//           title: const Text(
//             'Sign Up',
//             style: TextStyle(
//               fontSize: Font.mediumLarge,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         body: Stack(
//           children: [
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: CustomPaint(
//                 painter: WaveGradientPainter(),
//                 child: Container(
//                   height: 250,
//                 ),
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 kGap20,
//                 Expanded(
//                   child: CustomStepper(
//                     controller: _stepperController,
//                     steps: [
//                       // Pass controllers to each page
//                       AccountInfoPage(
//                         controller: _stepperController,
//                         emailController: _controllers['email']!,
//                         passwordController: _controllers['password']!,
//                         confirmPasswordController:
//                             _controllers['confirmPassword']!,
//                       ),
//                       PersonalInfoPage(
//                         controller: _stepperController,
//                         fullNameController: _controllers['fullName']!,
//                         biographyController: _controllers['biography']!,
//                       ),
//                       MedicalInformationPage(
//                         controller: _stepperController,
//                         heightController: _controllers['height']!,
//                         weightController: _controllers['weight']!,
//                       ),
//                       SummaryPage(
//                         controller: _stepperController,
//                         controllers: _controllers,
//                       ),
//                     ],
//                   ),
//                 ),
//                 CustomStepperControls(
//                   onCanceled: () => null,
//                   controller: _stepperController,
//                   darkMode: true,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: kPaddH15,
//       color: MyColors.background,
//       child: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Sign Up',
//             style: TextStyle(
//               fontSize: Font.large,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             'Create your account',
//             style: TextStyle(fontSize: Font.mediumSmall),
//           ),
//           kGap10,
//         ],
//       ),
//     );
//   }
// }
