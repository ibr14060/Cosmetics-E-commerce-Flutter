import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetics_project/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final User? user = Auth().currentUser;
  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return Text('Welcome ${user!.email}');
  }

  Widget _logoutButton() {
    return ElevatedButton(
      onPressed: () {
        signOut();
      },
      child: Text('Logout'),
    );
  }

  Widget _userID() {
    return Text('User ID: ${user!.uid}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userID(),
            _logoutButton(),
          ],
        ),
      ),
    );
  }
}
