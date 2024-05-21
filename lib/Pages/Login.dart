import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetics_project/auth.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: LoginScreenApp(),
    );
  }
}

class LoginScreenApp extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenApp> {
  String? error = '';
  bool isLogin = true;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  Future<bool> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _usernameController.text, password: _passwordController.text);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          error = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          error = 'Wrong password provided for that user.';
        });
      }
      return false;
    } catch (e) {
      setState(() {
        error = 'An unknown error occurred.';
      });
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
        mobileNumber: _mobileController.text,
        address: _addressController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          error = 'The password provided is too weak.';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          error = 'The account already exists for that email.';
        });
      }
      return false;
    } catch (e) {
      setState(() {
        error = 'An unknown error occurred.';
      });
      return false;
    }
  }

  void _loginOrSignup() async {
    bool isSuccess;
    if (isLogin) {
      isSuccess = await signInWithEmailAndPassword();
    } else {
      isSuccess = await createUserWithEmailAndPassword();
    }

    if (isSuccess) {
      Navigator.pushReplacementNamed(context, '/HomePage');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(error ?? 'An error occurred'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void toggleFormMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLogin) ...[
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
            ],
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loginOrSignup,
              child: Text(isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: toggleFormMode,
              child: Text(isLogin
                  ? 'Don\'t have an account? Sign Up'
                  : 'Have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
