part of 'login_cubit.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.signInEmail = const Email.pure(),
    this.signInPassword = const Password.pure(),
    this.signUpEmail = const Email.pure(),
    this.signUpPassword = const Password.pure(),
    this.signUpConfirmPassword = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  final Email signInEmail;
  final Password signInPassword;
  final Email signUpEmail;
  final Password signUpPassword;
  final Password signUpConfirmPassword;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        signInEmail,
        signInPassword,
        signUpEmail,
        signUpPassword,
        signUpConfirmPassword,
        status,
        isValid,
        errorMessage
      ];

  LoginState copyWith({
    Email? signInEmail,
    Password? signInPassword,
    Email? signUpEmail,
    Password? signUpPassword,
    Password? signUpConfirmPassword,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return LoginState(
      signInEmail: signInEmail ?? this.signInEmail,
      signInPassword: signInPassword ?? this.signInPassword,
      signUpEmail: signUpEmail ?? this.signUpEmail,
      signUpPassword: signUpPassword ?? this.signUpPassword,
      signUpConfirmPassword:
          signUpConfirmPassword ?? this.signUpConfirmPassword,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
