import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ImageUploader {
  /// Uploads a local image file to catbox.moe anonymously
  /// Returns the permanent public direct URL of the uploaded image, or null if failed.
  static Future<String?> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('ImageUploader: File does not exist at $filePath');
        return null;
      }

      final uri = Uri.parse('https://catbox.moe/user/api.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['reqtype'] = 'fileupload';
      request.files.add(
        await http.MultipartFile.fromPath('fileToUpload', filePath),
      );

      debugPrint('ImageUploader: Uploading $filePath to Catbox.moe...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final imageUrl = response.body.trim();
        debugPrint('ImageUploader: Upload success, URL: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('ImageUploader: Upload failed with status code: ${response.statusCode}, body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('ImageUploader: Error uploading image: $e');
      return null;
    }
  }
}
