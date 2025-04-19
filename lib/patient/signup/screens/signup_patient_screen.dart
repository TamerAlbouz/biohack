import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:medtalk/backend/injectable.dart';
import 'package:medtalk/common/functions/generate_random_password.dart';
import 'package:medtalk/common/widgets/random_hexagons.dart';
import 'package:medtalk/styles/font.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/button.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../common/widgets/button/loading_button.dart';
import '../../../common/widgets/button/success_button.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/date_picker.dart';
import '../../../common/widgets/dividers/section_divider.dart';
import '../../../common/widgets/dropdown/custom_simple_dropdown.dart';
import '../../../styles/colors.dart';
import '../../../styles/styles/text.dart';
import '../bloc/signup_patient_bloc.dart';

class SignUpPatientScreen extends StatefulWidget {
  const SignUpPatientScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SignUpPatientScreen());
  }

  @override
  State<SignUpPatientScreen> createState() => _SignUpPatientScreenState();
}

class _SignUpPatientScreenState extends State<SignUpPatientScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _showResendButton = true;
  late SignUpPatientBloc _signUpBloc;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _signUpBloc.close();
    _controllers.forEach((key, value) => value.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _timer?.cancel();
      _timer = null;
    } else if (state == AppLifecycleState.resumed) {
      if (_signUpBloc.state.requiresEmailVerification && _timer == null) {
        _startEmailVerificationTimer();
      }
    }
  }

  void _startEmailVerificationTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _signUpBloc.add(CheckEmailVerification()),
    );
  }

  // Controllers for text inputs
  late Map<String, TextEditingController> _controllers;

  //
  late String recoveryCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _signUpBloc = getIt<SignUpPatientBloc>();
    _controllers = {
      'email': TextEditingController(),
      'password': TextEditingController(),
      'confirmPassword': TextEditingController(),
      'fullName': TextEditingController(),
    };
    recoveryCode = generateRandomCode(14);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _signUpBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: BlocConsumer<SignUpPatientBloc, SignUpPatientState>(
              listener: (context, state) {
            if (!state.requiresEmailVerification) {
              _timer?.cancel();
              _timer = null;
            }

            if (state.requestSubscription) {
              // check if request is from login or sign up
              context.read<RouteBloc>().add(AuthSubscriptionRequested());
            }

            if (state.generateKeys) {
              context.read<SignUpPatientBloc>().add(GenerateKeys(recoveryCode));
            }

            if (state.requiresEmailVerification && _timer == null) {
              _startEmailVerificationTimer();
            }

            // show error message if there is any
            if (state.status.isFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                  ),
                );

              // clear the error message
              context.read<SignUpPatientBloc>().add(ResetStatus());
            }
          }, builder: (context, state) {
            return Column(
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

                // if state is show recovery codes
                if (state.showRecoveryCodes)
                  Center(
                    child: Padding(
                      padding: kPaddH20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recovery Code',
                            textAlign: TextAlign.left,
                            style: kAppIntro,
                          ),
                          kGap4,
                          const Text(
                            'Save this recovery code in a safe place. You will need it to recover your account if you forget your password.',
                            textAlign: TextAlign.left,
                            style: kAppIntroSubtitle,
                          ),
                          kGap8,
                          Text(
                            'There is no way to recover your account if you lose this code!',
                            textAlign: TextAlign.left,
                            style: kAppIntroSubtitle.copyWith(
                              color: Colors.red,
                            ),
                          ),
                          kGap28,
                          Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: MyColors.cardBackground,
                              borderRadius: kRadius10,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                recoveryCode,
                                style: const TextStyle(
                                  fontSize: Font.medium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          kGap32,
                          // Button to save recovery codes
                          ElevatedButton(
                            onPressed: () {
                              // Capture the bloc reference before showing dialog
                              final signUpBloc =
                                  context.read<SignUpPatientBloc>();
                              // show confirmation dialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: MyColors.cardBackground,
                                    title: Text('Recovery Code',
                                        style: kAppIntro.copyWith(
                                            fontSize: Font.mediumLarge)),
                                    content: const Text(
                                      'Are you sure you have saved your recovery code?',
                                      style: TextStyle(
                                        fontSize: Font.mediumSmall,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          signUpBloc.add(RequestSubscription());
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: kElevatedButtonCommonStyle,
                            child: const Text(
                              'Done',
                              style: TextStyle(fontSize: Font.mediumSmall),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (state.generateKeys)
                  // generating encryption keys... screen
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/json/encrypt.json',
                          height: 200,
                          width: 200,
                          // placeholder until the animation is loaded
                          frameRate: FrameRate.max,
                        ),
                        // show very small linear progress indicator
                        SizedBox(
                          width: 250,
                          child: LinearProgressIndicator(
                            minHeight: 1.5,
                            backgroundColor: Colors.grey[300],
                            color: MyColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Text describing the operation
                        const Text(
                          'Generating Encryption Keys...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Subtle animated dots for extra flair
                        const Text(
                          'Please wait...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                if (state.requiresEmailVerification)
                  Padding(
                    padding: kPaddH20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verify Your Email',
                          textAlign: TextAlign.left,
                          style: kAppIntro,
                        ),
                        kGap4,
                        const Text(
                          'We\'ve sent a verification link to your specified email address. Click the link in the email to verify your account.',
                          textAlign: TextAlign.left,
                          style: kAppIntroSubtitle,
                        ),
                        kGap28,
                        if (_showResendButton) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<SignUpPatientBloc>()
                                      .add(ResendVerificationEmail());
                                  setState(() => _showResendButton = false);
                                  Future.delayed(
                                    const Duration(minutes: 1),
                                    () => setState(
                                        () => _showResendButton = true),
                                  );
                                },
                                child: const Text(
                                  'Resend Verification Email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: Font.smallExtra,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Verification email sent. \nPlease wait 1 minute before requesting another.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: Font.small),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                if (!state.showRecoveryCodes &&
                    !state.generateKeys &&
                    !state.requiresEmailVerification)
                  Padding(
                    padding: kPaddH20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign Up',
                          style: kAppIntro,
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
                        kGap28,
                        _buildFullNameInput(context),
                        kGap4,
                        const SectionDivider(),
                        kGap8,
                        _buildDateOfBirthInput(context),
                        kGap8,
                        _buildSexInput(context),
                        kGap8,
                        const SectionDivider(),
                        kGap8,
                        _buildEmailInput(context),
                        kGap4,
                        _buildPasswordInput(context),
                        kGap4,
                        _buildConfirmPasswordInput(context),
                        kGap20,
                        _buildSignUpButton(),
                        kGap20,
                      ],
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFullNameInput(BuildContext context) {
    return BlocBuilder<SignUpPatientBloc, SignUpPatientState>(
      builder: (context, state) {
        return CustomInputField(
          controller: _controllers['fullName']!,
          hintText: 'Full Name',
          leadingWidget: _controllers['fullName']!.text.isEmpty
              ? const Icon(Icons.person_outlined, color: MyColors.primary)
              : const Icon(Icons.person, color: MyColors.primary),
          keyboardType: TextInputType.name,
          errorText:
              state.fullName.displayError != null ? 'Invalid Name' : null,
          onChanged: (name) {
            context.read<SignUpPatientBloc>().add(
                  FullNameChanged(name),
                );
          },
        );
      },
    );
  }

  Widget _buildDateOfBirthInput(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');

    // Calculate date 18 years ago
    final lastDate = DateTime.now().subtract(const Duration(days: 18 * 365));

    return BlocBuilder<SignUpPatientBloc, SignUpPatientState>(
      builder: (context, state) {
        return DatePicker(
          firstDate: DateTime(1900),
          lastDate: lastDate,
          hint: 'Date of Birth',
          onSelected: (date) {
            // Format date before saving
            final formattedDate = dateFormatter.format(date);

            context.read<SignUpPatientBloc>().add(
                  DateOfBirthChanged(formattedDate),
                );
          },
        );
      },
    );
  }

  Widget _buildSexInput(BuildContext context) {
    return BlocBuilder<SignUpPatientBloc, SignUpPatientState>(
      builder: (context, state) {
        return CustomSimpleDropdown(
          items: const ["Male", "Female"],
          initialValue: state.sex.value,
          hint: 'Sex',
          iconOnLeft: true,
          customLeadingWidget: state.sex.value == ""
              ? const FaIcon(FontAwesomeIcons.genderless,
                  color: MyColors.primary)
              : state.sex.value == "Male"
                  ? const FaIcon(FontAwesomeIcons.mars, color: MyColors.primary)
                  : const FaIcon(FontAwesomeIcons.venus,
                      color: MyColors.primary),
          onChanged: (value) {
            // Use 'Male' as default if no value selected
            context.read<SignUpPatientBloc>().add(SexChanged(value ?? "Male"));
          },
        );
      },
    );
  }

  Widget _buildEmailInput(BuildContext context) {
    return BlocBuilder<SignUpPatientBloc, SignUpPatientState>(
      builder: (context, state) {
        return CustomInputField(
          leadingWidget: _controllers['email']!.text.isEmpty
              ? const Icon(Icons.email_outlined, color: MyColors.primary)
              : const Icon(Icons.email, color: MyColors.primary),
          controller: _controllers['email']!,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          onChanged: (email) {
            context.read<SignUpPatientBloc>().add(SignUpEmailChanged(email));
          },
          errorText:
              state.signUpEmail.displayError != null ? 'Invalid Email' : null,
        );
      },
    );
  }

  Widget _buildPasswordInput(BuildContext context) {
    return BlocBuilder<SignUpPatientBloc, SignUpPatientState>(
      builder: (context, state) {
        return CustomInputField(
          leadingWidget: _controllers['password']!.text.isEmpty
              ? const Icon(Icons.lock_outlined, color: MyColors.primary)
              : const Icon(Icons.lock, color: MyColors.primary),
          controller: _controllers['password']!,
          hintText: 'Password',
          showPasswordToggle: true,
          obscureText: true,
          errorText: state.signUpPassword.displayError != null
              ? "Invalid Password. Must contain at least:\n"
                  "• 8 characters\n"
                  "• 1 uppercase letter\n"
                  "• 1 lowercase letter\n"
                  "• 1 number\n"
                  "• 1 special character\n"
              : null,
          onChanged: (password) {
            context
                .read<SignUpPatientBloc>()
                .add(SignUpPasswordChanged(password));
          },
          keyboardType: TextInputType.visiblePassword,
        );
      },
    );
  }

  Widget _buildConfirmPasswordInput(BuildContext context) {
    return BlocBuilder<SignUpPatientBloc, SignUpPatientState>(
      builder: (context, state) {
        return CustomInputField(
          leadingWidget: _controllers['confirmPassword']!.text.isEmpty
              ? const Icon(Icons.lock_outlined, color: MyColors.primary)
              : const Icon(Icons.lock, color: MyColors.primary),
          controller: _controllers['confirmPassword']!,
          hintText: 'Confirm Password',
          obscureText: true,
          showPasswordToggle: true,
          errorText: (state.signUpPassword.value !=
                      state.signUpConfirmPassword.value) ||
                  state.signUpConfirmPassword.displayError != null
              ? 'Passwords do not match'
              : null,
          onChanged: (confirmPassword) {
            context
                .read<SignUpPatientBloc>()
                .add(SignUpConfirmPasswordChanged(confirmPassword));
          },
          keyboardType: TextInputType.visiblePassword,
        );
      },
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<SignUpPatientBloc, SignUpPatientState>(
      builder: (context, state) {
        final status = state.status;

        if (status.isInProgress) return const LoadingButton();

        if (status.isSuccess) {
          // return the button with a green background and a tick icon
          return const SuccessButton();
        }
        return ElevatedButton(
          onPressed: state.isValid
              ? () => context.read<SignUpPatientBloc>().add(SubmitSignUp())
              : null,
          style: kElevatedButtonCommonStyle,
          child: const Text(
            "Create Account",
            style: TextStyle(fontSize: Font.mediumSmall),
          ),
        );
      },
    );
  }
}
