import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/services/employee_manager.dart';

import 'package:presence_app/utils.dart';

class Login {
  Future<int> signUp(String email, String password) async {
    if (password == '') {
      log.e('Empty password!');
      return emptyPassword;
    }
    if (!utils.isValidEmail(email)) {
      log.e('Invalid email!');
      return invalidEmail;
    }
    try {
      //

      log.d('Inside try');
      var credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.sendEmailVerification();
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.message!.contains('weak-password')) {
          log.e('The password provided is too weak: at least 6 chars required');
          return weekPassword;
        }
        if (e.message!.contains('already in use')) {
          log.e('The account already exists for that email.');
          return emailInUse;
        }
        log.e(e);
        return failure;
      }
    }
    log.d('Sign up successful');
    return success;
  }

  Future<int> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      log.d('User signed out successfully.');
      return success;
    } catch (e) {
      log.e('Error signing out: $e');
      return failure;
    }
  }

  Future<int> signIn(String email, String password) async {
    UserCredential credential;

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (!credential.user!.emailVerified) {
        log.e('Email not verified so you are signed out!');
        signOut();
        return emailNotVerified;
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.message!.contains('no user record')) {
          log.e('No user found for that email.');
          return emailNotExists;
        }
        if (e.message!.contains('too-many-requests')) {
          log.e('too many requests');
          return tooManyRequests;
        }
        if (e.message!.contains('wrong-password')) {
          log.e('Wrong password provided for that user.');
          return wrongPassword;
        }

        if (e.message!.contains('user-not-found')) {
          log.e('User not found');
          return emailNotExists;
        }

        if (e.message!.contains('network-request-failed')) {
          log.e('Network Resquest failed! May be you are not connected');

          return networkRequestFailed;
        } else {
          if (e.message!.contains(
              'The password is invalid or the user does not have a password.')) {
            return wrongPassword;
          }
          //return failure;
        }
      } else if (e is FirebaseException) {
        log.e('Firebase exception');

        return internalError;
      } else {
        log.e(e.toString());

        return failure;
      }
    }

    log.d('User signed in successfully');

    return success;
  }

// Function to handle Google Sign-In
  Future<int> googleSignIn() async {
    UserCredential credential;

    try {
      if (kIsWeb) {
        log.d("L'application s'exécute dans un navigateur Web.");
        credential = (await withWeb())!;
      } else {
        credential = (await withoutWeb())!;
      }
    } catch (e) {
      log.e('*******');
      log.e(e);
      log.e(e.toString());
      if (e.toString().contains('popup-closed-by-user') ||
          e.toString().contains('null value')) {
        log.e('Pop up closed by user');
        return popupClosedByUser;
      }

      if (e.toString().contains('network_error')) {
        log.e('Network error: $e');
        return networkError;
      }
      return failure;
    }

    // Check if the user is newly registered
    bool isNewUser = credential.additionalUserInfo!.isNewUser;
    String? mail = credential.user!.email;

    try {
      if (isNewUser) {
        // Retrieve the user's email

        log.d('New user*********');

        // Perform your desired operations with the user's email during sign-up or first sign-in
        if (await EmployeeManager().exists(Employee.target(mail!)) ==
            emailNotExists) {
          deleteCurrentUser();
          log.e(
              'Wrong email provided: Enter the email saved during registration');
          return emailInCorrect;
        }
      }
      if (await EmployeeManager().exists(Employee.target(mail!)) ==
          emailNotExists) {
        log.i('Your account has been deleted for you are no longer employee');
        googleSingOut();
        return deleteCurrentUser();
      }
      return success;
    } catch (e) {
      // Handle the sign-in error
      log.e('Error signing in with Google: $e');
      log.e(e.toString());
      if (e.toString().contains('popup-closed-by-user')) {
        log.e('Pop up closed by user');
        return popupClosedByUser;
      }
      if (e.toString().contains('network_error')) {
        log.e('Check your internet connection and try again!');
        return networkError;
      }
      return failure;
    }
  }

  // Function to handle Google Sign-Out
  Future<int> googleSingOut() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Sign out from Google
      await GoogleSignIn().signOut();

      log.d('Successfully signed out from Google.');

      return success;
    } catch (error) {
      log.e('Error signing out from Google: $error');
      return failure;
    }
  }

  Future<int> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((_) {
        // Email verification sent successfully
      }).catchError((error) {
        // Handle the error
        log.e('Error while sending email:$error');
      });
      return success;
    } catch (e) {
      log.e(e);
      return failure;
    }
  }

  Future<int> deleteCurrentUser() async {
    return await delete(FirebaseAuth.instance.currentUser);
  }

  Future<int> updateEmailForCurrentUser(String newEmail) async {
    return await updateEmail(FirebaseAuth.instance.currentUser, newEmail);
  }

  Future<int> updatePasswordForCurrentUser(String newPassword) async {
    return await updatePassword(FirebaseAuth.instance.currentUser, newPassword);
  }

  Future<int> delete(User? user) async {
    try {
      FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.currentUser!.delete();
      // Revoke access for the user from Google
      await GoogleSignIn().disconnect();

      log.i('User deleted successfully.');

      return accountDeleted;
    } catch (e) {
      log.e('Failed to delete user: $e');
      // Handle any errors that occur while deleting the user
      return failure;
    }
  }

  Future<int> updateEmail(User? user, String newEmail) async {
    try {
      FirebaseAuth.instance.currentUser!.updateEmail('adedeezechiel@gmail.com');

      log.i('****/');

      return success;
    } on FirebaseAuthException catch (e) {
      if (e.message!.contains('invalid-email')) {
        return invalidEmail;
      }
      if (e.message!.contains('email-already-in-use')) {
        return emailInUse;
      }

      log.e('Failed to update email for user: $e');
      // Handle any errors that occur while deleting the user
      return failure;
    }
  }

  Future<int> updatePassword(User? user, String newPassword) async {
    try {
      FirebaseAuth.instance.currentUser!.updatePassword(newPassword);

      return accountDeleted;
    } catch (e) {
      log.e('Failed to update password for user: $e');
      // Handle any errors that occur while deleting the user
      return failure;
    }
  }

  Future<User?> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      await FirebaseAuth.instance.signOut();
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      authProvider.setCustomParameters({'login_hint': 'user@example.com'});

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // ...
          } else if (e.code == 'invalid-credential') {
            // ...
          }
        } catch (e) {
          // ...
        }
      }
    }

    return user;
  }

  Future<UserCredential?> withWeb() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    GoogleAuthProvider authProvider = GoogleAuthProvider();
    authProvider.addScope('email');
    authProvider.addScope('https://www.googleapis.com/auth/cloud-platform');

    try {
      return await auth.signInWithPopup(authProvider);
    } catch (e) {
      log.e(e);
    }
    return null;
  }

  Future<UserCredential?> withoutWeb() async {
    // Trigger the Google Sign-In flow

    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();

    // Obtain the authentication details from
    //the Google Sign-In
    final GoogleSignInAuthentication googleAuth =
        await googleSignInAccount!.authentication;

    // Create a new credential using the
    //obtained authentication details
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase using the obtained credential

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
