class RtfFile {
  final String name;
  final String path;
  final int size; // in bytes
  final DateTime lastModified;
  final String? content;

  RtfFile({
    required this.name,
    required this.path,
    required this.size,
    required this.lastModified,
    this.content,
  });

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(0)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }

  factory RtfFile.fromJson(Map<String, dynamic> json) {
    return RtfFile(
      name: json['name'],
      path: json['path'],
      size: json['size'],
      lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified']),
    );
  }
}