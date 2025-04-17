import 'dart:async';

import 'package:backend/backend.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:medtalk/common/functions/generate_random_password.dart';
import 'package:medtalk/common/widgets/base/custom_base.dart';
import 'package:medtalk/common/widgets/random_hexagons.dart';
import 'package:medtalk/doctor/signup/bloc/signup_doctor_bloc.dart';
import 'package:medtalk/doctor/signup/models/location.dart';
import 'package:p_logger/p_logger.dart';

import '../../../app/bloc/auth/route_bloc.dart';
import '../../../common/widgets/button/loading_button.dart';
import '../../../common/widgets/button/success_button.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/date_picker.dart';
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

class _SignUpDoctorScreenState extends State<SignUpDoctorScreen>
    with WidgetsBindingObserver {
  // Step progress tracking
  final int _totalSteps = 5;
  final List<String> _stepTitles = [
    'Basic Info',
    'Personal Details',
    'Location',
    'Specialties',
    'Documents'
  ];

  late SignUpDoctorBloc _signUpBloc;
  Timer? _timer;
  bool _showResendButton = true;

  // Recovery code for key generation
  late String recoveryCode;

  // Controller map for text fields
  final Map<String, TextEditingController> _controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'previousName': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
    'cpsnsNumber': TextEditingController(),
    'speciality': TextEditingController(),
  };

  // Page controller for step navigation
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _signUpBloc = SignUpDoctorBloc(
      getIt<ICryptoRepository>(),
      getIt<IAuthenticationRepository>(),
      getIt<IEncryptionRepository>(),
      getIt<IDoctorRepository>(),
      getIt<IPatientRepository>(),
      getIt<ISecureStorageRepository>(),
      getIt<IStorageRepository>(),
    );
    recoveryCode = generateRandomCode(14);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _signUpBloc.close();
    _controllers.forEach((key, value) => value.dispose());
    _pageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _signUpBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
            builder: (context, state) {
              if (state.requiresEmailVerification ||
                  state.generateKeys ||
                  state.showRecoveryCodes) {
                return Container(); // Hide back button in verification screens
              }
              return IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (state.currentStep > 0) {
                    context.read<SignUpDoctorBloc>().add(PreviousStep());
                    _pageController.animateToPage(
                      state.currentStep - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // At first step, go back to login
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        ),
        body: BlocConsumer<SignUpDoctorBloc, SignUpDoctorState>(
          listener: (context, state) {
            if (!state.requiresEmailVerification) {
              _timer?.cancel();
              _timer = null;
            }

            if (state.requestSubscription) {
              context.read<RouteBloc>().add(AuthSubscriptionRequested());
            }

            if (state.generateKeys) {
              _signUpBloc.add(GenerateKeys(recoveryCode));
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
              _signUpBloc.add(ResetStatus());
            }

            // Update page controller when current step changes
            if (!state.requiresEmailVerification &&
                !state.generateKeys &&
                !state.showRecoveryCodes) {
              if (_pageController.page?.toInt() != state.currentStep) {
                _pageController.animateToPage(
                  state.currentStep,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          builder: (context, state) {
            // Show the regular signup flow
            return Column(
              children: [
                // Header with hexagon pattern
                const Stack(
                  children: [
                    HexagonPatternBox(
                      height: 150,
                      width: double.infinity,
                    ),
                  ],
                ),

                // Show email verification screen
                if (state.requiresEmailVerification)
                  _buildEmailVerificationScreen(),

                // Show key generation screen
                if (state.generateKeys) _buildKeyGenerationScreen(),

                // Show recovery codes screen
                if (state.showRecoveryCodes) _buildRecoveryCodesScreen(),

                if (!state.requiresEmailVerification &&
                    !state.generateKeys &&
                    !state.showRecoveryCodes) ...[
                  // Stepper header
                  ImprovedStepperHeader(
                    currentStep: state.currentStep,
                    totalSteps: _totalSteps,
                    stepTitles: _stepTitles,
                  ),

                  // Form content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBasicInfoStep(),
                        _buildPersonalDetailsStep(),
                        _buildLocationStep(),
                        _buildSpecialtiesStep(),
                        _buildDocumentsStep(),
                      ],
                    ),
                  ),

                  // Navigation buttons
                  _buildNavigationButtons(),
                ]
              ],
            );
          },
        ),
      ),
    );
  }

  // Email verification screen
  Widget _buildEmailVerificationScreen() {
    return SingleChildScrollView(
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
                          _signUpBloc.add(ResendVerificationEmail());
                          setState(() => _showResendButton = false);
                          Future.delayed(
                            const Duration(minutes: 1),
                            () => setState(() => _showResendButton = true),
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
        ],
      ),
    );
  }

  // Key generation screen
  Widget _buildKeyGenerationScreen() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/json/encrypt.json',
            height: 200,
            width: 200,
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
    );
  }

  // Recovery codes screen
  Widget _buildRecoveryCodesScreen() {
    return SingleChildScrollView(
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
                      // show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
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
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  _signUpBloc.add(RequestSubscription());
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
        ],
      ),
    );
  }

  // Step 1: Basic Info
  Widget _buildBasicInfoStep() {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: kPaddH20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kGap20,
              // Already have an account link
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
                          Navigator.of(context).pop();
                        },
                    ),
                  ],
                ),
              ),

              kGap24,

              // First and Last Name (combined as Full Name)
              CustomInputField(
                controller: _controllers['firstName']!,
                hintText: 'Full Name',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  context.read<SignUpDoctorBloc>().add(FullNameChanged(value));
                },
                leadingWidget:
                    const Icon(Icons.person, color: MyColors.primary),
              ),

              kGap8,

              // Previous Name (optional)
              CustomInputField(
                controller: _controllers['previousName']!,
                hintText: 'Previous Name (if applicable)',
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  context
                      .read<SignUpDoctorBloc>()
                      .add(PreviousNameChanged(value));
                },
                leadingWidget:
                    const Icon(Icons.history, color: MyColors.primary),
              ),

              kGap8,

              // Email
              CustomInputField(
                controller: _controllers['email']!,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                onChanged: (value) {
                  context
                      .read<SignUpDoctorBloc>()
                      .add(SignUpEmailChanged(value));
                },
                leadingWidget: const Icon(Icons.email, color: MyColors.primary),
              ),

              kGap8,

              // Password
              CustomInputField(
                controller: _controllers['password']!,
                hintText: 'Password',
                obscureText: true,
                showPasswordToggle: true,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  // Add password strength validation here
                  return null;
                },
                onChanged: (value) {
                  context
                      .read<SignUpDoctorBloc>()
                      .add(SignUpPasswordChanged(value));
                },
                leadingWidget: const Icon(Icons.lock, color: MyColors.primary),
              ),

              kGap8,

              // Confirm Password
              CustomInputField(
                controller: _controllers['confirmPassword']!,
                hintText: 'Confirm Password',
                obscureText: true,
                showPasswordToggle: true,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _controllers['password']!.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onChanged: (value) {
                  context
                      .read<SignUpDoctorBloc>()
                      .add(SignUpConfirmPasswordChanged(value));
                },
                leadingWidget: const Icon(Icons.lock, color: MyColors.primary),
              ),

              kGap20,
            ],
          ),
        );
      },
    );
  }

  // Step 2: Personal Details
  Widget _buildPersonalDetailsStep() {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: kPaddH20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kGap20,
              InkWell(
                onTap: () => _showSexPicker(context),
                child: Container(
                  height: 50,
                  padding: kPaddH15,
                  decoration: BoxDecoration(
                    color: MyColors.textField,
                    borderRadius: kRadius10,
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.venusMars,
                          color: MyColors.primary, size: 20),
                      kGap12,
                      Expanded(
                        child: Text(
                          state.sex.value.isEmpty ? 'Sex' : state.sex.value,
                          style: TextStyle(
                            fontSize: Font.small,
                            color: state.sex.value.isNotEmpty
                                ? MyColors.textBlack
                                : MyColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: MyColors.textGrey),
                    ],
                  ),
                ),
              ),

              kGap12,
              _buildDateOfBirthInput(context),
              kGap12,

              InkWell(
                onTap: () => _showLicencePicker(context),
                child: Container(
                  height: 50,
                  padding: kPaddH15,
                  decoration: BoxDecoration(
                    color: MyColors.textField,
                    borderRadius: kRadius10,
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.idCard,
                          color: MyColors.primary, size: 20),
                      kGap12,
                      Expanded(
                        child: Text(
                          state.licenseType.isEmpty
                              ? 'Licence Type'
                              : state.licenseType,
                          style: TextStyle(
                            fontSize: Font.small,
                            color: state.licenseType.isNotEmpty
                                ? MyColors.textBlack
                                : MyColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: MyColors.textGrey),
                    ],
                  ),
                ),
              ),

              kGap12,

              // CPSNS License Number
              CustomInputField(
                controller: _controllers['cpsnsNumber']!,
                hintText: 'CPSNS License Number',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'License number is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  context
                      .read<SignUpDoctorBloc>()
                      .add(LicenseNumberChanged(value));
                },
                leadingWidget: const Icon(Icons.badge, color: MyColors.primary),
              ),

              kGap20,
            ],
          ),
        );
      },
    );
  }

  // Step 3: Location
  Widget _buildLocationStep() {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: kPaddH20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kGap20,

              // Location search field
              InkWell(
                onTap: () => _showLocationPicker(context),
                child: Container(
                  height: 50,
                  padding: kPaddH15,
                  decoration: BoxDecoration(
                    color: MyColors.textField,
                    borderRadius: kRadius10,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: MyColors.primary, size: 20),
                      kGap12,
                      Expanded(
                        child: Text(
                          state.location.isEmpty
                              ? 'Select Location'
                              : state.location,
                          style: TextStyle(
                            fontSize: Font.small,
                            color: state.location.isNotEmpty
                                ? MyColors.textBlack
                                : MyColors.grey,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: MyColors.textGrey),
                    ],
                  ),
                ),
              ),
              kGap12,

              InkWell(
                onTap: () => _showZonePicker(context),
                child: Container(
                  height: 50,
                  padding: kPaddH15,
                  decoration: BoxDecoration(
                    color: MyColors.textField,
                    borderRadius: kRadius10,
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.mapLocation,
                          color: MyColors.primary, size: 18),
                      kGap12,
                      Expanded(
                        child: Text(
                          state.zone.isEmpty ? 'Select Zone' : state.zone,
                          style: TextStyle(
                            fontSize: Font.small,
                            color: state.zone.isNotEmpty
                                ? MyColors.textBlack
                                : MyColors.grey,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: MyColors.textGrey),
                    ],
                  ),
                ),
              ),

              kGap30,

              // Atlantic Registry
              const Text(
                'Atlantic Registry',
                style: TextStyle(
                  fontSize: Font.small,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textGrey,
                ),
              ),

              kGap8,

              // Atlantic Registry options
              Container(
                padding: kPaddH12V8,
                decoration: BoxDecoration(
                  color: MyColors.textField,
                  borderRadius: kRadius10,
                ),
                child: Column(
                  children: ['Yes', 'No'].map((option) {
                    return RadioListTile<String>(
                      title: Text(
                        option,
                        style: const TextStyle(fontSize: Font.small),
                      ),
                      value: option,
                      groupValue: state.isAtlanticRegistry,
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<SignUpDoctorBloc>()
                              .add(AtlanticRegistryChanged(value));
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),

              kGap12,

              // Only show home jurisdiction if "Yes" selected for Atlantic Registry
              if (state.isAtlanticRegistry == 'Yes') ...[
                InkWell(
                  onTap: () => _showRegistrantHomePicker(context),
                  child: Container(
                    height: 50,
                    padding: kPaddH15,
                    decoration: BoxDecoration(
                      color: MyColors.textField,
                      borderRadius: kRadius10,
                    ),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.locationCrosshairs,
                            color: MyColors.primary, size: 20),
                        kGap12,
                        Expanded(
                          child: Text(
                            state.registryHomeJurisdiction.isEmpty
                                ? 'Atlantic Registry Home Jurisdiction'
                                : state.registryHomeJurisdiction,
                            style: TextStyle(
                              fontSize: Font.small,
                              color: state.registryHomeJurisdiction.isNotEmpty
                                  ? MyColors.textBlack
                                  : MyColors.grey,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: MyColors.textGrey),
                      ],
                    ),
                  ),
                ),
                kGap16,
              ],

              kGap20,
            ],
          ),
        );
      },
    );
  }

  // Step 4: Specialties
  Widget _buildSpecialtiesStep() {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: kPaddH20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kGap20,
              InkWell(
                onTap: () => _showRegistrantPicker(context),
                child: Container(
                  height: 50,
                  padding: kPaddH15,
                  decoration: BoxDecoration(
                    color: MyColors.textField,
                    borderRadius: kRadius10,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: MyColors.primary, size: 20),
                      kGap12,
                      Expanded(
                        child: Text(
                          state.registrantType.isEmpty
                              ? 'Select Registrant Type'
                              : state.registrantType,
                          style: TextStyle(
                            fontSize: Font.small,
                            color: state.registrantType.isNotEmpty
                                ? MyColors.textBlack
                                : MyColors.grey,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: MyColors.textGrey),
                    ],
                  ),
                ),
              ),
              kGap12,
              CustomInputField(
                controller: _controllers['speciality']!,
                hintText: 'Speciality',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Specialty is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  context.read<SignUpDoctorBloc>().add(SpecialtyChanged(value));
                },
                leadingWidget:
                    const Icon(Icons.medical_services, color: MyColors.primary),
              ),
              kGap20,
            ],
          ),
        );
      },
    );
  }

  // Step 5: Documents
  Widget _buildDocumentsStep() {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: kPaddH20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kGap20,

              // Upload Medical Certificate
              const Text(
                'MEDICAL CERTIFICATE',
                style: TextStyle(
                  fontSize: Font.small,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textGrey,
                ),
              ),

              kGap8,

              ElevatedButton(
                onPressed: () async {
                  // Handle upload button click using file_picker
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    withData: true,
                  );

                  if (result != null) {
                    final file = result.files.single;
                    logger.i('Medical certificate file: ${file.name}');
                    context
                        .read<SignUpDoctorBloc>()
                        .add(MedicalLicenseUploaded(file));
                  }
                },
                style: kElevatedButtonCommonStyleOutlined.copyWith(
                  backgroundColor:
                      const WidgetStatePropertyAll(MyColors.textField),
                ),
                child: Text(
                  state.medicalLicenseFile != null
                      ? state.medicalLicenseFile!.name
                      : 'Upload Medical Certificate',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: Font.extraSmall),
                ),
              ),

              kGap16,

              // Upload Government ID
              const Text(
                'GOVERNMENT ID',
                style: TextStyle(
                  fontSize: Font.small,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textGrey,
                ),
              ),

              kGap8,

              ElevatedButton(
                onPressed: () async {
                  // Handle upload button click using file_picker
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    withData: true,
                  );

                  if (result != null) {
                    final file = result.files.single;
                    logger.i('Government ID file: ${file.name}');
                    context
                        .read<SignUpDoctorBloc>()
                        .add(GovernmentIdUploaded(file));
                  }
                },
                style: kElevatedButtonCommonStyleOutlined.copyWith(
                  backgroundColor:
                      const WidgetStatePropertyAll(MyColors.textField),
                ),
                child: Text(
                  state.governmentIdFile != null
                      ? state.governmentIdFile!.name
                      : 'Upload Government ID\n(ID, Passport, or Driver\'s License)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: Font.extraSmall),
                ),
              ),

              kGap16,

              // Virtual Care Standards Agreement
              CheckboxListTile(
                value: state.termsAccepted,
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<SignUpDoctorBloc>()
                        .add(TermsAcceptedChanged(value));
                  }
                },
                title: const Text(
                  'I agree to comply with CPSNS Virtual Care Standards',
                  style: TextStyle(fontSize: Font.small),
                ),
                dense: true,
                contentPadding: kPadd0,
                controlAffinity: ListTileControlAffinity.leading,
              ),

              kGap16,

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
                        style: TextStyle(fontSize: Font.small),
                      ),
                    ),
                  ],
                ),
              ),

              kGap20,
            ],
          ),
        );
      },
    );
  }

  // Navigation buttons
  Widget _buildNavigationButtons() {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        final bool isLastStep = state.currentStep == _totalSteps - 1;
        bool canProceed = false;

        // Determine if the current step is valid
        switch (state.currentStep) {
          case 0: // Basic Info
            canProceed = state.isBasicInfoValid;
            break;
          case 1: // Personal Details
            canProceed = state.isPersonalDetailsValid;
            break;
          case 2: // Location
            canProceed = state.isLocationValid;
            break;
          case 3: // Specialties
            canProceed = state.isSpecialtiesValid;
            break;
          case 4: // Documents
            canProceed = state.isDocumentsValid;
            break;
          default:
            canProceed = false;
        }

        // If submitting, show a loading button
        if (state.status == FormzSubmissionStatus.inProgress) {
          return Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
            decoration: BoxDecoration(
              color: MyColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: const LoadingButton(),
          );
        }

        // If submitted successfully, show a success button
        if (state.status == FormzSubmissionStatus.success) {
          return Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
            decoration: BoxDecoration(
              color: MyColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: const SuccessButton(),
          );
        }

        // Regular navigation buttons
        return Container(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
          decoration: BoxDecoration(
            color: MyColors.cardBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Back button
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    if (state.currentStep > 0) {
                      context.read<SignUpDoctorBloc>().add(PreviousStep());
                    } else {
                      // At first step, go back to login
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.grey.withValues(alpha: 0.2),
                    foregroundColor: MyColors.textGrey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor:
                        MyColors.grey.withValues(alpha: 0.2),
                    disabledForegroundColor: MyColors.textGrey,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: Font.mediumSmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              kGap16,

              // Next/Submit button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canProceed
                      ? () {
                          if (isLastStep) {
                            context
                                .read<SignUpDoctorBloc>()
                                .add(SubmitSignUp());
                          } else if (state.currentStep == 0) {
                            // For the first step, check if email exists before proceeding
                            context.read<SignUpDoctorBloc>().add(
                                CheckEmailExists(_controllers['email']!.text));
                          } else {
                            context.read<SignUpDoctorBloc>().add(NextStep());
                          }
                        }
                      : null,
                  style: kElevatedButtonCommonStyle,
                  child: Text(
                    isLastStep ? 'Submit' : 'Next',
                    style: const TextStyle(
                      fontSize: Font.mediumSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to your class
  void _showSexPicker(BuildContext context) {
    final signUpBloc = context.read<SignUpDoctorBloc>();

    const line = DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1,
      dashLength: 4.0,
      dashColor: MyColors.softStroke,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: signUpBloc,
          child: Container(
            height: 300,
            padding: kPadd16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Sex',
                  style: TextStyle(
                    fontSize: Font.medium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                kGap10,
                Expanded(
                  child: ListView(
                    children: [
                      _buildSexOption(context, 'Male'),
                      line,
                      _buildSexOption(context, 'Female'),
                      line,
                      _buildSexOption(context, 'Prefer not to say'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSexOption(BuildContext context, String label) {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        bool isSelected = state.sex.value == label;

        return InkWell(
          onTap: () {
            context.read<SignUpDoctorBloc>().add(SexChanged(label));
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Font.medium,
                    color: isSelected ? MyColors.primary : MyColors.textBlack,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: MyColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Licence Type Picker
  void _showLicencePicker(BuildContext context) {
    final signUpBloc = context.read<SignUpDoctorBloc>();

    final List<String> licenseTypeOptions = [
      'Academic Licence',
      'Clinical Assessment Licence',
      'Clinical Assistant Licence',
      'Defined Licence',
      'Defined Licence – Fellowship',
      'Full Licence',
      'Full Licence (Atlantic Registry)',
      'Full Licence With Postgraduate Training',
      'Physician Assistant Licence',
      'Podiatrist Licence',
      'Postgraduate Practising Licence',
      'Postgraduate Training Licence',
      'Postgraduate Training Licence - Elective',
      'Restricted Licence',
      'Temporary Licence',
    ];

    final TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = List.from(licenseTypeOptions);

    const line = DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1,
      dashLength: 4.0,
      dashColor: MyColors.softStroke,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return BlocProvider.value(
            value: signUpBloc,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: kPadd16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'License Type',
                    style: TextStyle(
                      fontSize: Font.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  kGap10,
                  // Search field
                  CustomInputField(
                    controller: searchController,
                    hintText: 'Search license types',
                    onChanged: (value) {
                      setState(() {
                        filteredOptions = licenseTypeOptions
                            .where((option) => option
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    color: Colors.grey.shade50,
                    leadingWidget:
                        const Icon(Icons.search, color: MyColors.primary),
                    keyboardType: TextInputType.text,
                  ),
                  kGap10,
                  Expanded(
                    child: ListView(
                      children: filteredOptions.map((option) {
                        return Column(
                          children: [
                            _buildLicenceOption(context, option),
                            if (option != filteredOptions.last) line,
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildLicenceOption(BuildContext context, String label) {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        bool isSelected = state.licenseType == label;

        return InkWell(
          onTap: () {
            context.read<SignUpDoctorBloc>().add(LicenseTypeChanged(label));
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: Font.medium,
                      color: isSelected ? MyColors.primary : MyColors.textBlack,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: MyColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Location Picker
  void _showLocationPicker(BuildContext context) {
    final signUpBloc = context.read<SignUpDoctorBloc>();

    final TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = List.from(locations);

    const line = DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1,
      dashLength: 4.0,
      dashColor: MyColors.softStroke,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return BlocProvider.value(
            value: signUpBloc,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: kPadd16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Location',
                    style: TextStyle(
                      fontSize: Font.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  kGap10,
                  // Search field
                  CustomInputField(
                    controller: searchController,
                    hintText: 'Search Locations',
                    onChanged: (value) {
                      setState(() {
                        filteredOptions = locations
                            .where((option) => option
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    color: Colors.grey.shade50,
                    leadingWidget:
                        const Icon(Icons.search, color: MyColors.primary),
                    keyboardType: TextInputType.text,
                  ),
                  kGap10,
                  Expanded(
                    child: ListView(
                      children: filteredOptions.map((option) {
                        return Column(
                          children: [
                            _buildLocationOption(context, option),
                            if (option != filteredOptions.last) line,
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildLocationOption(BuildContext context, String label) {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        bool isSelected = state.location == label;

        return InkWell(
          onTap: () {
            context.read<SignUpDoctorBloc>().add(LocationChanged(label));
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Font.medium,
                    color: isSelected ? MyColors.primary : MyColors.textBlack,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: MyColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Zone Picker
  void _showZonePicker(BuildContext context) {
    final signUpBloc = context.read<SignUpDoctorBloc>();

    final List<String> zoneOptions = [
      'Central Zone',
      'Eastern Zone',
      'IWK Health Centre',
      'Northern Zone',
      'Western Zone'
    ];

    const line = DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1,
      dashLength: 4.0,
      dashColor: MyColors.softStroke,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: signUpBloc,
          child: Container(
            height: 400,
            padding: kPadd16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Zone',
                  style: TextStyle(
                    fontSize: Font.medium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                kGap10,
                Expanded(
                  child: ListView(
                    children: zoneOptions.map((zone) {
                      return Column(
                        children: [
                          _buildZoneOption(context, zone),
                          if (zone != zoneOptions.last) line,
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoneOption(BuildContext context, String label) {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        bool isSelected = state.zone == label;

        return InkWell(
          onTap: () {
            context.read<SignUpDoctorBloc>().add(ZoneChanged(label));
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Font.medium,
                    color: isSelected ? MyColors.primary : MyColors.textBlack,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: MyColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Registry Home Jurisdiction Picker
  void _showRegistrantHomePicker(BuildContext context) {
    final signUpBloc = context.read<SignUpDoctorBloc>();

    final List<String> registryHomeOptions = [
      'Atlantic Registry - PEI',
      'Atlantic Registry - NL',
      'Atlantic Registry - NS',
      'Atlantic Registry - NB'
    ];

    const line = DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1,
      dashLength: 4.0,
      dashColor: MyColors.softStroke,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: signUpBloc,
          child: Container(
            height: 400,
            padding: kPadd16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Registrant Home Jurisdiction',
                  style: TextStyle(
                    fontSize: Font.medium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                kGap10,
                Expanded(
                  child: ListView(
                    children: registryHomeOptions.map((option) {
                      return Column(
                        children: [
                          _buildRegistrantHomeOption(context, option),
                          if (option != registryHomeOptions.last) line,
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegistrantHomeOption(BuildContext context, String label) {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        bool isSelected = state.registryHomeJurisdiction == label;

        return InkWell(
          onTap: () {
            context.read<SignUpDoctorBloc>().add(RegistryHomeChanged(label));
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Font.medium,
                    color: isSelected ? MyColors.primary : MyColors.textBlack,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: MyColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Registrant Type Picker
  void _showRegistrantPicker(BuildContext context) {
    final signUpBloc = context.read<SignUpDoctorBloc>();

    final List<String> registrantTypeOptions = [
      'All Registrants',
      'Family Physicians',
      'Specialty (excluding Family Medicine)',
      'Physicians Associate Physicians',
      'Podiatrists',
      'Physician Assistants'
    ];

    const line = DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1,
      dashLength: 4.0,
      dashColor: MyColors.softStroke,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.cardBackground,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: signUpBloc,
          child: Container(
            height: 400,
            padding: kPadd16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registrant Type',
                  style: TextStyle(
                    fontSize: Font.medium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                kGap10,
                Expanded(
                  child: ListView(
                    children: registrantTypeOptions.map((option) {
                      return Column(
                        children: [
                          _buildRegistrantOption(context, option),
                          if (option != registrantTypeOptions.last) line,
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegistrantOption(BuildContext context, String label) {
    return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
      builder: (context, state) {
        bool isSelected = state.registrantType == label;

        return InkWell(
          onTap: () {
            context.read<SignUpDoctorBloc>().add(RegistrantTypeChanged(label));
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Font.medium,
                    color: isSelected ? MyColors.primary : MyColors.textBlack,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: MyColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Import this class from your setup_appointments/widgets folder
class ImprovedStepperHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const ImprovedStepperHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current step title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: const TextStyle(
                  fontSize: Font.small,
                  color: MyColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              kGap4,
              Text(
                stepTitles[currentStep],
                style: const TextStyle(
                  fontSize: Font.medium,
                  fontWeight: FontWeight.bold,
                  color: MyColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildDateOfBirthInput(BuildContext context) {
  final dateFormatter = DateFormat('dd/MM/yyyy');

  // Calculate date 18 years ago
  final lastDate = DateTime.now().subtract(const Duration(days: 18 * 365));

  return BlocBuilder<SignUpDoctorBloc, SignUpDoctorState>(
    builder: (context, state) {
      return DatePicker(
        firstDate: DateTime(1900),
        lastDate: lastDate,
        hint: 'Date of Birth',
        initialDate: state.dateOfBirth.value.isNotEmpty
            ? dateFormatter.parse(state.dateOfBirth.value)
            : lastDate,
        onSelected: (date) {
          // Format date before saving
          final formattedDate = dateFormatter.format(date);

          context.read<SignUpDoctorBloc>().add(
                DateOfBirthChanged(formattedDate),
              );
        },
      );
    },
  );
}
