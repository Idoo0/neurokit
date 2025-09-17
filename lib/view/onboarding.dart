// lib/view/onboarding_screen.dart

import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a constant for the blue color to easily reuse it.
    const Color primaryBlue = Color(0xFF183D8D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            // Use CrossAxisAlignment.stretch to make children like buttons
            // fill the horizontal space available from the Padding.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Spacer pushes the content down from the top.
              // The flex value gives it more weight compared to the other spacer.
              const Spacer(flex: 2),

              // Your logo
              Image.asset(
                'assets/images/logo.png', // corrected path (no leading './')
                height: 180.0, // Adjust the size as needed
                // If the image fails to load, show a simple fallback instead of crashing
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  height: 180.0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Logo not found', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50.0),

              // The main descriptive text
              const Text(
                'Belajar jadi seru dengan cahaya, suara, dan semangat bikin fokusmu tahan lama & ingatan makin kuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                  height: 1.5, // Line height for better readability
                ),
              ),

              // This spacer creates a large gap, pushing buttons to the bottom
              const Spacer(),

              // "Get Started" Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Add navigation logic here
                  print('Get Started button pressed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: const StadiumBorder(), // Creates the rounded pill shape
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Get Started'),
              ),

              const SizedBox(height: 12.0),

              // "Skip" Button
              TextButton(
                onPressed: () {
                  // TODO: Add navigation logic here
                  print('Skip button pressed');
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),

              // Provides some padding at the very bottom of the screen
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}