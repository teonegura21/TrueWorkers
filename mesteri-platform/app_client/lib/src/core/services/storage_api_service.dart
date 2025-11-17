import '../network/api_client.dart';
import '../models/conversation_models.dart';

class StorageApiService {
  StorageApiService._();
  static final StorageApiService instance = StorageApiService._();
  final ApiClient _client = ApiClient.instance;

  Future<SignedUrlResponse> requestUpload({
    required String fileName,
    required String contentType,
    String? entityType,
    String? entityId,
  }) async {
    final response = await _client.post(
      '/storage/signed-url',
      data: {
        'fileName': fileName,
        'contentType': contentType,
        if (entityType != null) 'entityType': entityType,
        if (entityId != null) 'entityId': entityId,
      },
    );
    return SignedUrlResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
