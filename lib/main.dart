import 'dart:async';
import 'package:cosmetics_project/Pages/Guest.dart';
import 'package:cosmetics_project/Pages/main_screen.dart';
import 'package:cosmetics_project/Pages/on_boarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cosmetics_project/Pages/Login.dart';
import 'package:cosmetics_project/Pages/Home_Page.dart';
import 'package:cosmetics_project/Pages/ProductPage.dart';
import 'package:cosmetics_project/Pages/Comments.dart';
import 'package:cosmetics_project/Pages/Cart.dart';
import 'package:cosmetics_project/Pages/FavItems.dart';
import 'package:cosmetics_project/Pages/Checkout.dart';
import 'provider/product_provider.dart';

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

  try {
    Provider.debugCheckInvalidValueType = null;
    await GetStorage.init(); // Initialize GetStorage
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Product_provider()),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    print('Failed to initialize Firebase or GetStorage: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Lato',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 232, 82, 177),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        OnBoardingScreen.id: (context) => const OnBoardingScreen(),
        MainScreen.id: (context) => const MainScreen(),
        '/LoginScreen': (context) => LoginScreen(),
        '/HomePage': (context) => HomePage(
              title: 'Home Page',
              username: '_usernameController',
            ),
        '/Comments': (context) => Comments(
              title: 'Comment Page',
              postName: 'post1',
              username: '_usernameController',
            ),
        '/ProductPage': (context) => Products(
              title: 'Product Page',
              postName: 'post1',
              username: '_usernameController',
            ),
        '/Cart': (context) => Cart(
              title: 'Product Page',
              username: '_usernameController',
            ),
        '/FavItems': (context) => FavItems(
              title: 'FavItems Page',
              username: '_usernameController',
            ),
        '/Checkout': (context) => Checkout(
              title: 'FavItems Page',
              username: '_usernameController',
            ),
        '/GuestHomePage': (context) => GuestHomePage(
              title: 'Home Page',
            ),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to My App!',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String id = 'splash-screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final store = GetStorage();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      bool? _boarding = store.read('onBoarding');
      if (_boarding == null || _boarding == false) {
        Navigator.of(context).pushReplacementNamed(OnBoardingScreen.id);
      } else {
        Navigator.of(context).pushReplacementNamed(OnBoardingScreen.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('images/logo.png'),
      ),
    );
  }
}
