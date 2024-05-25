import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cosmetics_project/Pages/Login.dart';
import 'Pages/Home_Page.dart';
import 'Pages/ProductPage.dart';
import 'Pages/Comments.dart';
import 'Pages/Cart.dart';
import 'Pages/FavItems.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyATJmaerdU7lQuNsPyp-a5Tl0cAteF8FSQ',
    appId: '1:893206265578:android:a1ebe964fd618f068fe193',
    messagingSenderId: 'sendid',
    projectId: 'mobileproject12-d6fad',
    storageBucket: 'mobileproject12-d6fad.appspot.com',
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/LoginScreen': (context) => LoginScreen(),
        '/HomePage': (dummyCtx) => HomePage(
              title: 'Home Page',
              username: '_usernameController',
            ),
        '/Comments': (dummyCtx) => Comments(
              title: 'Comment Page',
              postName: 'post1',
              username: '_usernameController',
            ),
        '/ProductPage': (dummyCtx) => Products(
              title: 'Product Page',
              postName: 'post1',
              username: '_usernameController',
            ),
        '/Cart': (dummyCtx) => Cart(
              title: 'Product Page',
              username: '_usernameController',
            ),
        '/FavItems': (dummyCtx) => FavItems(
              title: 'FavItems Page',
              username: '_usernameController',
            )
      },
    );
  }
}
