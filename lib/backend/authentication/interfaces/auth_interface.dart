import 'package:medtalk/backend/user/models/user.dart';

abstract class IAuthenticationRepository {
  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user;

  /// Gets the uid of the provided email
  ///
  /// Throws a [Exception] if an exception occurs.
  Future<String> getUidFromEmail({required String email});

  /// Delete the currently authenticated user.
  ///
  /// Throws a [Exception] if an exception occurs.
  Future<void> deleteUser();

  /// Returns the current user.
  /// Defaults to [User.empty] if there is no user.
  User get currentUser;

  /// Sets custom user data for the current user
  Future<void> updateProfile(User user);

  /// Returns if the user is anonymous.
  /// Defaults to false if there is no user.
  bool get isAnonymous;

  Future<bool> wasDeleted();

  Future<void> sendEmailVerification();

  Future<bool> isEmailVerified();

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> createUserWithEmailAndPassword(
      {required String email, required String password});

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs in anonymously.
  ///
  /// Throws a [LogInAnonymouslyFailure] if an exception occurs.
  Future<void> logInAnonymously();

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut();

  /// Sends a password reset email to the user with the provided [email].
  ///
  /// Throws a [SendResetPasswordException] if an exception occurs.
  Future<void> sendPasswordResetEmail({required String email});

  /// Verifies the email with the provided [code].
  ///
  /// Returns false if the code is invalid or an exception occurs.
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  });

  /// Resets the password with the provided [code] and [password].
  ///
  /// Throws a [ResetPasswordException] if an exception occurs.
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  });
}
