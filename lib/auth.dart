import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Ensure the database reference uses the correct URL
  final DatabaseReference _database = FirebaseDatabase(
    databaseURL: "https://mobileproject12-d6fad-default-rtdb.firebaseio.com",
  ).reference();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String mobileNumber,
    required String address,
    required String firstName,
    required String lastName,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await _database.child('Users').child(user.uid).set({
          'email': email,
          'mobileNumber': mobileNumber,
          'address': address,
          'firstName': firstName,
          'lastName': lastName,
        });
        print('User data added to database');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return null;
    } catch (e) {
      print('An error occurred: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
