import 'package:backend/backend.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:medtalk/login/bloc/login_bloc.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../app/bloc/auth/route_bloc.dart';
import '../../common/globals/globals.dart';
import '../../common/widgets/custom_input_field.dart';
import '../../common/widgets/random_hexagons.dart';
import '../../doctor/signup/screens/verification_requirements_screen.dart';
import '../../patient/signup/screens/signup_patient_screen.dart';
import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/styles/button.dart';
import '../../styles/styles/text.dart';
import '../widgets/sign_in_button_widget.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const LoginScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) => LoginBloc(
        getIt<IAuthenticationRepository>(),
        getIt<IEncryptionRepository>(),
        getIt<ISecureStorageRepository>(),
        getIt<ICryptoRepository>(),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const HexagonPatternBox(
              width: double.infinity,
              height: 180,
            ),
            kGap20,
            BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state.status.isSuccess) {
                  // check if request is from login or sign up
                  context.read<RouteBloc>().add(AuthSubscriptionRequested());
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
                  context.read<LoginBloc>().add(const ResetStatus());
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: kPaddH20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign In',
                        style: kAppIntro,
                      ),
                      kGap4,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text:
                                  'You\'re logging in as a ${context.read<RouteBloc>().getRole()}. ',
                              style: kAppIntroSubtitle,
                              children: [
                                TextSpan(
                                  text: 'Switch?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.primary,
                                    decoration: TextDecoration.underline,
                                    fontSize: Font.small,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Handle "Switch?" click event
                                      context
                                          .read<RouteBloc>()
                                          .add(SwitchRoles());
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      kGap28,
                      CustomInputField(
                        key: const Key('loginForm_signInEmailInput_textField'),
                        hintText: "Email",
                        controller: _emailController,
                        leadingWidget: _emailController.text.isNotEmpty
                            ? const Icon(Icons.email, color: MyColors.primary)
                            : const Icon(Icons.email_outlined,
                                color: MyColors.primary),
                        onChanged: (email) => context
                            .read<LoginBloc>()
                            .add(SignInEmailChanged(email)),
                        keyboardType: TextInputType.emailAddress,
                        errorText: context.select(
                                  (LoginBloc cubit) =>
                                      cubit.state.signInEmail.displayError,
                                ) !=
                                null
                            ? "Invalid Email"
                            : null,
                      ),
                      kGap8,
                      CustomInputField(
                        key: const Key(
                            'loginForm_signInPasswordInput_textField'),
                        hintText: "Password",
                        controller: _passwordController,
                        onChanged: (password) => context
                            .read<LoginBloc>()
                            .add(SignInPasswordChanged(password)),
                        showPasswordToggle: true,
                        obscureText: true,
                        leadingWidget: _passwordController.text.isNotEmpty
                            ? const Icon(Icons.lock, color: MyColors.primary)
                            : const Icon(Icons.lock_outline,
                                color: MyColors.primary),
                        keyboardType: TextInputType.visiblePassword,
                        errorText: context.select(
                                  (LoginBloc cubit) =>
                                      cubit.state.signInPassword.displayError,
                                ) !=
                                null
                            ? "Invalid Password"
                            : null,
                      ),
                      // forgot password text button
                      Padding(
                        padding: kPadd0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // push forgot password screen
                                AppGlobal.navigatorKey.currentState?.push<void>(
                                  ForgotPasswordScreen.route(),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              // underline
                              child: const Text('Forgot password?',
                                  style: TextStyle(
                                      fontFamily: Font.family,
                                      fontWeight: FontWeight.normal,
                                      fontSize: Font.small)),
                            ),
                          ],
                        ),
                      ),
                      kGap60,
                      SignInButton(
                          status: context.select(
                            (LoginBloc cubit) => cubit.state.status,
                          ),
                          isValid: context.select(
                            (LoginBloc cubit) => cubit.state.isValid,
                          ),
                          onPressed: () {
                            context
                                .read<LoginBloc>()
                                .add(const LogInWithCredentials());
                          }),
                      kGap4,
                      const _OrDivider(),
                      kGap4,
                      // New Create an account button
                      ElevatedButton(
                        onPressed: () {
                          // depending on the role, push the user to the right screen
                          if (context.read<RouteBloc>().getRole() ==
                              Role.doctor.name) {
                            AppGlobal.navigatorKey.currentState?.push<void>(
                              VerificationRequirementsScreen.route(),
                            );
                          } else {
                            AppGlobal.navigatorKey.currentState?.push<void>(
                              SignUpPatientScreen.route(),
                            );
                          }
                        },
                        style: kElevatedButtonCommonStyleOutline,
                        child: const Text(
                          'Create an account',
                        ),
                      ),
                      // sign in as guest text button
                      kGap14,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // push intro to patient screen
                              // AppGlobal.navigatorKey.currentState?.push<void>(
                              //   NavigationPatientScreen.route(),
                              // );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Sign in as guest',
                                style: TextStyle(
                                    fontFamily: Font.family,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Font.smallExtra,
                                    decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            thickness: 1.0,
            color: MyColors.softStroke,
            height: 0,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 3),
          child: Text(
            'or',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: Font.smallExtra,
              color: MyColors.textGrey,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1.0,
            color: MyColors.softStroke,
            height: 0,
          ),
        ),
      ],
    );
  }
}
