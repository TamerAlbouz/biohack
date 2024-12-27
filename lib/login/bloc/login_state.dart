part of 'login_bloc.dart';

final class LoginState extends Equatable {
  const LoginState(
      {this.signInEmail = const Email.pure(),
      this.signInPassword = const Password.pure(),
      this.status = FormzSubmissionStatus.initial,
      this.isValid = false,
      this.errorMessage});

  final Email signInEmail;
  final Password signInPassword;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        signInEmail,
        signInPassword,
        status,
        isValid,
        errorMessage,
      ];

  LoginState copyWith(
      {Email? signInEmail,
      Password? signInPassword,
      FormzSubmissionStatus? status,
      bool? isValid,
      String? errorMessage}) {
    return LoginState(
      signInEmail: signInEmail ?? this.signInEmail,
      signInPassword: signInPassword ?? this.signInPassword,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
