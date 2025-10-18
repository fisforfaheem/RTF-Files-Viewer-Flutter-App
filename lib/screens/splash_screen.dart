import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rtf_view/constants/colors.dart';
import 'package:rtf_view/screens/main_menu_screen.dart';
import 'package:rtf_view/widgets/rtf_logo_widget.dart'; // Import RtfLogoWidget

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startNavigationTimer();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(seconds: 60), () {
      if (!_hasNavigated && mounted) {
        _navigateToMainMenu();
      }
    });
  }

  Future<void> _navigateToMainMenu() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    _navigationTimer?.cancel();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // RTF Banner in top-left
          Positioned(
            top: 30,
            left: -60,
            child: Transform.rotate(
              angle: -0.7, // Rotate by approximately -40 degrees
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300, // Light grey banner background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'RTF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Red RTF text
                  ),
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'RTF File Viewer',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Red color from image
                  ),
                ),
                const SizedBox(height: 16),
                // RTF Logo Widget
                const RtfLogoWidget(height: 120),
                const SizedBox(height: 24),
                // Subtitle
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          AppColors.textPrimary, // Darker text color from image
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'View '),
                      TextSpan(
                        text: 'RTF files',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' in Your\nSmart Phones with simple\n'),
                      TextSpan(
                        text: 'RTF File Viewer App.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tap to continue button
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _navigateToMainMenu,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          Colors.grey.shade300, // Light grey circle from image
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.primary, // Red arrow from image
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap to Continue',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          AppColors.textPrimary, // Darker text color from image
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
