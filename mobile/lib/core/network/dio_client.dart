import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'secure_token_storage.dart';

/// Bagian 14 & 30: Dio client, interceptor auth, retry, dan Idempotency-Key
class DioClient {
  final Dio dio;
  final SecureTokenStorage tokenStorage;
  bool _isRefreshing = false;

  DioClient({
    required this.tokenStorage,
    Dio? customDio,
  }) : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.apiBaseUrl,
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Add Idempotency-Key for POST requests that award XP (Section 30)
          if (options.method.toUpperCase() == 'POST' &&
              !options.headers.containsKey('Idempotency-Key')) {
            options.headers['Idempotency-Key'] =
                'idem_${DateTime.now().microsecondsSinceEpoch}';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          // AC-02 & Bagian 36: Refresh token otomatis sekali saat 401
          if (error.response?.statusCode == 401 &&
              !_isRefreshing &&
              !error.requestOptions.path.contains('/auth/refresh') &&
              !error.requestOptions.path.contains('/auth/login')) {
            _isRefreshing = true;
            try {
              final refreshToken = await tokenStorage.getRefreshToken();
              if (refreshToken != null) {
                final refreshRes = await dio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );
                final data = refreshRes.data['data'] as Map<String, dynamic>?;
                if (data != null && data['access_token'] != null) {
                  final newAccess = data['access_token'] as String;
                  final newRefresh =
                      (data['refresh_token'] as String?) ?? refreshToken;
                  final userId = await tokenStorage.getUserId() ?? '';
                  await tokenStorage.saveTokens(
                    accessToken: newAccess,
                    refreshToken: newRefresh,
                    userId: userId,
                  );
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newAccess';
                  _isRefreshing = false;
                  final retryResponse = await dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (_) {
              await tokenStorage.clearTokens();
            } finally {
              _isRefreshing = false;
            }
          }
          handler.next(error);
        },
      ),
    );
  }
}

