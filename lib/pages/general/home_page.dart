import 'package:flutter/material.dart';
import 'package:teklif/pages/slide_second_page.dart';
import 'package:teklif/pages/welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _controller = PageController(viewportFraction: 1.0);

  final List<Widget> _pages = const [
    WelcomePage(),
    SecondPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          PageView(
            controller: _controller,
            children: _pages,
            onPageChanged: (index) => setState(() => _currentIndex = index),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _pages.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(
                  entry.key,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? Colors.blueAccent
                        : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
