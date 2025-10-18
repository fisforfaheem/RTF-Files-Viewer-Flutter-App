import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rtf_view/constants/colors.dart';
import 'package:rtf_view/services/rtf_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  String _parsedTextContent = '';
  double _textSize = 16.0;

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
      if (directory == null) {
        throw Exception('Downloads directory not available');
      }

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

  // Print functionality
  void _printDocument(
    BuildContext context,
    String text,
    String fileName,
  ) async {
    try {
      Navigator.pop(context);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async =>
            await _generatePdf(text, fileName),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error printing document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List> _generatePdf(String text, String fileName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                fileName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(text, style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    return pdf.save();
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
        elevation: 0,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading document...'),
                ],
              ),
            );
          }

          if (rtfProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Error loading file',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(rtfProvider.error!),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (rtfProvider.currentFile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No file selected',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text('Please select an RTF file to view'),
                ],
              ),
            );
          }

          // Display RTF content
          return FutureBuilder<String>(
            future: rtfProvider.parseRtfContent(
              rtfProvider.currentFile!.content!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
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
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Error parsing RTF content',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(snapshot.error.toString()),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                        label: Text('Go Back'),
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
                      Icon(
                        Icons.description_outlined,
                        color: Colors.grey,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No content available',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('This RTF file appears to be empty'),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back),
                        label: Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document header
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
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
                              style: Theme.of(context).textTheme.titleMedium
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
                    const SizedBox(height: 16),
                    // Text size controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.zoom_out),
                          onPressed: _decreaseTextSize,
                          tooltip: 'Decrease text size',
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_in),
                          onPressed: _increaseTextSize,
                          tooltip: 'Increase text size',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Document content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectableText(
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
                      ),
                    ),
                  ],
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
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentFileName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(),

            // Menu items - wrap in Flexible to prevent overflow
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(Icons.copy, color: AppColors.primary),
                    title: const Text('Copy Text'),
                    onTap: () => _copyTextToClipboard(context, textContent),
                  ),
                  ListTile(
                    leading: const Icon(Icons.share, color: AppColors.primary),
                    title: const Text('Share Text'),
                    onTap: () =>
                        _shareText(context, textContent, currentFileName),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.ios_share,
                      color: AppColors.primary,
                    ),
                    title: const Text('Share File'),
                    onTap: () =>
                        _shareFile(context, currentFilePath, currentFileName),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.file_download,
                      color: AppColors.primary,
                    ),
                    title: const Text('Save As Copy'),
                    onTap: () => _saveFileAsCopy(
                      context,
                      currentFilePath,
                      currentFileName,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.print, color: AppColors.primary),
                    title: const Text('Print'),
                    onTap: () =>
                        _printDocument(context, textContent, currentFileName),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
