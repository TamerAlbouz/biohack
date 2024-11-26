import 'dart:async';

import 'package:backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:medtalk/common/widgets/logo_widget.dart';
import 'package:medtalk/login/bloc/login_bloc.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../app/bloc/auth/route_bloc.dart';
import '../../styles/colors.dart';
import '../widgets/sign_in_button_widget.dart';
import '../widgets/sign_in_email_widget.dart';
import '../widgets/sign_in_password_widget.dart';
import '../widgets/sign_up_button_widget.dart';
import '../widgets/sign_up_email_widget.dart';
import '../widgets/sign_up_password_confirm_widget.dart';
import '../widgets/sign_up_password_widget.dart';

class LoginPatientScreen extends StatefulWidget {
  const LoginPatientScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const LoginPatientScreen());

  @override
  State<LoginPatientScreen> createState() => _LoginPatientScreenState();
}

class _LoginPatientScreenState extends State<LoginPatientScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocProvider(
          create: (_) => LoginBloc(
                getIt<IAuthenticationRepository>(),
                getIt<IEncryptionRepository>(),
                getIt<ISecureEncryptionStorage>(),
              ),
          child: LoginForm(tabController: _tabController)),
    );
  }
}

class LoginForm extends StatefulWidget {
  final TabController tabController;

  const LoginForm({
    super.key,
    required this.tabController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  Timer? _timer;
  bool _showResendButton = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isSuccess && !state.requiresEmailVerification) {
          _timer?.cancel();
          // check if request is from login or sign up
          if (state.isSignUp) {
            context.read<RouteBloc>().add(AuthSubscriptionRequested());
          }
        }

        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                showCloseIcon: true,
                // allow overlaying over other widgets
                content: Text(state.errorMessage ?? 'Authentication Failure'),
              ),
            );

          // reset the status to initial
          context.read<LoginBloc>().add(const ResetStatus());
        }

        if (state.requiresEmailVerification) {
          _timer ??= Timer.periodic(
            const Duration(seconds: 5),
            (_) =>
                context.read<LoginBloc>().add(const CheckEmailVerification()),
          );
        }
      },
      builder: (context, state) {
        if (state.requiresEmailVerification) {
          return Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: kPaddL42R42,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LogoWidget(),
                      kGap28,
                      const Text(
                        'Verify Your Email',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      kGap14,
                      Text(
                        'We\'ve sent a verification link to ${context.select((LoginBloc cubit) => cubit.state.signUpEmail.value == "" ? cubit.state.signInEmail.value : cubit.state.signUpEmail.value)}',
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Click the link in the email to verify your account.',
                        textAlign: TextAlign.center,
                      ),
                      kGap28,
                      if (_showResendButton) ...[
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  context
                                      .read<LoginBloc>()
                                      .add(const ResendVerificationEmail());
                                  setState(() => _showResendButton = false);
                                  Future.delayed(
                                    const Duration(minutes: 1),
                                    () => setState(
                                        () => _showResendButton = true),
                                  );
                                },
                          child: const Text('Resend Verification Email'),
                        ),
                      ] else ...[
                        const Text(
                          'Verification email sent. Please wait 1 minute before requesting another.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                      kGap14,
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() => _isLoading = true);
                                context
                                    .read<RouteBloc>()
                                    .add(AuthLogoutPressed());
                              },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _isLoading
                                ? MyColors.buttonRed.withOpacity(0.5)
                                : MyColors.buttonRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        }

        return SafeArea(
          child: Padding(
            padding: kPaddL42R42,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const LogoWidget(),
                          kGap28,
                          TabBar(
                            controller: widget.tabController,
                            tabs: const [
                              Tab(text: 'Sign In'),
                              Tab(text: 'Sign Up'),
                            ],
                          ),
                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              controller: widget.tabController,
                              children: [
                                _SignIn(),
                                _SignUp(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          kGap14,
          SignUpEmailInput(
            displayError: context.select(
              (LoginBloc cubit) => cubit.state.signUpEmail.displayError,
            ),
            onChanged: (email) =>
                context.read<LoginBloc>().add(SignUpEmailChanged(email)),
          ),
          kGap14,
          SignUpPasswordInput(
            displayError: context.select(
              (LoginBloc cubit) => cubit.state.signUpPassword.displayError,
            ),
            onChanged: (password) =>
                context.read<LoginBloc>().add(SignUpPasswordChanged(password)),
          ),
          kGap14,
          SignUpConfirmPasswordInput(
            emptyInput: context.select(
              (LoginBloc cubit) => cubit.state.signUpConfirmPassword.isEmpty,
            ),
            passwordMatch: context.select(
              (LoginBloc cubit) => cubit.state.passwordMatch,
            ),
            onChanged: (password) => context
                .read<LoginBloc>()
                .add(SignUpConfirmPasswordChanged(password)),
          ),
          kGap14,
          SignUpButton(
              status: context.select(
                (LoginBloc cubit) => cubit.state.status,
              ),
              isValid: context.select(
                (LoginBloc cubit) => cubit.state.isValid,
              ),
              onPressed: () {
                context.read<LoginBloc>().add(const SignUpWithCredential());
              }),
        ],
      ),
    );
  }
}

class _SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          kGap14,
          SignInEmailInput(
            onChanged: (email) =>
                context.read<LoginBloc>().add(SignInEmailChanged(email)),
            displayError: context.select(
              (LoginBloc cubit) => cubit.state.signInEmail.displayError,
            ),
          ),
          kGap14,
          SignInPasswordInput(
            onChanged: (password) =>
                context.read<LoginBloc>().add(SignInPasswordChanged(password)),
            displayError: context.select(
              (LoginBloc cubit) => cubit.state.signInPassword.displayError,
            ),
          ),
          kGap14,
          SignInButton(
              status: context.select(
                (LoginBloc cubit) => cubit.state.status,
              ),
              isValid: context.select(
                (LoginBloc cubit) => cubit.state.isValid,
              ),
              onPressed: () {
                context.read<LoginBloc>().add(const LogInWithCredentials());
              }),
          kGap14,
        ],
      ),
    );
  }
}
