import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:medtalk/backend/authentication/exceptions/auth_exception.dart';
import 'package:medtalk/backend/authentication/exceptions/reset_password_exception.dart';
import 'package:medtalk/backend/authentication/interfaces/auth_interface.dart';
import 'package:medtalk/backend/user/models/user.dart';

/// Repository which manages user authentication.
@LazySingleton(as: IAuthenticationRepository)
class AuthenticationRepository implements IAuthenticationRepository {
  /// {@macro authentication_repository}
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFunctions functions;
  final String _functionUrl =
      'https://us-central1-medtalk-aefa8.cloudfunctions.net/';
  final Logger logger;

  AuthenticationRepository(this._firebaseAuth, this.functions, this.logger);

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  @override
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      return user;
    });
  }

  /// Gets the uid of the provided email
  ///
  /// Throws a [Exception] if an exception occurs.
  @override
  Future<String> getUidFromEmail({required String email}) async {
    try {
      final uid = await functions.httpsCallable('getUidFromEmail').call({
        'email': email,
      });

      return uid.data;
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('${e.code} - ${e.message}');
      rethrow;
    } catch (exception) {
      logger.e(exception.toString());
      rethrow;
    }
  }

  /// Delete the currently authenticated user.
  ///
  /// Throws a [Exception] if an exception occurs.
  @override
  Future<void> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('${e.code} - ${e.message}');
      rethrow;
    } catch (exception) {
      logger.e(exception.toString());
      rethrow;
    }
  }

  /// Returns the current user.
  /// Uses custom user data if set, otherwise falls back to Firebase user data
  @override
  User get currentUser {
    return _firebaseAuth.currentUser?.toUser ?? User.empty;
  }

  /// Sets custom user data for the current user
  @override
  Future<void> updateProfile(User user) async {
    // Set the display name and photo URL
    await _firebaseAuth.currentUser?.updateProfile(
      displayName: user.name,
      photoURL: user.profilePictureUrl,
    );
  }

  /// Returns if the user is anonymous.
  /// Defaults to false if there is no user.
  @override
  bool get isAnonymous {
    return _firebaseAuth.currentUser?.isAnonymous ?? false;
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    } else {
      throw Exception('Unable to send verification email');
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<bool> wasDeleted() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser?.email == null;
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  @override
  Future<void> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email right after sign up
      await userCredential.user?.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('${e.code} - ${e.message}');
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (exception) {
      logger.e(exception.toString());
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  // @override
  // Future<void> logInWithGoogle() async {
  //   try {
  //     final googleUser = await _googleSignIn.signIn();
  //     final googleAuth = await googleUser!.authentication;
  //     final firebase_auth.AuthCredential credential =
  //         firebase_auth.GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     await _firebaseAuth.signInWithCredential(credential);
  //   } on firebase_auth.FirebaseAuthException catch (e) {
  //     throw LogInWithGoogleFailure.fromCode(e.code);
  //   } catch (e) {
  //     throw LogInWithGoogleFailure.fromCode(
  //         GoogleSignInAccount.kFailedToRecoverAuthError);
  //   }
  // }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  @override
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('${e.code} - ${e.message}');
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (e) {
      logger.e(e.toString());
      throw LogInWithEmailAndPasswordFailure(e.toString());
    }
  }

  /// Signs in anonymously.
  ///
  /// Throws a [LogInAnonymouslyFailure] if an exception occurs.
  @override
  Future<void> logInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } catch (e) {
      logger.e(e.toString());
      throw LogInAnonymouslyFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  @override
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
      ]);
    } catch (e) {
      logger.e(e.toString());
      throw LogOutFailure();
    }
  }

  /// Sends a password reset email to the user with the provided [email].
  ///
  /// Throws a [SendResetPasswordException] if an exception occurs.
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      // Make an HTTP POST to the onRequest function endpoint
      final response = await http.post(
        Uri.parse("$_functionUrl/generateResetCode"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // Password reset code sent successfully
          logger.i('Password reset code sent successfully');
        } else {
          // The function responded with something other than { success: true }
          logger.e('Failed to send reset code');
          throw Exception('Failed to send reset code');
        }
      } else {
        // Non-200 HTTP status code indicates an error.
        logger.e('Failed to send password reset email');
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error'] ?? 'Unknown error';
        throw Exception('Error: $errorMsg');
      }
    } catch (e) {
      logger.e(e.toString());
      // Handle or propagate the error as needed
      rethrow;
    }
  }

  @override
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_functionUrl/verifyResetCode"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        logger.e('Failed to verify reset code: ${responseData['error']}');
        return false;
      }

      logger.i('Reset code verified successfully');
      final responseData = jsonDecode(response.body);
      return responseData['success'] == true;
    } catch (e) {
      logger.e(e.toString());
      return false;
    }
  }

  /// Resets the password with the provided [code] and [password].
  ///
  /// Throws a [ResetPasswordException] if an exception occurs.
  @override
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final result = await functions.httpsCallable('updateUserPassword').call({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      });

      if (result.data['success'] == true) {
        logger.i('Password reset successfully');
      } else {
        logger.e('Failed to reset password');
        throw ResetPasswordException('Failed to reset password');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('${e.code} - ${e.message}');
      throw ResetPasswordException(e.code);
    } catch (e) {
      logger.e(e.toString());
      throw ResetPasswordException('Failed to reset password');
    }
  }
}

extension on firebase_auth.User {
  /// Maps a [firebase_auth.User] into a [User].
  User get toUser {
    return User(
      uid: uid,
      email: email ?? "guest@gmail.com",
      name: displayName,
      profilePictureUrl: photoURL,
    );
  }
}
