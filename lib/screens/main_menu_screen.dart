import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rtf_view/constants/colors.dart';
import 'package:rtf_view/screens/document_viewer_screen.dart';
import 'package:rtf_view/screens/recent_files_screen.dart';
import 'package:rtf_view/services/rtf_provider.dart';
import 'package:rtf_view/widgets/rtf_icon.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _button1Animation;
  late Animation<Offset> _button2Animation;
  late Animation<Offset> _aboutAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Main fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Scale animation for RTF icon
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Slide animation for main content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Staggered button animations
    _button1Animation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
          ),
        );

    _button2Animation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
          ),
        );

    _aboutAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

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
              // Animated title
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'RTF File Viewer',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Animated RTF icon
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const RtfIcon(size: 120),
                ),
              ),
              const SizedBox(height: 24),
              // Animated subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Welcome to\nRTF File Viewer App.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
              const Spacer(),
              // Animated menu buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideTransition(
                    position: _button1Animation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAnimatedMenuButton(
                        context,
                        'View\nFiles',
                        Icons.description,
                        () => _pickAndOpenRtfFile(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  SlideTransition(
                    position: _button2Animation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildAnimatedMenuButton(
                        context,
                        'Recent\nFiles',
                        Icons.history,
                        () => _navigateToRecentFiles(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Animated about button
              SlideTransition(
                position: _aboutAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildAboutUsButton(context),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return _AnimatedMenuButton(label: label, icon: icon, onPressed: onPressed);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('About Us', style: TextStyle(fontSize: 16)),
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

class _AnimatedMenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedMenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 32, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
