import 'package:flutter/material.dart';

class RtfLogoWidget extends StatelessWidget {
  final double height;

  const RtfLogoWidget({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/icons/rtf 1.png',
        height: height * 0.7, // Adjust image size relative to container
      ),
    );
  }
}
