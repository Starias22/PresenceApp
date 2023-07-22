import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:presence_app/utils.dart';

class Login {
  Future<bool> signUp(String email, String password) async {

    try {
      var credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.sendEmailVerification();
    } catch (e) {
      if (e is FirebaseAuthException) {
        if(e.message!.contains('email address is already in use'))
      {
  return true;
    }
        log.e(e);
        return false;
      }
    }
    log.d('Sign up successful');
    return true;
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

    return success;
  }

// Function to handle Google Sign-In
  Future<int> googleSignIn() async {

    try {
      if (kIsWeb) {
log.d('Signing in on web');
        await withWeb();


      } else {
        log.d('Not web merveil bandit');
         await withoutWeb();
      }
      return success;


    } catch (e) {

      log.e(e);


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

  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((_) {
            return true;
        // Email verification sent successfully
      }).catchError((error) {
        //error.toString().contains(other)
        // Handle the error

        return false;
      });
      return true;
    } catch (e) {
      log.e(e);
      return false;
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
      FirebaseAuth.instance.currentUser!.updateEmail(newEmail);
      return success;
    } on FirebaseAuthException catch (e) {
      log.e('error during mail sending');
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
        log.e(e);
      }
    }
    else {
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

  //L'état de l'utilisateur en temps réel
  Stream<User?> get user {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.authStateChanges();
  }

  Future<UserCredential> withWeb() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    GoogleAuthProvider authProvider = GoogleAuthProvider();
    authProvider.addScope('email');
    authProvider.addScope('https://www.googleapis.com/auth/cloud-platform');


       return await auth.signInWithPopup(authProvider);


  }

  Future<UserCredential?> withoutWeb() async {
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
  bool isSignedIn() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    return user!=null;
  }
  bool isSignedInWithPassword(){
    if(!isSignedIn()) return false;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.providerData[0].providerId=='password';

  }
}
