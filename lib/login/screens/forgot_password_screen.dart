import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:lottie/lottie.dart';
import 'package:medtalk/common/functions/generate_random_password.dart';
import 'package:medtalk/common/widgets/button/loading_button.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
import 'package:medtalk/login/bloc/forgot_password_bloc.dart';
import 'package:medtalk/styles/styles/button.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../common/widgets/random_hexagons.dart';
import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/sizes.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => ForgotPasswordScreen(),
    );
  }

  final TextEditingController _controller = TextEditingController();
  final String newRecoveryCode = generateRandomCode(14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocProvider(
        create: (_) => ForgotPasswordBloc(
          getIt<IAuthenticationRepository>(),
          getIt<IEncryptionRepository>(),
          getIt<ICryptoRepository>(),
          getIt<IRateLimiter>(),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HexagonPatternBox(
                width: double.infinity,
                height: 180,
              ),
              kGap20,
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_back_ios,
                          color: MyColors.primary, size: 18),
                      Text(
                        'Nevermind, I remember my password',
                        style: kAppIntroSubtitle.copyWith(
                          color: MyColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: MyColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              kGap2,
              BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                builder: (context, state) {
                  // if state is show recovery codes
                  if (state.showRecovery) {
                    return Center(
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
                                  newRecoveryCode,
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
                                final forgotBloc =
                                    context.read<ForgotPasswordBloc>();
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
                                            Navigator.of(context).pop();
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
                    );
                  }

                  if (state.showResetPassword &&
                      state.status == FormzSubmissionStatus.inProgress) {
                    // generating encryption keys... screen
                    return Center(
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
                    );
                  }

                  if (state.showResetPassword) {
                    return Padding(
                      padding: kPaddH20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reset Password',
                            textAlign: TextAlign.left,
                            style: kAppIntro,
                          ),
                          kGap4,
                          // enter recovery code
                          const Text(
                            'Enter your personal recovery code that was provided to you on sign up.',
                            style: kAppIntroSubtitle,
                          ),
                          kGap40,
                          CustomInputField(
                            hintText: "Recovery Code",
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                context
                                    .read<ForgotPasswordBloc>()
                                    .add(RecoveryCodeChanged(value));
                              }
                            },
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            showPasswordToggle: true,
                          ),
                          kGap24,
                          const Text(
                            'Enter your new password',
                            style: kAppIntroSubtitle,
                          ),
                          kGap12,
                          CustomInputField(
                            hintText: "New Password",
                            onChanged: (value) {
                              context
                                  .read<ForgotPasswordBloc>()
                                  .add(PasswordChanged(value));
                            },
                            obscureText: true,
                            showPasswordToggle: true,
                            keyboardType: TextInputType.visiblePassword,
                            errorText: state.password.isNotValid &&
                                    state.password.value.isNotEmpty
                                ? "Invalid Password. Must contain at least:\n"
                                    "• 8 characters\n"
                                    "• 1 uppercase letter\n"
                                    "• 1 lowercase letter\n"
                                    "• 1 number\n"
                                    "• 1 special character\n"
                                : null,
                          ),
                          kGap4,
                          CustomInputField(
                            hintText: "Confirm Password",
                            onChanged: (value) {
                              context
                                  .read<ForgotPasswordBloc>()
                                  .add(ConfirmPasswordChanged(value));
                            },
                            obscureText: true,
                            showPasswordToggle: true,
                            keyboardType: TextInputType.visiblePassword,
                            errorText: state.password.isValid
                                ? state.confirmPassword == state.password.value
                                    ? null
                                    : 'Passwords do not match'
                                : null,
                          ),
                          kGap12,
                          if (state.status == FormzSubmissionStatus.inProgress)
                            const LoadingButton()
                          else
                            ElevatedButton(
                              onPressed: state.isValid
                                  ? () {
                                      context.read<ForgotPasswordBloc>().add(
                                            ResetPasswordWithCode(
                                                newRecoveryCode:
                                                    newRecoveryCode),
                                          );
                                    }
                                  : null,
                              style: kElevatedButtonCommonStyle,
                              child: const Text('Reset Password'),
                            ),
                        ],
                      ),
                    );
                  }
                  if (state.showCodeCheck) {
                    return Padding(
                      padding: kPaddH20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reset Password',
                            textAlign: TextAlign.left,
                            style: kAppIntro,
                          ),
                          kGap4,
                          const Text(
                            'Enter the code sent to your email.',
                            style: kAppIntroSubtitle,
                          ),
                          kGap40,
                          CustomInputField(
                            hintText: "Verification Code",
                            onChanged: (value) {},
                            controller: _controller,
                            keyboardType: TextInputType.number,
                          ),
                          kGap12,
                          if (state.status == FormzSubmissionStatus.inProgress)
                            const LoadingButton()
                          else
                            ElevatedButton(
                              onPressed: () {
                                context.read<ForgotPasswordBloc>().add(
                                    CheckEmailVerificationCode(
                                        _controller.text));
                                // empty the controller
                                _controller.clear();
                              },
                              style: kElevatedButtonCommonStyle,
                              child: const Text('Verify Code'),
                            ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: kPaddH20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Forgot Password',
                          textAlign: TextAlign.left,
                          style: kAppIntro,
                        ),
                        kGap4,
                        const Text(
                          'Enter your email address and we will send you a code to enter.',
                          style: kAppIntroSubtitle,
                        ),
                        kGap40,
                        CustomInputField(
                          hintText: "Email",
                          onChanged: (value) {
                            context
                                .read<ForgotPasswordBloc>()
                                .add(EmailChanged(value));
                          },
                          errorText: state.email.isValid
                              ? null
                              : state.email.value.isNotEmpty
                                  ? 'Invalid Email'
                                  : null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        kGap12,
                        // send email verification code
                        if (state.status == FormzSubmissionStatus.inProgress)
                          const LoadingButton()
                        else
                          ElevatedButton(
                            onPressed: state.isValid
                                ? () {
                                    context
                                        .read<ForgotPasswordBloc>()
                                        .add(const SendEmailVerification());
                                  }
                                : null,
                            style: kElevatedButtonCommonStyle,
                            child: const Text('Send Verification Code'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
