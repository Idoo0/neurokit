// lib/view/introduction_screen.dart

import 'package:flutter/material.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  // Controller for the name input field
  final TextEditingController _nameController = TextEditingController();
  // Variable to hold the selected class value
  String? _selectedClass;
  // List of items for the dropdown
  final List<String> _classOptions = ['7', '8', '9'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF183D8D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous screen (empty dot)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8.0),
            // Current screen (filled dot)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: const BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8.0),
            // Next screen (empty dot)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20), // Spacing from app bar

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 60.0, // Smaller logo for subsequent screens
                ),
              ),

              const SizedBox(height: 30.0),

              // Title
              const Text(
                'Kenalan dulu, yuk!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 40.0),

              // Name Input Field
              _buildTextField(
                controller: _nameController,
                hintText: 'Masukan nama panggilan mu',
              ),

              const SizedBox(height: 20.0),

              // Class Dropdown Field
              Container(
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
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                      });
                    },
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    dropdownColor: Colors.white, // Background color of dropdown menu
                  ),
                ),
              ),

              const Spacer(),

              // "Selanjutnya" Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Save data if needed
                  Navigator.pushNamed(context, '/dream');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Selanjutnya'),
              ),

              const SizedBox(height: 40.0), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background for the input field
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none, // Remove default underline
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}