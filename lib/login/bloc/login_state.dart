part of 'login_bloc.dart';

final class LoginState extends Equatable {
  const LoginState(
      {this.signInEmail = const Email.pure(),
      this.signInPassword = const Password.pure(),
      this.signUpEmail = const Email.pure(),
      this.signUpPassword = const Password.pure(),
      this.passwordMatch = false,
      this.signUpConfirmPassword = "",
      this.status = FormzSubmissionStatus.initial,
      this.requiresEmailVerification = false,
      this.isSignUp = false,
      this.isValid = false,
      this.errorMessage});

  final Email signInEmail;
  final bool requiresEmailVerification;
  final Password signInPassword;
  final bool isSignUp;
  final Email signUpEmail;
  final bool passwordMatch;
  final Password signUpPassword;
  final String signUpConfirmPassword;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        signInEmail,
        signInPassword,
        signUpEmail,
        signUpPassword,
        isSignUp,
        passwordMatch,
        signUpConfirmPassword,
        status,
        isValid,
        errorMessage,
        requiresEmailVerification
      ];

  LoginState copyWith(
      {Email? signInEmail,
      Password? signInPassword,
      Email? signUpEmail,
      bool? isSignUp,
      bool? passwordMatch,
      Password? signUpPassword,
      String? signUpConfirmPassword,
      FormzSubmissionStatus? status,
      bool? isValid,
      String? errorMessage,
      bool? requiresEmailVerification}) {
    return LoginState(
      isSignUp: isSignUp ?? this.isSignUp,
      signInEmail: signInEmail ?? this.signInEmail,
      signInPassword: signInPassword ?? this.signInPassword,
      passwordMatch: passwordMatch ?? this.passwordMatch,
      signUpEmail: signUpEmail ?? this.signUpEmail,
      signUpPassword: signUpPassword ?? this.signUpPassword,
      signUpConfirmPassword:
          signUpConfirmPassword ?? this.signUpConfirmPassword,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
