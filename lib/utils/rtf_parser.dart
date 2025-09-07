import 'dart:convert';

class RtfParser {
  // Singleton instance
  static final RtfParser _instance = RtfParser._internal();
  factory RtfParser() => _instance;
  RtfParser._internal();

  /// Parse RTF content and return a result with plain text and formatting information
  Future<RtfParseResult> parse(String rtfContent) async {
    try {
      // Basic RTF parsing implementation
      // This is a simplified version that extracts plain text from RTF
      String plainText = _extractPlainText(rtfContent);
      
      return RtfParseResult(
        plainText: plainText,
        hasImages: rtfContent.contains('\\pict'),
        hasFormatting: _hasFormatting(rtfContent),
      );
    } catch (e) {
      throw Exception('Failed to parse RTF content: $e');
    }
  }

  /// Extract plain text from RTF content with improved formatting handling
  String _extractPlainText(String rtfContent) {
    // Remove RTF control words and groups
    String text = rtfContent;
    
    // Skip RTF header
    if (text.startsWith('{\\rtf1')) {
      int headerEnd = text.indexOf('\\');
      if (headerEnd > 0) {
        text = text.substring(headerEnd);
      }
    }
    
    // Handle paragraph breaks before removing control words
    text = text.replaceAll('\\par', '\n\n');
    text = text.replaceAll('\\line', '\n');
    
    // Handle tabs
    text = text.replaceAll('\\tab', '\t');
    
    // Remove control words (\word)
    text = text.replaceAll(RegExp(r'\\[a-zA-Z0-9]+'), ' ');
    
    // Remove control symbols (\;)
    text = text.replaceAll(RegExp(r'\\[^a-zA-Z0-9]'), ' ');
    
    // Remove curly braces but preserve content structure
    text = _removeCurlyBraces(text);
    
    // Handle special characters
    text = _handleSpecialCharacters(text);
    
    // Remove extra whitespace but preserve paragraph breaks
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n[ \t]+'), '\n');
    text = text.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.trim();
    
    return text;
  }
  
  /// Remove curly braces while preserving content structure
  String _removeCurlyBraces(String text) {
    // Simple braces removal for now
    // A more sophisticated approach would track nesting levels
    return text.replaceAll('{', '').replaceAll('}', '');
  }

  /// Handle special RTF characters with improved support
  String _handleSpecialCharacters(String text) {
    // Handle Unicode characters
    text = text.replaceAllMapped(
      RegExp(r'\\u([0-9]+)\?'),
      (match) {
        int charCode = int.parse(match.group(1)!);
        return String.fromCharCode(charCode);
      },
    );
    
    // Handle common RTF escape sequences with expanded character support
    final replacements = {
      '\\par': '\n',
      '\\tab': '\t',
      '\\line': '\n',
      '\\bullet': '•',
      '\\endash': '–',
      '\\emdash': '—',
      '\\lquote': ''', // left single quote
      '\\rquote': ''', // right single quote
      '\\ldblquote': '"', // left double quote
      '\\rdblquote': '"', // right double quote
      '\\~': ' ', // non-breaking space
      '\\-': '-', // optional hyphen
      '\\_': '_', // non-breaking hyphen
      '\\:': '', // optional line break
      '\\\\': '\\', // backslash
      '\\{': '{', // opening brace
      '\\}': '}', // closing brace
    };
    
    replacements.forEach((key, value) {
      text = text.replaceAll(key, value);
    });
    
    return text;
  }

  /// Check if RTF content has formatting
  bool _hasFormatting(String rtfContent) {
    // Check for common formatting control words
    final formattingPatterns = [
      r'\\b\d*', // bold
      r'\\i\d*', // italic
      r'\\ul\d*', // underline
      r'\\strike\d*', // strikethrough
      r'\\cf\d+', // foreground color
      r'\\cb\d+', // background color
      r'\\fs\d+', // font size
      r'\\f\d+', // font
    ];
    
    for (final pattern in formattingPatterns) {
      if (RegExp(pattern).hasMatch(rtfContent)) {
        return true;
      }
    }
    
    return false;
  }
}

class RtfParseResult {
  final String plainText;
  final bool hasImages;
  final bool hasFormatting;

  RtfParseResult({
    required this.plainText,
    this.hasImages = false,
    this.hasFormatting = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'plainText': plainText,
      'hasImages': hasImages,
      'hasFormatting': hasFormatting,
    };
  }

  factory RtfParseResult.fromJson(Map<String, dynamic> json) {
    return RtfParseResult(
      plainText: json['plainText'] as String,
      hasImages: json['hasImages'] as bool,
      hasFormatting: json['hasFormatting'] as bool,
    );
  }
}