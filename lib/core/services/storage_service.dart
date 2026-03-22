import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final _client = Supabase.instance.client;
  static const String bucketName = 'listings';

  /// Uploads multiple files and returns their public URLs
  Future<List<String>> uploadImages(List<XFile> images) async {
    final List<String> urls = [];
    
    for (final image in images) {
      final url = await uploadFile(image);
      if (url != null) urls.add(url);
    }
    
    return urls;
  }

  /// Uploads a single file (Photo or Video)
  Future<String?> uploadFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final extension = p.extension(file.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final filePath = 'public/$fileName';

      await _client.storage.from(bucketName).uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(contentType: _getContentType(extension)),
      );

      final publicUrl = _client.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Storage error: $e');
      return null;
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg': return 'image/jpeg';
      case '.png': return 'image/png';
      case '.gif': return 'image/gif';
      case '.mp4': return 'video/mp4';
      case '.mov': return 'video/quicktime';
      default: return 'application/octet-stream';
    }
  }
}
