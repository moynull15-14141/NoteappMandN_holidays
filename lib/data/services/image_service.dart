import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noteapp/core/utils/exceptions.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<String?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        if (bytes.length > 5242880) {
          // 5MB
          throw ImageException(
            message: 'Image size exceeds 5MB limit',
            code: 'IMAGE_TOO_LARGE',
          );
        }

        // For web, convert to base64 data URL
        if (kIsWeb) {
          return 'data:image/jpeg;base64,${base64Encode(bytes)}';
        }

        // For mobile/desktop, save to app directory
        return image.path;
      }
      return null;
    } catch (e) {
      if (e is ImageException) rethrow;
      throw ImageException(
        message: 'Failed to pick image: $e',
        code: 'PICK_IMAGE_ERROR',
      );
    }
  }

  static Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (bytes.length > 5242880) {
          // 5MB
          throw ImageException(
            message: 'Image size exceeds 5MB limit',
            code: 'IMAGE_TOO_LARGE',
          );
        }

        // For web, convert to base64 data URL
        if (kIsWeb) {
          return 'data:image/jpeg;base64,${base64Encode(bytes)}';
        }

        // For mobile/desktop, save to app directory
        return photo.path;
      }
      return null;
    } catch (e) {
      if (e is ImageException) rethrow;
      throw ImageException(
        message: 'Failed to take photo: $e',
        code: 'CAMERA_ERROR',
      );
    }
  }

  static Future<bool> deleteImage(String imagePath) async {
    try {
      // Web uses base64, no file to delete
      if (kIsWeb || imagePath.startsWith('data:')) {
        return true;
      }

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw ImageException(
        message: 'Failed to delete image: $e',
        code: 'DELETE_IMAGE_ERROR',
      );
    }
  }

  static Future<String> saveImageToAppDirectory(String imagePath) async {
    try {
      // Web doesn't need to save, already in memory
      if (kIsWeb) {
        return imagePath;
      }

      final file = File(imagePath);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedFile = await file.copy('${appDir.path}/$fileName.jpg');
      return savedFile.path;
    } catch (e) {
      throw ImageException(
        message: 'Failed to save image: $e',
        code: 'SAVE_IMAGE_ERROR',
      );
    }
  }
}
