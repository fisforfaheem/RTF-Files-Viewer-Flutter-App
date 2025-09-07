import 'package:flutter/material.dart';
import 'package:rtf_view/constants/colors.dart';

class RtfIcon extends StatelessWidget {
  final double size;
  final bool showCorner;

  const RtfIcon({
    super.key,
    this.size = 80.0,
    this.showCorner = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Base document shape
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.rtfIconBackground,
              borderRadius: BorderRadius.circular(size * 0.1),
            ),
          ),
          
          // Folded corner
          if (showCorner)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.rtfIconCorner,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size * 0.1),
                  ),
                ),
              ),
            ),
          
          // RTF text
          Center(
            child: Container(
              width: size * 0.6,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: AppColors.rtfIconCorner,
                borderRadius: BorderRadius.circular(size * 0.05),
              ),
              child: Center(
                child: Text(
                  'RTF',
                  style: TextStyle(
                    color: AppColors.rtfIconText,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.15,
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