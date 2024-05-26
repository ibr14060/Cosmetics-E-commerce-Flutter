import 'package:cosmetics_project/Pages/Guest.dart';
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
    Navigator.pushReplacementNamed(context, '/GuestHomePage');
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
                boardImage: Image(
                  image: NetworkImage(
                      'https://www.byrdie.com/thmb/Qi-SWEO79P6vKqZp_ZSZMhHySjA=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/BYR-GROUPSHOT_JessicaJuliao-0282.jpg-88161a03826f40d9aaa96286e724ddb0.jpg'),
                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText:
                    'Welcome to beauty store where you can find latest makeup products',
              ),
              OnBoardPage(
                boardImage: Image(
                  image: NetworkImage(
                      'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi99aQOWT6L_5TQPyzB-v_KgmNIRoILOzNZfdnQnGniwGflHmohec4MJG9Ce3Qev2W9KQgIiD2AwY20gFE_VwStmr0RYw4om4UWRy33mttCSfyONbwvkt3qiTh59nDN6EStteCg4xX9WMQx00Zu44pfpqGDpEqysijMR_LjRAN5kynTJyqfbKrLjG5B4A/s640/Nakeup%20Face%20Water%20Barbie%20Set%20(1).jpeg'),
                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText:
                    'Welcome to beauty store where you can find latest makeup products',
              ),
              OnBoardPage(
                boardImage: Image(
                  image: NetworkImage(
                      'https://static01.nyt.com/images/2018/12/20/t-magazine/fashion/20tmag-fragrance/20tmag-fragrance-superJumbo.jpg'),

                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText: 'NEEDED SUPPLEMENTS AND VITAMINS',
              ),
              OnBoardPage(
                boardImage: Image(
                  image: NetworkImage(
                      'https://img.fruugo.com/product/9/07/297418079_max.jpg'),
                  fit: BoxFit.cover, // Adjust the fit property
                  width: MediaQuery.of(context).size.width,
                ),
                boardText: 'SKIN CARE PRODUCTS',
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
