import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
import 'package:medtalk/common/widgets/custom_password_field.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/text.dart';

import '../../styles/colors.dart';
import '../../styles/font.dart';
import '../../styles/styles/button.dart';
import '../cubit/login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const LoginScreen());

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
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
        create: (_) => LoginCubit(context.read<IAuthenticationRepository>(),
            context.read<IPatientInterface>()),
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
                SvgPicture.asset(
                  'assets/svgs/Logo.svg',
                  semanticsLabel: "Logo",
                  width: 70,
                  height: 70,
                ),
                kGap5,
                _GreetingText(),
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
                _GoogleLoginButton(),
                kGap14,
                _SignInAsGuest(),
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
          _SignUpEmailInput(),
          kGap14,
          _SignUpPasswordInput(),
          kGap14,
          _SignUpConfirmPasswordInput(),
          kGap14,
          _SignUpButton(),
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
          _SignInEmailInput(),
          kGap14,
          _SignInPasswordInput(),
          kGap14,
          _SignInButton(),
          kGap14,
        ],
      ),
    );
  }
}

class _SignInAsGuest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<LoginCubit>().logInAnonymously(),
      child: const Text(
        'Sign in as a Guest',
        style: TextStyle(
          // underline
          fontFamily: Font.family,
          color: MyColors.textWhite,
          fontSize: Font.small,
          decoration: TextDecoration.underline,
          decorationColor: MyColors.textWhite,
          decorationThickness: 1.5,
        ),
      ),
    );
  }
}

class _SignInEmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayError = context.select(
      (LoginCubit cubit) => cubit.state.signInEmail.displayError,
    );

    final emptyInput = context.select(
      (LoginCubit cubit) => cubit.state.signInEmail.value.isEmpty,
    );

    return InputField(
      key: const Key('loginForm_signInEmailInput_textField'),
      hintText: "Email",
      onChanged: (email) =>
          context.read<LoginCubit>().signInEmailChanged(email),
      keyboardType: TextInputType.emailAddress,
      errorText: displayError != null && !emptyInput ? "Invalid Email" : null,
    );
  }
}

class _SignUpEmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayError = context.select(
      (LoginCubit cubit) => cubit.state.signUpEmail.displayError,
    );

    final emptyInput = context.select(
      (LoginCubit cubit) => cubit.state.signUpEmail.value.isEmpty,
    );

    return InputField(
      key: const Key('loginForm_signUpEmailInput_textField'),
      hintText: "Email",
      onChanged: (email) =>
          context.read<LoginCubit>().signUpEmailChanged(email),
      keyboardType: TextInputType.emailAddress,
      errorText: displayError != null && !emptyInput ? "Invalid Email" : null,
    );
  }
}

class _SignInPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayError = context.select(
      (LoginCubit cubit) => cubit.state.signInPassword.displayError,
    );

    final emptyInput = context.select(
      (LoginCubit cubit) => cubit.state.signInPassword.value.isEmpty,
    );

    return PasswordInputField(
      key: const Key('loginForm_signInPasswordInput_textField'),
      hintText: "Password",
      onChanged: (password) =>
          context.read<LoginCubit>().signInPasswordChanged(password),
      keyboardType: TextInputType.visiblePassword,
      errorText:
          displayError != null && !emptyInput ? "Invalid Password" : null,
    );
  }
}

class _SignUpPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayError = context.select(
      (LoginCubit cubit) => cubit.state.signUpPassword.displayError,
    );

    final emptyInput = context.select(
      (LoginCubit cubit) => cubit.state.signUpPassword.value.isEmpty,
    );

    return PasswordInputField(
      key: const Key('loginForm_signUpPasswordInput_textField'),
      hintText: "Password",
      onChanged: (password) =>
          context.read<LoginCubit>().signUpPasswordChanged(password),
      keyboardType: TextInputType.visiblePassword,
      errorText:
          displayError != null && !emptyInput ? "Invalid Password" : null,
    );
  }
}

class _SignUpConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isValid = context.select(
      (LoginCubit cubit) => cubit.state.isValid,
    );

    final emptyInput = context.select(
      (LoginCubit cubit) => cubit.state.signUpConfirmPassword.isEmpty,
    );

    return PasswordInputField(
      key: const Key('loginForm_confirmPasswordInput_textField'),
      hintText: "Confirm Password",
      onChanged: (password) =>
          context.read<LoginCubit>().signUpConfirmPasswordChanged(password),
      keyboardType: TextInputType.visiblePassword,
      errorText: !isValid && !emptyInput ? "Passwords do not match" : null,
    );
  }
}

// class _LineDivider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Divider(
//       color: MyColors.grey,
//       height: 20,
//       thickness: 2,
//       indent: 0,
//       endIndent: 0,
//     );
//   }
// }

class _GreetingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPaddH14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
              text: TextSpan(
            text: 'BioHack',
            style: Theme.of(context).textTheme.titleLarge,
          )),
        ],
      ),
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('loginForm_googleLogin_raisedButton'),
      style: ElevatedButton.styleFrom(
        padding: kPadd10,
        shape: const CircleBorder(),
        backgroundColor: MyColors.black,
      ),
      child:
          const Icon(FontAwesomeIcons.google, color: MyColors.grey, size: 28),
      onPressed: () => context.read<LoginCubit>().logInWithGoogle(),
    );
  }
}

class _SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInProgress = context.select(
      (LoginCubit cubit) => cubit.state.status.isInProgress,
    );

    if (isInProgress) return const CircularProgressIndicator();

    final isValid = context.select(
      (LoginCubit cubit) => cubit.state.isValid,
    );

    return ElevatedButton(
      key: const Key('loginForm_continue_raisedButton'),
      style: kMainButtonStyle,
      onPressed: isValid
          ? () => context.read<LoginCubit>().logInWithCredentials()
          : null,
      child: const Text('SIGN IN', style: kButtonText),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isInProgress = context.select(
      (LoginCubit cubit) => cubit.state.status.isInProgress,
    );

    if (isInProgress) return const CircularProgressIndicator();

    final isValid = context.select(
      (LoginCubit cubit) => cubit.state.isValid,
    );

    return ElevatedButton(
      key: const Key('signUpForm_continue_raisedButton'),
      style: kMainButtonStyle,
      onPressed: isValid
          ? () => context.read<LoginCubit>().signUpWithCredential()
          : null,
      child: const Text('SIGN UP', style: kButtonText),
    );
  }
}
