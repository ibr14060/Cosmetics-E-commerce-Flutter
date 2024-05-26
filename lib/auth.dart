import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

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
      _storeAuthState(true); // Store authentication state
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
    required String role,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        final response = await http.post(
          Uri.parse(
              'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Users.json'),
          body: json.encode({
            'email': email,
            'mobileNumber': mobileNumber,
            'address': address,
            'firstName': firstName,
            'lastName': lastName,
          }),
        );
        if (response.statusCode == 200) {
          final Cartresponse = await http.post(
            Uri.parse(
                'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Cart.json'),
            body: json.encode({
              'email': email,
              'Products': "",
            }),
          );
          final Favresponse = await http.post(
            Uri.parse(
                'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/FavItems.json'),
            body: json.encode({
              'email': email,
              'Products': "",
            }),
          );
          final Orderresponse = await http.post(
            Uri.parse(
                'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Orders.json'),
            body: json.encode({
              'email': email,
              'Products': "",
            }),
          );
          if (Cartresponse.statusCode == 200 &&
              Favresponse.statusCode == 200 &&
              Orderresponse.statusCode == 200) {
            print('User data added to database');
            _storeAuthState(true); // Store authentication state
          } else {
            print('Error adding user data to database');
          }
        }
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

  void _storeAuthState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<bool> getAuthState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> _createEmptyCart(String userId, String email) async {
    final response = await http.post(
      Uri.parse(
          'https://mobileproject12-d6fad-default-rtdb.firebaseio.com/Cart.json'),
      body: json.encode({
        'email': email,
        'Products': [],
      }),
    );
    if (response.statusCode == 200) {
      await _database.child('Cart').child(userId).set({
        'email': email,
        'Products': [],
      });
    }
  }

  Future<void> _createEmptyFavItems(String userId, String email) async {
    await _database.child('FavItems').child(userId).set({
      'email': email,
      'Products': [],
    });
  }

  Future<void> _createEmptyOrders(String userId, String email) async {
    await _database.child('Orders').child(userId).set({
      'email': email,
      'Products': [],
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _storeAuthState(false); // Clear authentication state
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
