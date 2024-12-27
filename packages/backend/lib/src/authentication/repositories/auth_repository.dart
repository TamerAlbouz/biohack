import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../backend.dart';

/// Repository which manages user authentication.
@LazySingleton(as: IAuthenticationRepository)
class AuthenticationRepository implements IAuthenticationRepository {
  /// {@macro authentication_repository}
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthenticationRepository(this._firebaseAuth, this._googleSignIn);

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

  /// Delete the currently authenticated user.
  ///
  /// Throws a [Exception] if an exception occurs.
  @override
  Future<void> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } catch (_) {
      throw Exception('Unable to delete user');
    }
  }

  /// Returns the current user.
  /// Defaults to [User.empty] if there is no user.
  @override
  User get currentUser {
    return _firebaseAuth.currentUser?.toUser ?? User.empty;
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
  Future<void> signUp({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email right after sign up
      await userCredential.user?.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
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
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (e) {
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
    } catch (_) {
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
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }

  /// Sends a password reset email to the user with the provided [email].
  ///
  /// Throws a [SendResetPasswordException] if an exception occurs.
  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SendResetPasswordException(e.code);
    } catch (_) {
      throw SendResetPasswordException(
          "An error occurred while sending the password reset email.");
    }
  }

  /// Resets the password with the provided [code] and [password].
  ///
  /// Throws a [ResetPasswordException] if an exception occurs.
  @override
  Future<void> confirmResetPassword(
      {required String code, required String password}) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
          code: code, newPassword: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ResetPasswordException(e.code);
    } catch (_) {
      throw ResetPasswordException(
          "An error occurred while resetting the password.");
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
