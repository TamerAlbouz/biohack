import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
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
        create: (_) => LoginCubit(context.read<AuthenticationRepository>()),
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
        }
      },
      child: Column(
        children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding: kPaddH42,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _GreetingText(),
                  kGap10,
                  _LineDivider(),
                  kGap14,
                  TabBar(
                    controller: tabController,
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _SignIn(),
                        _SignUp(),
                      ],
                    ),
                  ),
                  kGap14,
                  const Text('Or',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: Font.medium,
                          fontWeight: FontWeight.bold)),
                  kGap14,
                  _GoogleLoginButton(),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/Cool-Waves-medium.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: _SignInAsGuest(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmailInput(),
        kGap14,
        _PasswordInput(),
        kGap14,
        _SignInButton(),
      ],
    );
  }
}

class _SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmailInput(),
        kGap14,
        _PasswordInput(),
        kGap14,
        _SignInButton(),
      ],
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

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayError = context.select(
      (LoginCubit cubit) => cubit.state.email.displayError,
    );

    return InputField(
      key: const Key('loginForm_emailInput_textField'),
      hintText: "Email",
      onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
      keyboardType: TextInputType.emailAddress,
      errorText: displayError != null ? "Invalid Email" : null,
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final displayError = context.select(
      (LoginCubit cubit) => cubit.state.password.displayError,
    );

    return InputField(
      key: const Key('loginForm_passwordInput_textField'),
      hintText: "Password",
      onChanged: (password) =>
          context.read<LoginCubit>().passwordChanged(password),
      keyboardType: TextInputType.visiblePassword,
      errorText: displayError != null ? "Invalid Password" : null,
    );
  }
}

class _LineDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Colors.grey,
      height: 20,
      thickness: 2,
      indent: 0,
      endIndent: 0,
    );
  }
}

class _GreetingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPaddH14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
            text: 'Hello,\n',
            style: Theme.of(context).textTheme.titleLarge,
            children: <TextSpan>[
              TextSpan(
                text: 'How\'re you doing today?',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
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
        backgroundColor: MyColors.buttonBlack,
      ),
      child: const Icon(FontAwesomeIcons.google,
          color: MyColors.buttonHint, size: 28),
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

// class _SignUpButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return TextButton(
//       key: const Key('loginForm_createAccount_flatButton'),
//       onPressed: () => Navigator.of(context).push<void>(SignUpPage.route()),
//       child: Text(
//         'CREATE ACCOUNT',
//         style: TextStyle(color: theme.primaryColor),
//       ),
//     );
//   }
// }
