import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({Key? key}) : super(key: key);

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final List<String> _bannerImage = [
    'images/banner1.1.jpg',
    'images/banner2.jpg',
    'images/banner3.webp',
    'images/banner4.1.jpg',
    'images/banner5.jpg',
  ];

  double scrollerPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 140,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: PageView.builder(
                itemCount: _bannerImage.length,
                itemBuilder: (BuildContext context, int index) {
                  return Image.asset(
                    _bannerImage[index],
                    fit: BoxFit
                        .fill, // Use BoxFit.fill to ensure the image fills the container
                  );
                },
                onPageChanged: (val) {
                  setState(() {
                    scrollerPosition = val.toDouble();
                  });
                },
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: DotsIndicatorWidget(scrollerPosition: scrollerPosition),
        ),
      ],
    );
  }
}

class DotsIndicatorWidget extends StatelessWidget {
  const DotsIndicatorWidget({
    Key? key,
    required this.scrollerPosition,
  }) : super(key: key);

  final double scrollerPosition;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DotsIndicator(
        position: scrollerPosition.toInt(),
        dotsCount: 5,
        decorator: DotsDecorator(
          activeColor: Colors.pink.shade400,
          color: Colors.pink.shade200,
          spacing: EdgeInsets.all(2),
          size: const Size.square(6),
          activeSize: const Size(12, 6),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
