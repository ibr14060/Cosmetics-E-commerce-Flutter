import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetics_project/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future<User?>.value(Auth().currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasError || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Error'),
              ),
              body: Center(
                child: Text('Error: User not found'),
              ),
            );
          } else {
            final User user = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text('Welcome ${user.email}'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('User ID: ${user.uid}'),
                    ElevatedButton(
                      onPressed: () {
                        Auth().signOut();
                        Navigator.pushReplacementNamed(context, '/LoginScreen');
                      },
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }
}
