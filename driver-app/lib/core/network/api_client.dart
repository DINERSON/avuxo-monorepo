import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const avuxoBackendUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://avuxo-backend-production.up.railway.app',
);

final authTokenProvider = StateProvider<String?>((ref) => null);

final apiClientProvider = Provider<Dio>((ref) {
  final token = ref.watch(authTokenProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: avuxoBackendUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App': 'avuxo-driver',
        'X-Platform': defaultTargetPlatform.name,
      },
      validateStatus: (status) {
        return status != null && status >= 200 && status < 500;
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          debugPrint('');
          debugPrint('🟢 AVUXO DRIVER REQUEST');
          debugPrint('${options.method} ${options.uri}');
          debugPrint('DATA: ${options.data}');
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('');
          debugPrint('✅ AVUXO DRIVER RESPONSE');
          debugPrint(
            '${response.requestOptions.method} ${response.requestOptions.uri}',
          );
          debugPrint('STATUS: ${response.statusCode}');
        }

        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('');
          debugPrint('❌ AVUXO DRIVER ERROR');
          debugPrint(
            '${error.requestOptions.method} ${error.requestOptions.uri}',
          );
          debugPrint('MESSAGE: ${error.message}');
          debugPrint('RESPONSE: ${error.response?.data}');
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});

String _extractErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (data != null && data.toString().trim().isNotEmpty) {
      return data.toString();
    }

    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }

    return 'Erro de conexão.';
  }

  return 'Erro inesperado: $error';
}

Future<Response<dynamic>> safeGet(
  Dio dio,
  String path, {
  Map<String, dynamic>? queryParameters,
}) async {
  try {
    return await dio
        .get(
          path,
          queryParameters: queryParameters,
        )
        .timeout(
          const Duration(seconds: 20),
        );
  } on TimeoutException {
    throw Exception('Tempo de conexão esgotado.');
  } catch (e) {
    throw Exception(_extractErrorMessage(e));
  }
}

Future<Response<dynamic>> safePost(
  Dio dio,
  String path, {
  dynamic data,
}) async {
  try {
    return await dio
        .post(
          path,
          data: data,
        )
        .timeout(
          const Duration(seconds: 20),
        );
  } on TimeoutException {
    throw Exception('Tempo de conexão esgotado.');
  } catch (e) {
    throw Exception(_extractErrorMessage(e));
  }
}

Future<Response<dynamic>> safePut(
  Dio dio,
  String path, {
  dynamic data,
}) async {
  try {
    return await dio
        .put(
          path,
          data: data,
        )
        .timeout(
          const Duration(seconds: 20),
        );
  } on TimeoutException {
    throw Exception('Tempo de conexão esgotado.');
  } catch (e) {
    throw Exception(_extractErrorMessage(e));
  }
}

Future<Response<dynamic>> safeDelete(
  Dio dio,
  String path, {
  dynamic data,
}) async {
  try {
    return await dio
        .delete(
          path,
          data: data,
        )
        .timeout(
          const Duration(seconds: 20),
        );
  } on TimeoutException {
    throw Exception('Tempo de conexão esgotado.');
  } catch (e) {
    throw Exception(_extractErrorMessage(e));
  }
}