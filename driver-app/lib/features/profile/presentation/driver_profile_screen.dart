import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/local_storage.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() =>
      _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  static const Color avuxoGreen = Color(0xFF24F877);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://avuxo-backend-production.up.railway.app',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  final ImagePicker picker = ImagePicker();

  bool loading = true;
  bool uploadingPhoto = false;
  bool _loadingProfile = false;

  String? error;
  String? localPhoto;
  File? selectedPhoto;
  Map<String, dynamic>? driver;

  @override
  void initState() {
    super.initState();
    _loadLocalPhoto();
    _loadProfile();
  }

  @override
  void dispose() {
    dio.close(force: true);
    super.dispose();
  }

  Future<void> _loadLocalPhoto() async {
    final photo = await LocalStorage().getDriverPhoto();

    if (!mounted) return;

    if (photo != null && photo.trim().isNotEmpty) {
      setState(() {
        localPhoto = photo;
      });
    }
  }

  Future<void> _loadProfile() async {
    if (_loadingProfile) return;

    _loadingProfile = true;

    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final phone = await LocalStorage().getPhone();

      if (!mounted) return;

      if (phone == null || phone.trim().isEmpty) {
        setState(() {
          error = 'Telefone do motorista não encontrado na sessão.';
          loading = false;
        });
        return;
      }

      final normalizedPhone = phone.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final response = await dio.get(
        '/drivers/status/$normalizedPhone',
      );

      if (!mounted) return;

      final data = response.data;

      if (data is! Map ||
          data['found'] != true ||
          data['driver'] is! Map) {
        setState(() {
          error = 'Motorista não encontrado.';
          loading = false;
        });
        return;
      }

      final driverFound = Map<String, dynamic>.from(
        data['driver'],
      );

      driverFound['approved'] = data['approved'] == true;
      driverFound['blocked'] = data['blocked'] == true;
      driverFound['blockedReason'] = data['blockedReason'] ?? '';
      driverFound['status'] = data['status'] ?? '';

      final backendPhoto = _text(
        driverFound['driverPhoto'],
        fallback: '',
      );

      if (backendPhoto.isNotEmpty) {
        await LocalStorage().saveDriverPhoto(backendPhoto);
      }

      if (!mounted) return;

      setState(() {
        driver = driverFound;
        localPhoto = backendPhoto.isNotEmpty ? backendPhoto : localPhoto;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'Não foi possível carregar o perfil.';
        loading = false;
      });
    } finally {
      _loadingProfile = false;
    }
  }
  Future<void> _choosePhotoSource() async {
    if (uploadingPhoto) return;

    final source =
        await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF141C25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              14,
              18,
              18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                        BorderRadius.circular(99),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Foto de perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Essa foto aparecerá para o cliente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                _photoOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Escolher da galeria',
                  subtitle:
                      'Usar uma foto salva no celular',
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.gallery,
                    );
                  },
                ),

                const SizedBox(height: 10),

                _photoOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Tirar foto agora',
                  subtitle:
                      'Abrir a câmera do celular',
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.camera,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    await _pickAndUploadPhoto(source);
  }

  Future<void> _pickAndUploadPhoto(
    ImageSource source,
  ) async {
    try {
      final file = await picker.pickImage(
        source: source,
        imageQuality: 35,
        maxWidth: 420,
        maxHeight: 420,
      );

      if (file == null) return;

      final pickedFile = File(file.path);

      final fileSize =
          await pickedFile.length();

      if (fileSize >
          (2 * 1024 * 1024)) {
        throw Exception(
          'A foto deve ter no máximo 2MB.',
        );
      }

      if (!mounted) return;

      setState(() {
        selectedPhoto = pickedFile;
        uploadingPhoto = true;
      });

      final driverId =
          '${driver?['id'] ?? ''}'.trim();

      if (driverId.isEmpty) {
        throw Exception(
          'ID do motorista não encontrado.',
        );
      }

      final bytes =
          await pickedFile.readAsBytes();

      final base64Photo =
          'data:image/jpeg;base64,${base64Encode(bytes)}';

      final response = await dio.post(
        '/drivers/$driverId/photo',
        data: {
          'driverPhoto': base64Photo,
        },
      );

      final data = response.data;

      if (response.statusCode != 200 ||
          data is! Map ||
          data['success'] != true) {
        throw Exception(
          data is Map
              ? data['message'] ??
                  'Backend recusou a foto.'
              : 'Erro no backend.',
        );
      }

      await LocalStorage().saveDriverPhoto(
        base64Photo,
      );

      if (!mounted) return;

      setState(() {
        localPhoto = base64Photo;
        driver?['driverPhoto'] =
            base64Photo;
        selectedPhoto = null;
        uploadingPhoto = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: avuxoGreen,
          content: Text(
            'Foto atualizada com sucesso.',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        uploadingPhoto = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.redAccent,
          content: Text(
            'Erro ao atualizar foto: $e',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }
  }

  String _text(
    dynamic value, {
    String fallback = 'Não informado',
  }) {
    final text =
        '${value ?? ''}'.trim();

    return text.isEmpty
        ? fallback
        : text;
  }

  String _ratingText(
    Map<String, dynamic> d,
  ) {
    final totalRatings =
        int.tryParse(
              '${d['totalRatings'] ?? 0}',
            ) ??
            0;

    final rating =
        double.tryParse(
              '${d['rating'] ?? 0}',
            ) ??
            0;

    if (totalRatings <= 0 ||
        rating <= 0) {
      return 'Novo motorista';
    }

    return rating.toStringAsFixed(2);
  }

  ImageProvider?
      _profileImageProvider(
    String photo,
  ) {
    if (selectedPhoto != null) {
      return FileImage(
        selectedPhoto!,
      );
    }

    final cleanPhoto =
        photo.trim();

    if (cleanPhoto.isEmpty) {
      return null;
    }

    if (cleanPhoto.startsWith(
          'http://',
        ) ||
        cleanPhoto.startsWith(
          'https://',
        )) {
      return NetworkImage(
        cleanPhoto,
      );
    }

    try {
      final base64Only =
          cleanPhoto.contains(',')
              ? cleanPhoto
                  .split(',')
                  .last
              : cleanPhoto;

      return MemoryImage(
        base64Decode(base64Only),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0B1117),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0B1117),
        elevation: 0,
        centerTitle: true,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Meu Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                uploadingPhoto ||
                        _loadingProfile
                    ? null
                    : _loadProfile,
            icon: const Icon(
              Icons.refresh,
              color: avuxoGreen,
            ),
          ),
        ],
      ),
      body: _body(),
    );
  }
  Widget _body() {
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final d = driver ?? {};

    final name = _text(
      d['fullName'] ?? d['name'],
      fallback: 'Motorista AVUXO',
    );

    final phone = _text(d['phone']);
    final email = _text(d['email']);

    final approved = d['approved'] == true;
    final blocked = d['blocked'] == true;

    final car = [
      _text(d['carBrand'], fallback: ''),
      _text(d['carModel'], fallback: ''),
      _text(d['carColor'], fallback: ''),
    ].where((e) => e.trim().isNotEmpty).join(' ');

    final status = blocked
        ? 'Bloqueado'
        : approved
            ? 'Aprovado'
            : 'Em análise';

    final photo = _text(
      d['driverPhoto'] ?? localPhoto,
      fallback: '',
    );

    final imageProvider = _profileImageProvider(photo);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          GestureDetector(
            onTap: uploadingPhoto ? null : _choosePhotoSource,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: avuxoGreen,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: avuxoGreen.withAlpha(51),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: const Color(0xFF141C25),
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? const Icon(
                            Icons.person,
                            size: 62,
                            color: avuxoGreen,
                          )
                        : null,
                  ),
                ),
                if (uploadingPhoto)
                  Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(148),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: avuxoGreen,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 6,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: avuxoGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0B1117),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.black,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Toque na foto para alterar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Essa foto aparecerá para o cliente',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: avuxoGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Motorista AVUXO',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: avuxoGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _item(Icons.phone, 'Telefone', phone),
          _item(Icons.email, 'E-mail', email),
          _item(Icons.star, 'Avaliação', _ratingText(d)),
          _item(
            Icons.directions_car,
            'Veículo',
            car.isEmpty ? 'Não informado' : car,
          ),
          _item(
            Icons.confirmation_number,
            'Placa',
            _text(d['carPlate']),
          ),
          _item(Icons.badge, 'Status', status),
          if (blocked && _text(d['blockedReason'], fallback: '').isNotEmpty)
            _item(
              Icons.warning_rounded,
              'Motivo do bloqueio',
              _text(d['blockedReason']),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: uploadingPhoto ? null : _choosePhotoSource,
              icon: uploadingPhoto
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.4,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.black,
                    ),
              label: Text(
                uploadingPhoto
                    ? 'ENVIANDO FOTO...'
                    : 'ALTERAR FOTO DE PERFIL',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: avuxoGreen,
                disabledBackgroundColor: avuxoGreen.withAlpha(140),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: uploadingPhoto ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1117),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withAlpha(15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: avuxoGreen.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: avuxoGreen,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String value,
  ) {
    final safeTitle = title.trim().isEmpty ? 'Informação' : title.trim();
    final safeValue = value.trim().isEmpty ? 'Não informado' : value.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141C25),
        borderRadius: BorderRadius.circular(18),
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
              safeTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              safeValue,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
}