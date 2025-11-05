import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/media/media_attachment.dart';
import '../../models/media/media_enums.dart';

class MediaUploadService {
  final Dio _dio;
  final String baseUrl;
  final ImagePicker _imagePicker = ImagePicker();

  MediaUploadService({
    required this.baseUrl,
    required Dio dio,
  }) : _dio = dio;

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request photo library permission
  Future<bool> requestPhotosPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  // Pick image from camera or gallery
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      // Request appropriate permission
      bool hasPermission;
      if (source == ImageSource.camera) {
        hasPermission = await requestCameraPermission();
      } else {
        hasPermission = await requestPhotosPermission();
      }

      if (!hasPermission) {
        throw Exception('Permission denied. Please grant access in Settings.');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      rethrow;
    }
  }

  // Pick multiple images
  Future<List<File>> pickMultipleImages({int maxImages = 10}) async {
    try {
      final hasPermission = await requestPhotosPermission();
      if (!hasPermission) {
        throw Exception('Permission denied. Please grant access in Settings.');
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (images.length > maxImages) {
        throw Exception('Maximum $maxImages images allowed');
      }

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      rethrow;
    }
  }

  // Crop image
  Future<File?> cropImage({
    required File imageFile,
    CropStyle cropStyle = CropStyle.rectangle,
    List<CropAspectRatioPreset> aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ],
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        cropStyle: cropStyle,
        aspectRatioPresets: aspectRatioPresets,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF2196F3),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      debugPrint('Error cropping image: $e');
      rethrow;
    }
  }

  // Pick video from gallery
  Future<File?> pickVideo({int maxDurationSeconds = 300}) async {
    try {
      final hasPermission = await requestPhotosPermission();
      if (!hasPermission) {
        throw Exception('Permission denied. Please grant access in Settings.');
      }

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(seconds: maxDurationSeconds),
      );

      if (video == null) return null;
      return File(video.path);
    } catch (e) {
      debugPrint('Error picking video: $e');
      rethrow;
    }
  }

  // Upload single image
  Future<UploadResponse> uploadImage({
    required File file,
    required MediaCategory category,
    String? entityId,
    Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'category': category.toJson(),
        if (entityId != null) 'entityId': entityId,
      });

      final response = await _dio.post(
        '$baseUrl/media/upload/image',
        data: formData,
        onSendProgress: onProgress,
      );

      return UploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error uploading image: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // Upload single video
  Future<UploadResponse> uploadVideo({
    required File file,
    required MediaCategory category,
    String? entityId,
    Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'category': category.toJson(),
        if (entityId != null) 'entityId': entityId,
      });

      final response = await _dio.post(
        '$baseUrl/media/upload/video',
        data: formData,
        onSendProgress: onProgress,
      );

      return UploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error uploading video: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // Upload multiple files (batch)
  Future<BatchUploadResponse> uploadBatch({
    required List<File> files,
    required MediaCategory category,
    String? entityId,
    Function(int, int)? onProgress,
  }) async {
    try {
      if (files.length > 10) {
        throw Exception('Maximum 10 files allowed per batch upload');
      }

      final formData = FormData.fromMap({
        'files': await Future.wait(
          files.map((file) => MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              )),
        ),
        'category': category.toJson(),
        if (entityId != null) 'entityId': entityId,
      });

      final response = await _dio.post(
        '$baseUrl/media/upload/batch',
        data: formData,
        onSendProgress: onProgress,
      );

      return BatchUploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error uploading batch: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // Delete media file
  Future<void> deleteMedia(String mediaId) async {
    try {
      await _dio.delete('$baseUrl/media/$mediaId');
    } on DioException catch (e) {
      debugPrint('Error deleting media: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // Get user media by category
  Future<List<MediaAttachment>> getUserMedia({
    required String userId,
    required MediaCategory category,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/media/$userId/${category.toJson()}',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'order': order,
        },
      );

      final List<dynamic> mediaList = response.data['media'];
      return mediaList
          .map((json) => MediaAttachment.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint('Error fetching media: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // Build full URL for media files
  String getMediaUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http')) {
      return relativeUrl;
    }
    return '$baseUrl/uploads$relativeUrl';
  }

  // Handle Dio errors
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      if (statusCode == 400) {
        // Validation errors
        if (data is Map && data.containsKey('errors')) {
          final errors = (data['errors'] as List).join('; ');
          return Exception('Validation failed: $errors');
        }
        return Exception(data['message'] ?? 'Invalid request');
      } else if (statusCode == 401) {
        return Exception('Unauthorized. Please login again.');
      } else if (statusCode == 403) {
        return Exception('Access denied.');
      } else if (statusCode == 413) {
        return Exception('File too large. Please select a smaller file.');
      } else if (statusCode == 500) {
        return Exception('Server error. Please try again later.');
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Check your internet connection.');
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection.');
    }

    return Exception('Upload failed. Please try again.');
  }
}
