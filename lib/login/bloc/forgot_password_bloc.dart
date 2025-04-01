import 'dart:typed_data';

import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:formz_inputs/formz_inputs.dart';
import 'package:p_logger/p_logger.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc(
    this._authenticationRepository,
    this._encryptionRepository,
    this._crypto,
    this._rateLimiter,
  ) : super(const ForgotPasswordState()) {
    on<SendEmailVerification>(_sendEmailVerification);
    on<ResetPasswordWithCode>(_resetPasswordWithCode);
    on<PasswordChanged>(_passwordChanged);
    on<ConfirmPasswordChanged>(_confirmPasswordChanged);
    on<EmailChanged>(_emailChanged);
    on<RecoveryCodeChanged>(_recoveryCodeChanged);
    on<CheckEmailVerificationCode>(_checkEmailVerificationCode);
  }

  final IAuthenticationRepository _authenticationRepository;
  final IEncryptionRepository _encryptionRepository;
  final ICryptoRepository _crypto;
  final IRateLimiter _rateLimiter;

  void _recoveryCodeChanged(
      RecoveryCodeChanged event, Emitter<ForgotPasswordState> emit) {
    emit(state.copyWith(recoveryCode: event.recoveryCode));
  }

  void _passwordChanged(
      PasswordChanged event, Emitter<ForgotPasswordState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([password]),
      ),
    );
  }

  void _confirmPasswordChanged(
      ConfirmPasswordChanged event, Emitter<ForgotPasswordState> emit) {
    // check that the password and confirm password match
    if (state.password.value != event.confirmPassword) {
      emit(state.copyWith(
        confirmPassword: event.confirmPassword,
        isValid: false,
      ));
      return;
    }

    emit(
      state.copyWith(
        confirmPassword: event.confirmPassword,
        isValid: Formz.validate([state.password]) &&
            state.password.value == event.confirmPassword,
      ),
    );
  }

  void _emailChanged(EmailChanged event, Emitter<ForgotPasswordState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email]),
      ),
    );
  }

  Future<void> _checkEmailVerificationCode(CheckEmailVerificationCode event,
      Emitter<ForgotPasswordState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      // add a rate limiter to prevent spamming
      final RateLimitResult rateLimitCheck = await _rateLimiter.checkRateLimit(
        key: 'verify_reset_code_${state.email.value}',
        maxAttempts: 5, // 5 attempts allowed
        windowDuration: const Duration(hours: 1), // within 1 hour
      );

      if (!rateLimitCheck.allowed) {
        final int minutesRemaining = rateLimitCheck.timeRemaining.inMinutes;
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage:
              'Too many attempts. Please try again in $minutesRemaining minutes',
        ));
        return;
      }

      await _rateLimiter.recordAttempt(
        key: 'verify_reset_code_${state.email.value}',
      );

      var result = await _authenticationRepository.verifyResetCode(
          email: state.email.value, code: event.verificationCode);

      if (!result) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Invalid verification code',
        ));
        return;
      }

      // reset rate limiting on success, also reset send email rate limiting
      await _rateLimiter.reset(key: 'send_password_reset_${state.email.value}');
      await _rateLimiter.reset(key: 'verify_reset_code_${state.email.value}');

      emit(state.copyWith(
        isValid: false,
        emailVerificationCode: event.verificationCode,
        status: FormzSubmissionStatus.success,
        showResetPassword: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to verify email',
      ));
    }
  }

  Future<void> _sendEmailVerification(
      SendEmailVerification event, Emitter<ForgotPasswordState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      logger.i('Beginning password reset for ${state.email.value}');
      // add a rate limiter to prevent spamming
      final RateLimitResult rateLimitCheck = await _rateLimiter.checkRateLimit(
        key: 'send_password_reset_${state.email.value}',
        maxAttempts: 5, // 5 attempts allowed
        windowDuration: const Duration(hours: 1), // within 1 hour
      );

      if (!rateLimitCheck.allowed) {
        logger.i(
            'Too many attempts. Please try again in ${rateLimitCheck.timeRemaining.inMinutes} minutes');
        final int minutesRemaining = rateLimitCheck.timeRemaining.inMinutes;
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage:
              'Too many attempts. Please try again in $minutesRemaining minutes',
        ));
        return;
      }

      logger.i('Recording attempt to send password reset email');
      await _rateLimiter.recordAttempt(
        key: 'send_password_reset_${state.email.value}',
      );

      logger.i('Sending password reset email to ${state.email.value}');
      await _authenticationRepository.sendPasswordResetEmail(
          email: state.email.value);

      logger.i('Password reset email sent to ${state.email.value}');
      emit(state.copyWith(
          status: FormzSubmissionStatus.success, showCodeCheck: true));
    } catch (e) {
      logger.e('Failed to send verification email: $e');
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to send verification email',
      ));
    }
  }

  Future<void> _resetPasswordWithCode(
      ResetPasswordWithCode event, Emitter<ForgotPasswordState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      logger.i('Resetting password for ${state.email.value}');
      // Check rate limiting first
      final RateLimitResult rateLimitCheck = await _rateLimiter.checkRateLimit(
        key: 'reset_password_${state.email.value}',
        maxAttempts: 5, // 5 attempts allowed
        windowDuration: const Duration(hours: 1), // within 1 hour
      );

      if (!rateLimitCheck.allowed) {
        final int minutesRemaining = rateLimitCheck.timeRemaining.inMinutes;
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage:
              'Too many attempts. Please try again in $minutesRemaining minutes',
        ));
        return;
      }

      await _rateLimiter.recordAttempt(
        key: 'reset_password_${state.email.value}',
      );

      // Get uid of email
      final uid = await _authenticationRepository.getUidFromEmail(
          email: state.email.value);

      // Step 2: Get encrypted data
      final encryptedData = await _encryptionRepository.getEncryptedData(uid);

      if (encryptedData == null) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'User data not found',
        ));
        return;
      }

      logger.i('Retrieved encrypted data for ${state.email.value}');
      // Step 3: Try to decrypt private key using recovery code
      try {
        // Generate key using recovery code instead of password
        final Uint8List recoveryKey = await _crypto.generateKey(
          state.recoveryCode,
          encryptedData[1].randomSaltOne,
        );

        // Attempt to decrypt - if this fails, the recovery code is wrong
        var privateKey = _crypto.symmetricDecrypt(
          recoveryKey,
          Uint8List.fromList(encryptedData[1].randomSaltTwo.codeUnits),
          Uint8List.fromList(encryptedData[1].encryptedPrivateKey.codeUnits),
        );

        // Reset password and re-encrypt
        await _authenticationRepository.resetPasswordWithCode(
          email: state.email.value,
          code: state.emailVerificationCode!,
          newPassword: state.password.value,
        );

        // Generate new encryption key with new password
        final Uint8List newPbkdfKey = await _crypto.generateKey(
          state.password.value,
          encryptedData[0].randomSaltOne,
        );

        // Generate new recovery key with new password
        final Uint8List newRecoveryKey = await _crypto.generateKey(
          event.newRecoveryCode,
          encryptedData[1].randomSaltOne,
        );

        // Re-encrypt private key with new password
        final Uint8List reEncryptedPrivateKey = _crypto.symmetricEncrypt(
          newPbkdfKey,
          Uint8List.fromList(encryptedData[0].randomSaltTwo.codeUnits),
          privateKey,
        );

        // encrypt another copy of the private key with the new recovery code
        final Uint8List reEncryptedPrivateKeyWithRecoveryCode =
            _crypto.symmetricEncrypt(
          newRecoveryKey,
          Uint8List.fromList(encryptedData[1].randomSaltTwo.codeUnits),
          privateKey,
        );

        // Save the new encrypted private key
        final PrivateKeyEncryptionResult newEncryptedData =
            PrivateKeyEncryptionResult(
          publicKey: encryptedData[0].publicKey,
          encryptedPrivateKey: String.fromCharCodes(reEncryptedPrivateKey),
          randomSaltOne: encryptedData[0].randomSaltOne,
          randomSaltTwo: encryptedData[0].randomSaltTwo,
        );

        // Save the new encrypted private key with the new recovery code
        final PrivateKeyEncryptionResult newEncryptedDataWithRecoveryCode =
            PrivateKeyEncryptionResult(
          publicKey: encryptedData[1].publicKey,
          encryptedPrivateKey:
              String.fromCharCodes(reEncryptedPrivateKeyWithRecoveryCode),
          randomSaltOne: encryptedData[1].randomSaltOne,
          randomSaltTwo: encryptedData[1].randomSaltTwo,
        );

        await _encryptionRepository.updateEncryptionData(uid, [
          newEncryptedData,
          newEncryptedDataWithRecoveryCode,
        ]);

        // Reset rate limiting on success
        await _rateLimiter.reset(key: 'reset_password_${state.email.value}');

        logger.i('Password reset for ${state.email.value}');
        emit(state.copyWith(
            status: FormzSubmissionStatus.success,
            isValid: true,
            showResetPassword: false,
            showRecovery: true));
      } catch (e) {
        logger.e('Failed to reset password: $e');
        // Record failed attempt
        await _rateLimiter.recordAttempt(
          key: 'reset_password_${state.email.value}',
        );

        // If decryption fails, recovery code is invalid
        emit(state.copyWith(
          isValid: false,
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Invalid recovery code',
        ));
        return;
      }
    } on SendResetPasswordException catch (e) {
      logger.e('Password reset failed: $e');
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'The email address is invalid',
      ));
    } catch (e) {
      logger.e('Password reset failed: $e');
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to reset password',
      ));
    }
  }
}
