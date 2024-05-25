import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cosmetics_project/Pages/main_screen.dart';
import 'package:get_storage/get_storage.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);
  static const String id = 'onboard-screen';

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  double currentPage = 0;
  double scrollerPosition = 0;
  final store = GetStorage();
  onButtonPressed(context) {
    store.write('onBoarding', true);
    return Navigator.pushReplacementNamed(context, MainScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color.fromARGB(255, 242, 168, 193), // Background color
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          PageView(
            onPageChanged: (val) {
              setState(() {
                currentPage = val.toDouble();
              });
            },
            children: [
              OnBoardPage(
                boardImage: Image.asset(
                  'images/p.jpeg',
                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText:
                    'Welcome to beauty store where you can find latest makeup products',
              ),
              OnBoardPage(
                boardImage: Image.asset(
                  'images/2.jpeg',
                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText: 'YOUR MUST HAVES HAIR STYLING TOOLS',
              ),
              OnBoardPage(
                boardImage: Image.asset(
                  'images/1.jpeg',
                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText: 'NEEDED SUPPLEMENTS AND VITAMINS',
              ),
              OnBoardPage(
                boardImage: Image.asset(
                  'images/3.jpeg',
                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText: 'SKIN CARE PRODUCTS',
              ),
              OnBoardPage(
                boardImage: Image.asset(
                  'images/5.webp',
                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText: 'YOUR FAVS PERFUMES',
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DotsIndicator(
                  dotsCount: 5,
                  position: currentPage.toInt(),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: TextButton(
                    onPressed: () {
                      onButtonPressed(context);
                    },
                    child: const Text(
                      'SKIP TO MAIN PAGE',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFFFCCC1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnBoardPage extends StatelessWidget {
  final Image boardImage;
  final String boardText;

  const OnBoardPage(
      {Key? key, required this.boardImage, required this.boardText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: boardImage,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 450.0),
            child: Text(
              boardText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
