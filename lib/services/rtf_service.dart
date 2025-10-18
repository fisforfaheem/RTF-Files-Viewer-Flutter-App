import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:rtf_view/models/rtf_file.dart';
import 'package:rtf_view/utils/rtf_parser.dart';

class RtfService {
  // Singleton instance
  static final RtfService _instance = RtfService._internal();
  factory RtfService() => _instance;
  RtfService._internal();

  // Parse RTF content with fallback mechanism
  Future<String> parseRtfContent(String rtfContent) async {
    try {
      final parser = RtfParser();
      final result = await parser.parse(rtfContent);

      // Check if the parsed content is valid
      if (result.plainText.trim().isEmpty) {
        // Fallback to basic extraction if formatted parsing fails
        return _extractBasicText(rtfContent);
      }

      return result.plainText;
    } catch (e) {
      // If parsing with formatting fails, try basic extraction as fallback
      try {
        return _extractBasicText(rtfContent);
      } catch (innerException) {
        throw Exception('Failed to parse RTF content: $e');
      }
    }
  }

  // Basic text extraction fallback
  String _extractBasicText(String rtfContent) {
    // Remove RTF control words and groups
    String text = rtfContent;

    // Remove header
    if (text.startsWith('{\\rtf1')) {
      int headerEnd = text.indexOf('\\');
      if (headerEnd > 0) {
        text = text.substring(headerEnd);
      }
    }

    // Remove control words (\word)
    text = text.replaceAll(RegExp(r'\\[a-zA-Z0-9]+'), ' ');

    // Remove control symbols (\;)
    text = text.replaceAll(RegExp(r'\\[^a-zA-Z0-9]'), ' ');

    // Remove curly braces
    text = text.replaceAll('{', ' ').replaceAll('}', ' ');

    // Remove extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  // Parse RTF content with formatting information
  Future<RtfParseResult> parseRtfContentWithFormatting(
    String rtfContent,
  ) async {
    try {
      final parser = RtfParser();
      return await parser.parse(rtfContent);
    } catch (e) {
      throw Exception('Failed to parse RTF content with formatting: $e');
    }
  }

  // Load RTF file from path
  Future<RtfFile> loadRtfFile(String path) async {
    try {
      final file = File(path);
      final fileStats = await file.stat();
      final fileName = path.split('/').last;
      final content = await file.readAsString();

      return RtfFile(
        name: fileName,
        path: path,
        size: fileStats.size,
        lastModified: fileStats.modified,
        content: content,
      );
    } catch (e) {
      throw Exception('Failed to load RTF file: $e');
    }
  }

  // Load RTF file from bytes (for web/mobile scenarios where file path is not available)
  Future<RtfFile> loadRtfFileFromBytes(List<int> bytes, String fileName) async {
    try {
      // Decode bytes to string
      final content = utf8.decode(bytes);

      return RtfFile(
        name: fileName,
        path: '', // Empty path for byte-based files
        size: bytes.length,
        lastModified: DateTime.now(), // Current time for new files
        content: content,
      );
    } catch (e) {
      throw Exception('Failed to load RTF file from bytes: $e');
    }
  }

  // Get recent files
  Future<List<RtfFile>> getRecentFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recentFilesDir = Directory('${directory.path}/recent_files');

      if (!await recentFilesDir.exists()) {
        await recentFilesDir.create(recursive: true);
        return [];
      }

      final files = await recentFilesDir.list().toList();
      final rtfFiles = <RtfFile>[];

      for (var fileEntity in files) {
        if (fileEntity is File &&
            fileEntity.path.toLowerCase().endsWith('.rtf')) {
          final fileStats = await fileEntity.stat();
          final content = await fileEntity.readAsString();
          rtfFiles.add(
            RtfFile(
              name: fileEntity.path.split('/').last,
              path: fileEntity.path,
              size: fileStats.size,
              lastModified: fileStats.modified,
              content: content,
            ),
          );
        }
      }

      // Sort by last modified (most recent first)
      rtfFiles.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      return rtfFiles;
    } catch (e) {
      throw Exception('Failed to get recent files: $e');
    }
  }

  // Add file to recent files
  Future<void> addToRecentFiles(RtfFile file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recentFilesDir = Directory('${directory.path}/recent_files');

      if (!await recentFilesDir.exists()) {
        await recentFilesDir.create(recursive: true);
      }

      // Copy file to recent files directory if it's not already there
      final destinationPath = '${recentFilesDir.path}/${file.name}';
      if (file.path != destinationPath) {
        await File(file.path).copy(destinationPath);
      }
    } catch (e) {
      throw Exception('Failed to add file to recent files: $e');
    }
  }

  // Clear all recent files
  Future<void> clearRecentFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recentFilesDir = Directory('${directory.path}/recent_files');

      if (await recentFilesDir.exists()) {
        await recentFilesDir.delete(recursive: true);
        await recentFilesDir.create(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to clear recent files: $e');
    }
  }
}
