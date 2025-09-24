import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes_name.dart';
import '../services/motivation_service.dart';
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
  // Make params optional so route can construct without args
  const MotivationPage({
    Key? key,
    this.isStarting,
    this.messages,
  }) : super(key: key);

  final bool? isStarting;
  final List<String>? messages;

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  int step = -1;
  late MotivationService _motivationService;

  // Local copies resolved from either widget props or Get.arguments
  late bool _isStarting;
  late List<String> _messages;

  @override
  void initState() {
    super.initState();

    // Initialize motivation service
    _motivationService = Get.put(MotivationService());

    // 1) Read args if not provided via constructor
    final args = Get.arguments as Map<String, dynamic>?;

    _isStarting = widget.isStarting ?? (args?['isStarting'] as bool? ?? true);

    final List<String>? passed =
        widget.messages ??
            (args?['messages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList();

    // 2) Fallback copy lives HERE (widget owns defaults)
    _messages = (passed == null || passed.isEmpty)
        ? (_isStarting
        ? const ['Believe in yourself!']
        : const ['Great work for today!'])
        : passed;

    // 3) Generate motivation dan kick off loading -> message
    _generateMotivationAndShow();
  }

  @override
  void dispose() {
    _motivationService.stopAll();
    super.dispose();
  }

  Future<void> _generateMotivationAndShow() async {
    try {
      // Generate motivasi berdasarkan sesi (loading screen)
      final sesi = _isStarting ? "start" : "end";
      await _motivationService.generateMotivation(sesi);
      
      // Setelah selesai generate, tampilkan UI motivation
      if (mounted) setState(() => step = 0);
      
      // Auto-play motivasi pertama kali
      await _playMotivation();
    } catch (e) {
      print("Error generating motivation: $e");
      // Jika error, tetap lanjut ke step berikutnya dengan pesan default
      if (mounted) setState(() => step = 0);
    }
  }

  Future<void> _playMotivation() async {
    await _motivationService.playMotivationWithStreaming();
  }

  @override
  Widget build(BuildContext context) {
    if (step == -1) return _loadingScreen();
    return _messageScreen();
  }

  Widget _loadingScreen() {
    return Scaffold(
      backgroundColor: brand700,
      body: Center(
        child: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              _isStarting ? "Memulai Sesimu..." : "Mengakhiri Sesimu...",
              style: mobileH2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _motivationService.isGenerating.value 
                  ? "Mempersiapkan motivasi..."
                  : "Hampir selesai...",
              style: bodyText16.copyWith(color: Colors.white70),
            ),
            
            // Progress indicator untuk audio generation
            if (_motivationService.currentText.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "Motivasi siap!",
                      style: bodyText14.copyWith(color: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        )),
      ),
    );
  }

  Widget _messageScreen() {
    return Scaffold(
      backgroundColor: brand700,
      body: Obx(() {
        // Jika ada text dari AI dan sedang streaming, tampilkan itu
        if (_motivationService.currentText.value.isNotEmpty) {
          return _streamingMessageScreen();
        }
        
        // Fallback ke pesan default
        return _defaultMessageScreen();
      }),
    );
  }

  Widget _streamingMessageScreen() {
    final screenHeight = AppUtils.screenHeight(context);
    
    return Stack(
      children: [
        // Background dan dekorasi sama seperti sebelumnya
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.2,
              left: 32,
              right: 32,
            ),
            child: Obx(() => Column(
              children: [
                // Tampilkan teks yang sudah muncul
                Text(
                  _motivationService.streamingWords.join(' '),
                  textAlign: TextAlign.center,
                  style: mobileH1.copyWith(
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Indikator audio playing
                if (_motivationService.isPlayingAudio.value)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volume_up, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Sedang diputar...",
                        style: bodyText14.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
              ],
            )),
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

        // Item 3: The music note image
        Positioned(
          bottom: screenHeight * 0.35,
          left: 30,
          child: Image.asset(
            "assets/images/music-spark-confetti.png",
            width: 120,
          ),
        ),

        // Item 4: The star image
        Positioned(
          bottom: screenHeight * 0.35,
          right: 30,
          child: Image.asset(
            "assets/images/star-spark-confetti.png",
            width: 130,
          ),
        ),

        // Item 5: The action buttons
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play Again Button (show when not playing)
                if (!_motivationService.isPlayingAudio.value && 
                    _motivationService.currentText.value.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: _playMotivation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: brand700, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.replay, color: brand700, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Putar Lagi',
                              style: bodyText14.copyWith(
                                color: brand700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Main Action Button
                InkWell(
                  onTap: _motivationService.isPlayingAudio.value ? null : _handleNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: _motivationService.isPlayingAudio.value 
                          ? Colors.grey 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _motivationService.isPlayingAudio.value 
                          ? "Tunggu sebentar..."
                          : (_isStarting ? "Mulai" : "Selesai"),
                      style: buttonText.copyWith(
                        color: _motivationService.isPlayingAudio.value 
                            ? Colors.white 
                            : brand700,
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ),
      ],
    );
  }

  void _handleNext() {
    if (_isStarting) {
      Get.offNamed(RoutesName.warmUp);
    } else {
      Get.offNamed(RoutesName.studyResult);
    }
  }

  Widget _defaultMessageScreen() {
    final msg = _messages.isNotEmpty ? _messages[step] : "Let's get started!";
    final isFirst = step == 0;
    final isLast = step >= _messages.length - 1;
    final screenHeight = AppUtils.screenHeight(context);

    // Start flow: first=Mulai, middle=Lanjut, last=Selesai
    // End flow:   never show "Mulai"
    final buttonText = _isStarting
        ? (isFirst ? "Mulai" : (isLast ? "Selesai" : "Lanjut"))
        : (isLast ? "Selesai" : "Lanjut");

    void handlePress() {
      if (!isLast) {
        setState(() => step++);
      } else {
        if (_isStarting) {
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

          // Item 3: The music note image
          Positioned(
            bottom: screenHeight * 0.35,
            left: 30,
            child: Image.asset(
              "assets/images/music-spark-confetti.png",
              width: 120,
            ),
          ),

          // Item 4: The star image
          Positioned(
            bottom: screenHeight * 0.35,
            right: 30,
            child: Image.asset(
              "assets/images/star-spark-confetti.png",
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
                    buttonText,
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