import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient({String? token})
      : _dio = Dio(
          BaseOptions(
            baseUrl: const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'https://avuxo-backend-production.up.railway.app',
            ),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            validateStatus: (status) {
              return status != null && status >= 200 && status < 500;
            },
          ),
        ) {
    _setupInterceptors();
  }

  final Dio _dio;

  Dio get instance => _dio;

  void setToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }

    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('');
          debugPrint('🚀 PASSENGER REQUEST');
          debugPrint('${options.method} ${options.uri}');
          debugPrint('DATA: ${options.data}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('');
          debugPrint('✅ PASSENGER RESPONSE');
          debugPrint(
            '${response.requestOptions.method} ${response.requestOptions.uri}',
          );
          debugPrint('STATUS: ${response.statusCode}');
          debugPrint('DATA: ${response.data}');

          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('');
          debugPrint('❌ PASSENGER DIO ERROR');
          debugPrint('${error.requestOptions.method} ${error.requestOptions.uri}');
          debugPrint('MESSAGE: ${error.message}');
          debugPrint('RESPONSE: ${error.response?.data}');

          handler.next(error);
        },
      ),
    );
  }
}

Future<Response<dynamic>> safeGet(
  Dio dio,
  String path, {
  Map<String, dynamic>? queryParameters,
}) async {
  try {
    return await dio.get(
      path,
      queryParameters: queryParameters,
    );
  } on TimeoutException {
    throw Exception('Tempo de conexão esgotado.');
  } on DioException catch (e) {
    throw Exception(
      e.response?.data?.toString() ??
          e.message ??
          'Erro de conexão.',
    );
  } catch (e) {
    throw Exception('Erro inesperado: $e');
  }
}

Future<Response<dynamic>> safePost(
  Dio dio,
  String path, {
  dynamic data,
}) async {
  try {
    return await dio.post(
      path,
      data: data,
    );
  } on TimeoutException {
    throw Exception('Tempo de conexão esgotado.');
  } on DioException catch (e) {
    throw Exception(
      e.response?.data?.toString() ??
          e.message ??
          'Erro de conexão.',
    );
  } catch (e) {
    throw Exception('Erro inesperado: $e');
  }
}