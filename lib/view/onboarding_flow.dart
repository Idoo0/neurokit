// lib/view/onboarding_flow_screen.dart

import 'package:flutter/material.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  // Controller to manage which page is visible
  final PageController _pageController = PageController();

  // Keep track of the current page index
  int _currentPageIndex = 0;

  // Form controllers and variables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  String? _selectedClass;
  final List<String> _classOptions = ['7', '8', '9'];

  // This function is called when a page is changed
  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  // Animate to the next page
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
  _pageController.previousPage(
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );
}

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF183D8D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 48, // Standard height for a touch target
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Conditionally show the back button
                    if (_currentPageIndex > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                          onPressed: _previousPage,
                        ),
                      ),
                    // Progress Dots
                    _ProgressDots(
                      currentIndex: _currentPageIndex,
                      color: primaryBlue,
                    ),
                  ],
                ),
              ),
                // STATIC PART: Progress Dots
                

              const SizedBox(height: 30),
              // STATIC PART: Logo
              Image.asset(
                'assets/images/logo.png',
                // Adjust height based on the first page vs others
                height: _currentPageIndex == 0 ? 180.0 : 60.0,
              ),
              const SizedBox(height: 30),

              // DYNAMIC PART: The PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  // Disable swiping by the user
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomePage(primaryBlue),
                    _buildIntroductionPage(primaryBlue),
                    _buildDreamPage(primaryBlue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page 1: Welcome
  Widget _buildWelcomePage(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Belajar jadi seru dengan cahaya, suara, dan semangat bikin fokusmu tahan lama & ingatan makin kuat',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: Colors.black87, height: 1.5),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _nextPage,
          style: _buttonStyle(primaryBlue),
          child: const Text('Get Started'),
        ),
        TextButton(
          onPressed: () { /* Handle skip */ },
          child: const Text('Skip', style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Page 2: Introduction
  Widget _buildIntroductionPage(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Kenalan dulu, yuk!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _nameController,
          hintText: 'Masukan nama panggilan mu',
        ),
        const SizedBox(height: 20),
        _buildDropdown(),
        const Spacer(),
        ElevatedButton(
          onPressed: _nextPage,
          style: _buttonStyle(primaryBlue),
          child: const Text('Selanjutnya'),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  // Page 3: Dream
  Widget _buildDreamPage(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Ceritakan impianmu!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _universityController,
          hintText: 'Universitas Impian',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _majorController,
          hintText: 'Jurusan Impian',
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            // This is the final step, navigate to the main app
            print('Onboarding complete!');
            Navigator.pushReplacementNamed(context, '/homepage');
          },
          style: _buttonStyle(primaryBlue),
          child: const Text('Ayo Mulai'),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  // --- Helper Widgets for UI consistency ---

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
  
  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedClass,
          hint: const Text('Kelas', style: TextStyle(color: Colors.grey)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _classOptions.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedClass = newValue;
            });
          },
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}

// A separate stateless widget for the dots to keep the build method clean
class _ProgressDots extends StatelessWidget {
  final int currentIndex;
  final Color color;

  const _ProgressDots({required this.currentIndex, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: index == currentIndex ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}