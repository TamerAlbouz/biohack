import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:medtalk/common/widgets/logo_widget.dart';
import 'package:medtalk/styles/sizes.dart';

import '../../../styles/font.dart';
import '../cubit/login_cubit.dart';
import '../widgets/google_sign_button_widget.dart';
import '../widgets/guest_login_widget.dart';
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
      resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (_) => LoginCubit(context.read<IAuthenticationRepository>()),
        child: LoginForm(tabController: _tabController),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final TabController tabController;

  const LoginForm({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
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
          context.read<LoginCubit>().resetStatus();
        }
      },
      child: Padding(
        padding: kPaddL42R42T42,
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
                  controller: tabController,
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      _SignIn(),
                      _SignUp(),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'Or',
                  style: TextStyle(
                    fontFamily: Font.family,
                    color: Colors.grey,
                    fontSize: Font.medium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                kGap14,
                GoogleLoginButton(
                  onPressed: () {
                    context.read<LoginCubit>().logInWithGoogle();
                  },
                ),
                kGap14,
                SignInAsGuest(
                  onPressed: () =>
                      context.read<LoginCubit>().logInAnonymously(),
                ),
                kGap14,
              ],
            ),
          ],
        ),
      ),
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
              (LoginCubit cubit) => cubit.state.signUpEmail.displayError,
            ),
            onChanged: (email) =>
                context.read<LoginCubit>().signUpEmailChanged(email),
          ),
          kGap14,
          SignUpPasswordInput(
            displayError: context.select(
              (LoginCubit cubit) => cubit.state.signUpPassword.displayError,
            ),
            onChanged: (password) =>
                context.read<LoginCubit>().signUpPasswordChanged(password),
          ),
          kGap14,
          SignUpConfirmPasswordInput(
            emptyInput: context.select(
              (LoginCubit cubit) => cubit.state.signUpConfirmPassword.isEmpty,
            ),
            isValid: context.select(
              (LoginCubit cubit) => cubit.state.isValid,
            ),
            onChanged: (password) => context
                .read<LoginCubit>()
                .signUpConfirmPasswordChanged(password),
          ),
          kGap14,
          SignUpButton(
            status: context.select(
              (LoginCubit cubit) => cubit.state.status,
            ),
            isValid: context.select(
              (LoginCubit cubit) => cubit.state.isValid,
            ),
            onPressed: () => context.read<LoginCubit>().signUpWithCredential(),
          ),
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
                context.read<LoginCubit>().signInEmailChanged(email),
            displayError: context.select(
              (LoginCubit cubit) => cubit.state.signInEmail.displayError,
            ),
          ),
          kGap14,
          SignInPasswordInput(
            onChanged: (password) =>
                context.read<LoginCubit>().signInPasswordChanged(password),
            displayError: context.select(
              (LoginCubit cubit) => cubit.state.signInPassword.displayError,
            ),
          ),
          kGap14,
          SignInButton(
            status: context.select(
              (LoginCubit cubit) => cubit.state.status,
            ),
            isValid: context.select(
              (LoginCubit cubit) => cubit.state.isValid,
            ),
            onPressed: () => context.read<LoginCubit>().logInWithCredentials(),
          ),
          kGap14,
        ],
      ),
    );
  }
}
