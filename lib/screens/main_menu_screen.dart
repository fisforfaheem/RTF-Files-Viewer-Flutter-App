import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rtf_view/constants/colors.dart';
import 'package:rtf_view/screens/about_screen.dart';
import 'package:rtf_view/screens/document_viewer_screen.dart';
import 'package:rtf_view/screens/recent_files_screen.dart';
import 'package:rtf_view/services/rtf_provider.dart';
import 'package:rtf_view/widgets/rtf_logo_widget.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Title
              Text(
                'RTF File Viewer',
                style: TextStyle(
                  fontSize: 28, // Correct font size from image
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Main title color from image
                ),
              ),
              const SizedBox(height: 40),
              // RTF Icon
              const RtfLogoWidget(height: 120),
              const SizedBox(height: 24),
              // Subtitle
              const Text(
                'Welcome to\nRTF File Viewer App.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ), // Subtitle color from image
              ),
              const SizedBox(height: 20),
              // Menu buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuButton(
                    context,
                    'View\nFiles',
                    () => _pickAndOpenRtfFile(context),
                  ),
                  const SizedBox(width: 24),
                  _buildMenuButton(
                    context,
                    'Recent\nFiles',
                    () => _navigateToRecentFiles(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // About button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showAboutScreen(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.grey.shade300, // Corrected to light grey
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'About Us',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 120,
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white, // Ensure text is white for red buttons
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ), // Ensure text is white for red buttons
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndOpenRtfFile(BuildContext context) async {
    try {
      // First try with custom file type for RTF files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['rtf'],
      );

      // If that doesn't work, try with any file type
      if (result == null || result.files.isEmpty) {
        result = await FilePicker.platform.pickFiles(type: FileType.any);
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        if (file.path != null) {
          // Check if it's actually an RTF file
          final fileName = file.name.toLowerCase();
          if (!fileName.endsWith('.rtf')) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select an RTF file (.rtf extension)'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          if (!context.mounted) return;

          final rtfProvider = Provider.of<RtfProvider>(context, listen: false);
          await rtfProvider.openRtfFile(file.path!);

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DocumentViewerScreen(),
            ),
          );
        } else if (file.bytes != null) {
          // Handle files without path (web/mobile scenarios)
          if (!context.mounted) return;

          final rtfProvider = Provider.of<RtfProvider>(context, listen: false);
          await rtfProvider.openRtfFileFromBytes(file.bytes!, file.name);

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DocumentViewerScreen(),
            ),
          );
        }
      } else {
        // User cancelled file picker
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No file selected')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToRecentFiles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecentFilesScreen()),
    );
  }

  void _showAboutScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }
}
