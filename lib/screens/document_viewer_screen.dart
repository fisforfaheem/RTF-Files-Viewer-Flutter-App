import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rtf_view/constants/colors.dart';
import 'package:rtf_view/services/rtf_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _parsedTextContent = '';
  double _textSize = 16.0;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Copy text to clipboard
  void _copyTextToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Share text content
  void _shareText(BuildContext context, String text, String fileName) async {
    try {
      await Share.share(text, subject: 'Shared from RTF Viewer: $fileName');
      if (!context.mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Share file
  void _shareFile(
    BuildContext context,
    String filePath,
    String fileName,
  ) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles([file], subject: 'Shared RTF file: $fileName');
      if (!context.mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Save file as copy
  void _saveFileAsCopy(
    BuildContext context,
    String filePath,
    String fileName,
  ) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null)
        throw Exception('Downloads directory not available');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName =
          '${fileName.replaceAll('.rtf', '')}_copy_$timestamp.rtf';
      final newFilePath = '${directory.path}/$newFileName';

      await File(filePath).copy(newFilePath);

      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File saved as: $newFileName'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Print functionality (placeholder - would need platform-specific implementation)
  void _printDocument(BuildContext context, String text, String fileName) {
    // For now, just show a message
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print functionality will be available soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Text size controls
  void _increaseTextSize() {
    setState(() {
      if (_textSize < 32.0) {
        _textSize += 2.0;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text size: ${_textSize.toInt()}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _decreaseTextSize() {
    setState(() {
      if (_textSize > 10.0) {
        _textSize -= 2.0;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text size: ${_textSize.toInt()}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View RTF File'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context, _parsedTextContent),
          ),
        ],
      ),
      body: Consumer<RtfProvider>(
        builder: (context, rtfProvider, child) {
          if (rtfProvider.isLoading) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading document...'),
                  ],
                ),
              ),
            );
          }

          if (rtfProvider.error != null) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading file',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(rtfProvider.error!),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (rtfProvider.currentFile == null) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AppColors.primary,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No file selected',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Please select an RTF file to view'),
                    ],
                  ),
                ),
              ),
            );
          }

          // Display RTF content with improved formatting
          return FutureBuilder<String>(
            future: rtfProvider.parseRtfContent(
              rtfProvider.currentFile!.content!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Parsing RTF content...'),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error parsing RTF content',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(snapshot.error.toString()),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              // Store the parsed text content for sharing functionality
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _parsedTextContent != snapshot.data) {
                    setState(() {
                      _parsedTextContent = snapshot.data!;
                    });
                  }
                });
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Colors.grey,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No content available',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('This RTF file appears to be empty'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Animated document header card
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.0, -0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: const Interval(
                                  0.3,
                                  0.7,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.description,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    rtfProvider.currentFile!.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Document content card
                      Expanded(
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(top: 1),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Animated text size controls
                              FadeTransition(
                                opacity: Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: _slideController,
                                        curve: const Interval(
                                          0.5,
                                          0.9,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      _AnimatedZoomButton(
                                        icon: Icons.zoom_out,
                                        tooltip: 'Decrease text size',
                                        onPressed: _decreaseTextSize,
                                      ),
                                      _AnimatedZoomButton(
                                        icon: Icons.zoom_in,
                                        tooltip: 'Increase text size',
                                        onPressed: _increaseTextSize,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Document content
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        snapshot.data!,
                                        style: TextStyle(
                                          height: 1.5,
                                          fontSize: _textSize,
                                          letterSpacing: 0.5,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.left,
                                        enableInteractiveSelection: true,
                                      ),
                                      // Add some bottom padding for better scrolling experience
                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, String textContent) {
    final currentFileName =
        Provider.of<RtfProvider>(context, listen: false).currentFile?.name ??
        'Document';
    final currentFilePath =
        Provider.of<RtfProvider>(context, listen: false).currentFile?.path ??
        '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _AnimatedBottomSheet(
        fileName: currentFileName,
        filePath: currentFilePath,
        textContent: textContent,
        onCopyText: (ctx) => _copyTextToClipboard(ctx, textContent),
        onShareText: (ctx) => _shareText(ctx, textContent, currentFileName),
        onShareFile: (ctx) => _shareFile(ctx, currentFilePath, currentFileName),
        onSaveAsCopy: (ctx) =>
            _saveFileAsCopy(ctx, currentFilePath, currentFileName),
        onPrint: (ctx) => _printDocument(ctx, textContent, currentFileName),
      ),
    );
  }
}

class _AnimatedZoomButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AnimatedZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_AnimatedZoomButton> createState() => _AnimatedZoomButtonState();
}

class _AnimatedZoomButtonState extends State<_AnimatedZoomButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: IconButton(
          icon: Icon(widget.icon, color: AppColors.primary),
          onPressed: null, // Handled by GestureDetector
          tooltip: widget.tooltip,
        ),
      ),
    );
  }
}

class _AnimatedBottomSheet extends StatefulWidget {
  final String fileName;
  final String filePath;
  final String textContent;
  final Function(BuildContext) onCopyText;
  final Function(BuildContext) onShareText;
  final Function(BuildContext) onShareFile;
  final Function(BuildContext) onSaveAsCopy;
  final Function(BuildContext) onPrint;

  const _AnimatedBottomSheet({
    required this.fileName,
    required this.filePath,
    required this.textContent,
    required this.onCopyText,
    required this.onShareText,
    required this.onShareFile,
    required this.onSaveAsCopy,
    required this.onPrint,
  });

  @override
  State<_AnimatedBottomSheet> createState() => _AnimatedBottomSheetState();
}

class _AnimatedBottomSheetState extends State<_AnimatedBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, -0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                  ),
                ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.fileName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const Divider(),

          // Menu items with staggered animations
          _buildAnimatedMenuItem(
            index: 0,
            icon: Icons.copy,
            title: 'Copy Text',
            onTap: () => widget.onCopyText(context),
          ),
          _buildAnimatedMenuItem(
            index: 1,
            icon: Icons.share,
            title: 'Share Text',
            onTap: () => widget.onShareText(context),
          ),
          _buildAnimatedMenuItem(
            index: 2,
            icon: Icons.ios_share,
            title: 'Share File',
            onTap: () => widget.onShareFile(context),
          ),
          _buildAnimatedMenuItem(
            index: 3,
            icon: Icons.file_download,
            title: 'Save As Copy',
            onTap: () => widget.onSaveAsCopy(context),
          ),
          _buildAnimatedMenuItem(
            index: 4,
            icon: Icons.print,
            title: 'Print',
            onTap: () => widget.onPrint(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                0.2 + (index * 0.1),
                0.6 + (index * 0.1),
                curve: Curves.easeOut,
              ),
            ),
          ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Interval(
              0.2 + (index * 0.1),
              0.6 + (index * 0.1),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          onTap: onTap,
        ),
      ),
    );
  }
}
