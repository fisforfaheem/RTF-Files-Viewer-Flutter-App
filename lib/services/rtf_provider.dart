import 'package:flutter/foundation.dart';
import 'package:rtf_view/models/rtf_file.dart';
import 'package:rtf_view/services/rtf_service.dart';

class RtfProvider extends ChangeNotifier {
  final RtfService _rtfService = RtfService();

  List<RtfFile> _recentFiles = [];
  RtfFile? _currentFile;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RtfFile> get recentFiles => _recentFiles;
  RtfFile? get currentFile => _currentFile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load recent files
  Future<void> loadRecentFiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recentFiles = await _rtfService.getRecentFiles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open RTF file from path
  Future<void> openRtfFile(String path) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentFile = await _rtfService.loadRtfFile(path);
      await _rtfService.addToRecentFiles(_currentFile!);

      // Refresh recent files list
      await loadRecentFiles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open RTF file from bytes (for web/mobile scenarios)
  Future<void> openRtfFileFromBytes(List<int> bytes, String fileName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentFile = await _rtfService.loadRtfFileFromBytes(bytes, fileName);
      await _rtfService.addToRecentFiles(_currentFile!);

      // Refresh recent files list
      await loadRecentFiles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current file
  void clearCurrentFile() {
    _currentFile = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Parse RTF content
  Future<String> parseRtfContent(String rtfContent) async {
    try {
      return await _rtfService.parseRtfContent(rtfContent);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear recent files
  Future<void> clearRecentFiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _rtfService.clearRecentFiles();
      _recentFiles = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
