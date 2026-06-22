import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/local_storage.dart';

class DriverVehicleScreen extends StatefulWidget {
  const DriverVehicleScreen({super.key});

  @override
  State<DriverVehicleScreen> createState() =>
      _DriverVehicleScreenState();
}

class _DriverVehicleScreenState
    extends State<DriverVehicleScreen> {
  static const Color avuxoGreen =
      Color(0xFF24F877);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          'https://avuxo-backend-production.up.railway.app',
      connectTimeout:
          const Duration(seconds: 12),
      receiveTimeout:
          const Duration(seconds: 12),
      validateStatus: (status) =>
          status != null && status < 500,
    ),
  );

  bool loading = true;
  bool _loadingVehicle = false;

  String? error;

  Map<String, dynamic> vehicle = {};
  Map<String, dynamic> driver = {};

  @override
  void initState() {
    super.initState();
    _loadVehicle();
  }

  @override
  void dispose() {
    dio.close(force: true);
    super.dispose();
  }

  Future<void> _loadVehicle() async {
    if (_loadingVehicle) return;

    _loadingVehicle = true;

    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final phone =
          await LocalStorage().getPhone();

      if (!mounted) return;

      if (phone == null ||
          phone.trim().isEmpty) {
        setState(() {
          error =
              'Telefone do motorista não encontrado.';
          loading = false;
        });
        return;
      }

      final normalizedPhone =
          phone.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final profileResponse =
          await dio.get(
        '/drivers/status/$normalizedPhone',
      );

      if (!mounted) return;

      final profileData =
          profileResponse.data;

      if (profileData is! Map ||
          profileData['found'] != true ||
          profileData['driver'] is! Map) {
        setState(() {
          error =
              'Motorista não encontrado.';
          loading = false;
        });
        return;
      }

      final driverData =
          Map<String, dynamic>.from(
        profileData['driver'],
      );

      final driverId =
          '${driverData['id'] ?? ''}'
              .trim();

      if (driverId.isEmpty) {
        setState(() {
          error =
              'ID do motorista não veio do backend.';
          loading = false;
        });
        return;
      }

      final response =
          await dio.get(
        '/driver/vehicle/$driverId',
      );

      if (!mounted) return;

      final data = response.data;

      if (data is! Map ||
          data['success'] != true ||
          data['vehicle'] is! Map) {
        setState(() {
          error =
              'Não foi possível carregar o veículo.';
          loading = false;
        });
        return;
      }
      setState(() {
        driver = driverData;
        vehicle = Map<String, dynamic>.from(
          data['vehicle'],
        );
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'Erro de conexão com o backend.';
        loading = false;
      });
    } finally {
      _loadingVehicle = false;
    }
  }

  String _text(
    dynamic value, {
    String fallback = 'Não informado',
  }) {
    final text = '${value ?? ''}'.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  ImageProvider? _imageProvider(dynamic value) {
    final photo = '${value ?? ''}'.trim();

    if (photo.isEmpty) return null;

    if (photo.startsWith('http://') ||
        photo.startsWith('https://')) {
      return NetworkImage(photo);
    }

    try {
      final base64Only = photo.contains(',')
          ? photo.split(',').last
          : photo;

      return MemoryImage(
        base64Decode(base64Only),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = _text(
      vehicle['brand'] ?? driver['carBrand'],
    );

    final model = _text(
      vehicle['model'] ?? driver['carModel'],
    );

    final plate = _text(
      vehicle['plate'] ?? driver['carPlate'],
    );

    final color = _text(
      vehicle['color'] ?? driver['carColor'],
    );

    final year = _text(
      vehicle['year'] ?? driver['carYear'],
    );

    final seats = _text(
      driver['carSeats'],
    );

    final renavam = _text(
      vehicle['renavam'] ?? driver['renavam'],
    );

    final vehicleTitle = [
      model == 'Não informado' ? '' : model,
      color == 'Não informado' ? '' : color,
    ].where((e) => e.trim().isNotEmpty).join(' ');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1117),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Meu Veículo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loading || _loadingVehicle
                ? null
                : _loadVehicle,
            icon: const Icon(
              Icons.refresh,
              color: avuxoGreen,
            ),
          ),
        ],
      ),
      body: _body(
        brand: brand,
        model: model,
        plate: plate,
        color: color,
        year: year,
        seats: seats,
        renavam: renavam,
        vehicleTitle: vehicleTitle.isEmpty
            ? 'Veículo AVUXO'
            : vehicleTitle,
      ),
    );
  }

  Widget _body({
    required String brand,
    required String model,
    required String plate,
    required String color,
    required String year,
    required String seats,
    required String renavam,
    required String vehicleTitle,
  }) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: avuxoGreen,
          strokeWidth: 2.8,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error!,
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    final vehiclePhoto = _imageProvider(
      driver['vehiclePhoto'],
    );

    final frontPhoto = _imageProvider(
      driver['vehiclePhoto'],
    );

    final sidePhoto = _imageProvider(
      driver['vehicleSidePhoto'],
    );

    final backPhoto = _imageProvider(
      driver['vehicleBackPhoto'],
    );
    return SafeArea(
      child: RepaintBoundary(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: avuxoGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: avuxoGreen.withAlpha(56),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20),
                        color: Colors.black.withAlpha(20),
                        image: vehiclePhoto != null
                            ? DecorationImage(
                                image: vehiclePhoto,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: vehiclePhoto == null
                          ? const Center(
                              child: Icon(
                                Icons
                                    .directions_car_rounded,
                                size: 80,
                                color: Colors.black,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vehicleTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Veículo aprovado',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _item(
                Icons.factory_rounded,
                'Marca',
                brand,
              ),

              _item(
                Icons.directions_car,
                'Modelo',
                model,
              ),

              _item(
                Icons.confirmation_number,
                'Placa',
                plate,
              ),

              _item(
                Icons.palette,
                'Cor',
                color,
              ),

              _item(
                Icons.calendar_month,
                'Ano',
                year,
              ),

              _item(
                Icons.event_seat,
                'Lugares',
                seats,
              ),

              _item(
                Icons.badge_rounded,
                'Renavam',
                renavam,
              ),

              _item(
                Icons.verified,
                'Status',
                'Aprovado',
              ),

              const SizedBox(height: 22),

              _sectionTitle('Documentos'),

              _docCard(
                'CRLV',
                _text(
                  driver['vehicleDocumentPdf'] ??
                      driver[
                          'vehicleDocumentPhoto'],
                  fallback: '',
                ).isEmpty
                    ? 'Documento do veículo não enviado'
                    : 'Documento do veículo enviado',
              ),

              _docCard(
                'CNH',
                _text(
                  driver['licensePhoto'] ??
                      driver[
                          'cnhFrontPhoto'],
                  fallback: '',
                ).isEmpty
                    ? 'Carteira de motorista não enviada'
                    : 'Carteira de motorista enviada',
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'Fotos do veículo',
              ),

              Row(
                children: [
                  Expanded(
                    child: _PhotoBox(
                      label: 'Frente',
                      image: frontPhoto,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _PhotoBox(
                      label: 'Lateral',
                      image: sidePhoto,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _PhotoBox(
                      label: 'Traseira',
                      image: backPhoto,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141C25),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withAlpha(10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: avuxoGreen,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docCard(
    String title,
    String subtitle,
  ) {
    final sent =
        !subtitle.toLowerCase().contains(
      'não',
    );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141C25),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withAlpha(10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: sent
                ? avuxoGreen
                : Colors.white38,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            sent
                ? Icons.check_circle
                : Icons.pending_rounded,
            color: sent
                ? avuxoGreen
                : Colors.white38,
          ),
        ],
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({
    required this.label,
    required this.image,
  });

  final String label;
  final ImageProvider? image;

  static const Color avuxoGreen =
      Color(0xFF24F877);

  void _openImage(
    BuildContext context,
  ) {
    if (image == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor:
                Colors.black,
            iconTheme:
                const IconThemeData(
              color: Colors.white,
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: Image(
                image: image!,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => _openImage(context),
      child: Container(
        height: 105,
        decoration: BoxDecoration(
          color: const Color(0xFF141C25),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color:
                avuxoGreen.withAlpha(64),
          ),
          image: image == null
              ? null
              : DecorationImage(
                  image: image!,
                  fit: BoxFit.cover,
                ),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_rounded,
                    color: avuxoGreen,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              )
            : Align(
                alignment:
                    Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withAlpha(148),
                    borderRadius:
                        const BorderRadius
                            .vertical(
                      bottom:
                          Radius.circular(
                        18,
                      ),
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign:
                        TextAlign.center,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}