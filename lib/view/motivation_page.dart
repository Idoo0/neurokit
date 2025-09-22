import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes_name.dart';
import '../utils.dart'; // Import your utils file

/// Custom clipper to create the inverted arc shape.
class _InvertedArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 40);
    path.quadraticBezierTo(size.width / 2, -40, 0, 40);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MotivationPage extends StatefulWidget {
  final bool isStarting;
  final List<String> messages;
  const MotivationPage({
    Key? key,
    required this.isStarting,
    required this.messages,
  }) : super(key: key);

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  int step = -1;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          step = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (step == -1) {
      return _loadingScreen();
    } else {
      return _messageScreen();
    }
  }

  Widget _loadingScreen() {
    return Scaffold(
      backgroundColor: brand700,
      body: Center(
        child: Text(
          widget.isStarting ? "Memulai Sesimu..." : "Mengakhiri Sesimu...",
          style: mobileH2.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _messageScreen() {
    final msg = widget.messages.isNotEmpty ? widget.messages[step] : "Let's get started!";
    final isLastMessage = step >= widget.messages.length - 1;
    final screenHeight = AppUtils.screenHeight(context);

    void handlePress() {
      if (!isLastMessage) {
        setState(() => step++);
      } else {
        if (widget.isStarting) {
          Get.offNamed(RoutesName.warmUp);
        } else {
          Get.offNamed(RoutesName.studyResult);
        }
      }
    }

    return Scaffold(
      backgroundColor: brand700,
      body: Stack(
        children: [
          // Item 1: The motivational text
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.2,
                left: 32,
                right: 32,
              ),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: mobileH1.copyWith(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // Item 2: The white arc background
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _InvertedArcClipper(),
              child: Container(
                height: screenHeight * 0.35,
                color: Colors.white,
              ),
            ),
          ),

          // Item 3: The music note image (sibling to the white arc)
          Positioned(
            bottom: screenHeight * 0.35,
            left: 30,
            child: Image.asset(
              "assets/images/music-spark-confetti.PNG",
              width: 120,
            ),
          ),

          // Item 4: The star image (sibling to the white arc)
          Positioned(
            bottom: screenHeight * 0.35,
            right: 30,
            child: Image.asset(
              "assets/images/star-spark-confetti.PNG",
              width: 130,
            ),
          ),

          // Item 5: The action button
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: handlePress,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    isLastMessage ? "Selesai" : "Mulai",
                    style: mobileH3.copyWith(color: brand700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}