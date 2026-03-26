import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:vinta/core/services/supabase_service.dart';

class StorageService {
  SupabaseClient? get _client =>
      SupabaseService.isInitialized ? SupabaseService.client : null;
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

  /// Uploads a single file (Photo or Video) with optional compression
  Future<String?> uploadFile(XFile file) async {
    try {
      final client = _client;
      if (client == null) return null;

      final extension = p.extension(file.path).toLowerCase();
      final isImage = ['.jpg', '.jpeg', '.png'].contains(extension);

      List<int> bytes;
      if (isImage) {
        // Compress image
        final tempDir = await getTemporaryDirectory();
        final targetPath = p.join(tempDir.path, "compressed_${DateTime.now().millisecondsSinceEpoch}$extension");
        
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.path,
          targetPath,
          quality: 70,
          minWidth: 1024,
          minHeight: 1024,
        );
        
        if (compressedFile != null) {
          bytes = await File(compressedFile.path).readAsBytes();
        } else {
          bytes = await file.readAsBytes();
        }
      } else {
        bytes = await file.readAsBytes();
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final filePath = 'public/$fileName';

      await client.storage.from(bucketName).uploadBinary(
            filePath,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(contentType: _getContentType(extension)),
          );

      final publicUrl = client.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Storage error: $e');
      return null;
    }
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }
}
