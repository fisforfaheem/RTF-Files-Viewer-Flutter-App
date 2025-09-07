import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rtf_view/constants/colors.dart';
import 'package:rtf_view/screens/document_viewer_screen.dart';
import 'package:rtf_view/screens/recent_files_screen.dart';
import 'package:rtf_view/services/rtf_provider.dart';
import 'package:rtf_view/widgets/rtf_icon.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                'RTF File Viewer',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 40),
              const RtfIcon(size: 120),
              const SizedBox(height: 24),
              Text(
                'Welcome to\nRTF File Viewer App.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuButton(
                    context,
                    'View\nFiles',
                    Icons.description,
                    () => _pickAndOpenRtfFile(context),
                  ),
                  const SizedBox(width: 24),
                  _buildMenuButton(
                    context,
                    'Recent\nFiles',
                    Icons.history,
                    () => _navigateToRecentFiles(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildAboutUsButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 120,
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutUsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _showAboutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'About Us',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _pickAndOpenRtfFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['rtf'],
      );

      if (result != null && result.files.single.path != null) {
        if (!context.mounted) return;
        
        final rtfProvider = Provider.of<RtfProvider>(context, listen: false);
        await rtfProvider.openRtfFile(result.files.single.path!);
        
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DocumentViewerScreen(),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  void _navigateToRecentFiles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecentFilesScreen(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About RTF File Viewer'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RTF File Viewer is a high-performance application designed to view Rich Text Format files on Android devices.',
            ),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}