import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class DriverRegistrationService {
  static const int maxPdfSize =
      10 * 1024 * 1024;

  static const int maxImageSize =
      8 * 1024 * 1024;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          'https://avuxo-backend-production.up.railway.app',
      connectTimeout:
          const Duration(seconds: 60),
      receiveTimeout:
          const Duration(seconds: 180),
      sendTimeout:
          const Duration(seconds: 180),
      validateStatus: (status) =>
          status != null && status < 500,
    ),
  );

  Future<void> dispose() async {
    dio.close(force: true);
  }

  Future<String> _imageToCompressedBase64(
    File? file,
  ) async {
    if (file == null) {
      return '';
    }

    if (!await file.exists()) {
      return '';
    }

    final length =
        await file.length();

    if (length > maxImageSize) {
      throw Exception(
        'Imagem acima de 8MB.',
      );
    }

    try {
      final compressedBytes =
          await FlutterImageCompress
              .compressWithFile(
        file.absolute.path,
        minWidth: 900,
        minHeight: 900,
        quality: 45,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null ||
          compressedBytes.isEmpty) {
        return '';
      }

      return 'data:image/jpeg;base64,${base64Encode(compressedBytes)}';
    } catch (_) {
      throw Exception(
        'Falha ao processar imagem.',
      );
    }
  }

  Future<String> _pdfToBase64(
    File? file,
  ) async {
    if (file == null) {
      return '';
    }

    if (!await file.exists()) {
      return '';
    }

    final length =
        await file.length();

    if (length > maxPdfSize) {
      throw Exception(
        'PDF acima de 10MB.',
      );
    }

    final bytes =
        await file.readAsBytes();

    if (bytes.isEmpty) {
      return '';
    }

    return 'data:application/pdf;base64,${base64Encode(bytes)}';
  }
  Future<String> _pdfOrCompressedImageToBase64(
    File? file,
  ) async {
    if (file == null) {
      return '';
    }

    if (_isPdf(file)) {
      return _pdfToBase64(file);
    }

    return _imageToCompressedBase64(file);
  }

  String _safeText(
    String value,
    String fieldName,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      throw Exception('$fieldName obrigatório.');
    }

    return text;
  }

  String _safeOptionalText(
    String value,
  ) {
    return value.trim();
  }

  String _safeEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      throw Exception('E-mail obrigatório.');
    }

    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('E-mail inválido.');
    }

    return email;
  }

  String _safePhone(String value) {
    final phone = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (phone.isEmpty) {
      throw Exception('Telefone obrigatório.');
    }

    if (phone.length < 10) {
      throw Exception('Telefone inválido.');
    }

    return phone;
  }

  String _safePlate(String value) {
    final plate = value
        .trim()
        .toUpperCase()
        .replaceAll('-', '')
        .replaceAll(' ', '');

    if (plate.isEmpty) {
      throw Exception('Placa obrigatória.');
    }

    if (plate.length < 7) {
      throw Exception('Placa inválida.');
    }

    return plate;
  }

  Future<void> registerDriver({
    required String fullName,
    required String email,
    required String phone,
    required String carBrand,
    required String carModel,
    required String carPlate,
    required String carColor,
    required String carYear,
    required String carSeats,
    required String renavam,
    required bool rentedVehicle,
    required File? idDoc,
    required File? selfie,
    required File? cnhFront,
    required File? cnhBack,
    required File? vehicleDocumentPdf,
    required File? carFront,
    required File? carSide,
    required File? carBack,
  }) async {
    final safeFullName = _safeText(
      fullName,
      'Nome completo',
    );

    final safeEmail = _safeEmail(email);
    final safePhone = _safePhone(phone);

    final safeCarBrand = _safeText(
      carBrand,
      'Marca do veículo',
    );

    final safeCarModel = _safeText(
      carModel,
      'Modelo do veículo',
    );

    final safeCarPlate = _safePlate(carPlate);

    final safeCarColor = _safeText(
      carColor,
      'Cor do veículo',
    );

    final safeCarYear = _safeText(
      carYear,
      'Ano do veículo',
    );

    final safeCarSeats = _safeText(
      carSeats,
      'Quantidade de lugares',
    );

    final safeRenavam = _safeOptionalText(
      renavam,
    );
    try {
      final documentPhoto =
          await _imageToCompressedBase64(
        idDoc,
      );

      final driverPhoto =
          await _imageToCompressedBase64(
        selfie,
      );

      final cnhFrontFile =
          await _pdfOrCompressedImageToBase64(
        cnhFront,
      );

      final cnhBackFile =
          await _pdfOrCompressedImageToBase64(
        cnhBack,
      );

      final vehicleDocumentFile =
          await _pdfOrCompressedImageToBase64(
        vehicleDocumentPdf,
      );

      final vehiclePhoto =
          await _imageToCompressedBase64(
        carFront,
      );

      final vehicleSidePhoto =
          await _imageToCompressedBase64(
        carSide,
      );

      final vehicleBackPhoto =
          await _imageToCompressedBase64(
        carBack,
      );

      final response = await dio.post(
        '/drivers/register',
        data: {
          'fullName': safeFullName,
          'name': safeFullName,
          'email': safeEmail,
          'phone': safePhone,
          'carBrand': safeCarBrand,
          'brand': safeCarBrand,
          'carModel': safeCarModel,
          'model': safeCarModel,
          'carPlate': safeCarPlate,
          'plate': safeCarPlate,
          'carColor': safeCarColor,
          'color': safeCarColor,
          'carYear': safeCarYear,
          'year': safeCarYear,
          'carSeats': safeCarSeats,
          'seats': safeCarSeats,
          'renavam': safeRenavam,
          'rentedVehicle': rentedVehicle,
          'rating': 5,
          'driverPhoto': driverPhoto,
          'photo': driverPhoto,
          'profilePhoto': driverPhoto,
          'documentPhoto': documentPhoto,
          'idDocPhoto': documentPhoto,
          'identityPhoto': documentPhoto,
          'cnhFront': cnhFrontFile,
          'cnhFrontPhoto': cnhFrontFile,
          'licenseFrontPhoto': cnhFrontFile,
          'cnhBack': cnhBackFile,
          'cnhBackPhoto': cnhBackFile,
          'licenseBackPhoto': cnhBackFile,
          'licensePhoto': cnhFrontFile,
          'cnhPhoto': cnhFrontFile,
          'vehicleDocumentPdf': vehicleDocumentFile,
          'vehicleDocumentPhoto': vehicleDocumentFile,
          'carDocumentPdf': vehicleDocumentFile,
          'documentCarPhoto': vehicleDocumentFile,
          'vehiclePhoto': vehiclePhoto,
          'carPhoto': vehiclePhoto,
          'vehicleFrontPhoto': vehiclePhoto,
          'vehicleSidePhoto': vehicleSidePhoto,
          'carSidePhoto': vehicleSidePhoto,
          'vehicleBackPhoto': vehicleBackPhoto,
          'carBackPhoto': vehicleBackPhoto,
        },
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 180),
          receiveTimeout: const Duration(seconds: 180),
        ),
      );

      final data = response.data;

      if ((response.statusCode == 200 ||
              response.statusCode == 201) &&
          data is Map &&
          data['success'] == true) {
        return;
      }

      throw Exception(
        data is Map
            ? data['message']?.toString() ??
                data['error']?.toString() ??
                'Falha no cadastro.'
            : data?.toString() ?? 'Falha no cadastro.',
      );
    }
    on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('==============================');
        debugPrint('DIO ERROR');
        debugPrint('STATUS: ${e.response?.statusCode}');
        debugPrint('DATA: ${e.response?.data}');
        debugPrint('MESSAGE: ${e.message}');
        debugPrint('==============================');
      }

      final responseData = e.response?.data;

      if (responseData is Map) {
        final message =
            '${responseData['message'] ?? responseData['error'] ?? ''}'
                .trim();

        if (message.isNotEmpty) {
          throw Exception(message);
        }
      }

      throw Exception(
        e.message ?? 'Falha de conexão com o backend AVUXO.',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  bool _isPdf(File? file) {
    if (file == null) {
      return false;
    }

    return file.path.toLowerCase().endsWith('.pdf');
  }
}