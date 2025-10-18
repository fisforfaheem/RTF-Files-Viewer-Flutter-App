import 'package:flutter/material.dart';
import 'package:rtf_view/constants/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.description,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // App Name
            const Text(
              'RTF File Viewer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 8),

            // Version
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 40),

            // App Description
            const Text(
              'RTF File Viewer is a simple and efficient application designed to view Rich Text Format (.rtf) files on your mobile devices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 40),

            // Features Section
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Features List
            _buildFeatureItem(
              icon: Icons.file_open,
              title: 'File Selection',
              description:
                  'Browse and select RTF files from your device storage',
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.visibility,
              title: 'Document Viewing',
              description:
                  'View RTF content with proper text formatting and layout',
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.share,
              title: 'Share Content',
              description:
                  'Share text content or original RTF files with others',
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.print,
              title: 'Print Documents',
              description: 'Print RTF content as PDF documents',
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.history,
              title: 'Recent Files',
              description: 'Quick access to recently opened RTF files',
            ),

            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.zoom_in,
              title: 'Text Controls',
              description: 'Adjust text size for comfortable reading',
            ),

            const SizedBox(height: 40),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Simple • Fast • Reliable',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
