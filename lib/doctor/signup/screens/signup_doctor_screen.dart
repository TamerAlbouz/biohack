import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:p_logger/p_logger.dart';

import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/random_hexagons.dart';
import '../../../styles/colors.dart';
import '../../../styles/font.dart';
import '../../../styles/sizes.dart';
import '../../../styles/styles/button.dart';
import '../../../styles/styles/text.dart';

class SignUpDoctorScreen extends StatefulWidget {
  const SignUpDoctorScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SignUpDoctorScreen());
  }

  @override
  State<SignUpDoctorScreen> createState() => _SignUpDoctorScreenState();
}

class _SignUpDoctorScreenState extends State<SignUpDoctorScreen> {
  final _controllers = {
    'cpsnsNumber': TextEditingController(),
    'speciality': TextEditingController(),
  };

  var _uploadGovIdText =
      'Upload Government ID\n(ID, Passport, or Driver\'s License)';

  var _uploadCertText = 'Upload Medical Certificate';

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Stack(
              children: [
                HexagonPatternBox(
                  height: 180,
                  width: double.infinity,
                ),
              ],
            ),
            kGap20,
            Padding(
              padding: kPaddH20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  kGap4,
                  RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: kAppIntroSubtitle,
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MyColors.primary,
                            decoration: TextDecoration.underline,
                            fontSize: Font.small,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Handle "Switch?" click event
                              Navigator.of(context).pop();
                            },
                        ),
                      ],
                    ),
                  ),
                  kGap24,

                  // CPSNS License Number
                  CustomInputField(
                    controller: _controllers['cpsnsNumber']!,
                    hintText: 'CPSNS License Number',
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      // Handle input changes
                    },
                    leadingWidget:
                        const Icon(Icons.badge, color: MyColors.primary),
                  ),

                  kGap8,

                  // CPSNS License Number
                  CustomInputField(
                    controller: _controllers['speciality']!,
                    hintText: 'Speciality',
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      // Handle input changes
                    },
                    leadingWidget:
                        const Icon(Icons.badge, color: MyColors.primary),
                  ),

                  kGap8,

                  // create a button to upload photo for gov id or driver's license or passport
                  ElevatedButton(
                    onPressed: () async {
                      // Handle upload button click using file_picker
                      // request permission if not granted
                      final file = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                      );

                      if (file != null) {
                        // change the title of the button to the name of the file
                        logger.i('File: ${file.files.single.name}');
                        setState(() {
                          _uploadCertText = file.files.single.name;
                        });
                      }
                    },
                    style: kElevatedButtonCommonStyleOutline.copyWith(
                      backgroundColor:
                          const WidgetStatePropertyAll(MyColors.textField),
                    ),
                    child: Text(
                      _uploadCertText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: Font.extraSmall),
                    ),
                  ),

                  kGap8,

                  // create a button to upload photo for gov id or driver's license or passport
                  ElevatedButton(
                    onPressed: () async {
                      // Handle upload button click using file_picker
                      // request permission if not granted
                      final file = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                      );

                      if (file != null) {
                        // change the title of the button to the name of the file
                        logger.i('File: ${file.files.single.name}');
                        setState(() {
                          _uploadGovIdText = file.files.single.name;
                        });
                      }
                    },
                    style: kElevatedButtonCommonStyleOutline.copyWith(
                      backgroundColor:
                          const WidgetStatePropertyAll(MyColors.textField),
                    ),
                    child: Text(
                      _uploadGovIdText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: Font.extraSmall),
                    ),
                  ),

                  kGap8,

                  // Virtual Care Standards Agreement
                  CheckboxListTile(
                    value: false,
                    onChanged: (value) {
                      // Handle checkbox state
                    },
                    title: const Text(
                      'I agree to comply with CPSNS Virtual Care Standards',
                      style: TextStyle(fontSize: 14),
                    ),
                    dense: true,
                    contentPadding: kPadd0,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle submission
                      },
                      style: kElevatedButtonCommonStyle,
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  kGap14,

                  // Processing Time Info
                  const CustomBase(
                    shadow: false,
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue, size: 24),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Most verifications are completed within 2-3 business days when all documentation is provided.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  kGap20,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
