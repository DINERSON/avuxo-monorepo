import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/local_storage.dart';
import '../../auth/presentation/auth_gate.dart';
import '../data/driver_registration_service.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with TickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);
  static const Color darkBg = Color(0xFF05070A);
  static const Color cardBg = Color(0xFF0B1117);

  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();

  final TextEditingController carBrand = TextEditingController();
  final TextEditingController carModel = TextEditingController();
  final TextEditingController plate = TextEditingController();
  final TextEditingController renavam = TextEditingController();
  final TextEditingController carColor = TextEditingController();
  final TextEditingController carSeats = TextEditingController();
  final TextEditingController carYear = TextEditingController();

  late final DriverRegistrationService registrationService;
  late final AnimationController glowController;

  File? idDoc;
  File? selfie;
  File? cnhFront;
  File? cnhBack;
  File? vehicleDocumentPdf;
  File? carFront;
  File? carSide;
  File? carBack;

  bool loading = false;
  bool rentedVehicle = false;
  int step = 0;

  @override
  void initState() {
    super.initState();

    registrationService = DriverRegistrationService();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: 0.70,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    glowController.dispose();

    registrationService.dispose();

    name.dispose();
    phone.dispose();
    email.dispose();

    carBrand.dispose();
    carModel.dispose();
    plate.dispose();
    renavam.dispose();
    carColor.dispose();
    carSeats.dispose();
    carYear.dispose();

    super.dispose();
  }

  Future<void> pickImage({
    required String type,
    ImageSource source = ImageSource.camera,
  }) async {
    if (loading) return;

    try {
      final x = await ImagePicker().pickImage(
        source: source,
        imageQuality: 78,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (x == null) return;

      final file = File(x.path);

      if (!await file.exists()) {
        _snack('Arquivo de imagem não encontrado.');
        return;
      }

      if (!mounted) return;

      setState(() {
        if (type == 'id') {
          idDoc = file;
        } else if (type == 'cnh_front') {
          cnhFront = file;
        } else if (type == 'cnh_back') {
          cnhBack = file;
        } else if (type == 'selfie') {
          selfie = file;
        } else if (type == 'front') {
          carFront = file;
        } else if (type == 'side') {
          carSide = file;
        } else if (type == 'back') {
          carBack = file;
        }
      });
    } catch (e) {
      _snack('Falha ao selecionar imagem.');
      debugPrint('ERRO IMAGEM AVUXO: $e');
    }
  }

  Future<void> pickVehicleDocumentPdf() async {
    if (loading) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;

      if (path == null || path.trim().isEmpty) {
        _snack('Não foi possível carregar o PDF.');
        return;
      }

      final file = File(path);

      if (!await file.exists()) {
        _snack('PDF não encontrado.');
        return;
      }

      if (!mounted) return;

      setState(() {
        vehicleDocumentPdf = file;
      });
    } catch (e) {
      _snack('Falha ao selecionar PDF.');
      debugPrint('ERRO PDF AVUXO: $e');
    }
  }
  bool _validEmail(String value) {
    final emailText = value.trim();

    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(emailText);
  }

  bool _validPhone(String value) {
    final phoneOnly = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    return phoneOnly.length >= 10;
  }

  bool _validPlate(String value) {
    final cleanPlate = value
        .trim()
        .toUpperCase()
        .replaceAll('-', '')
        .replaceAll(' ', '');

    return cleanPlate.length >= 7;
  }

  void nextStep() {
    if (loading) return;

    FocusScope.of(context).unfocus();

    if (step == 0) {
      if (name.text.trim().isEmpty) {
        _snack('Digite seu nome completo.');
        return;
      }

      if (!_validPhone(phone.text)) {
        _snack('Telefone inválido.');
        return;
      }

      if (!_validEmail(email.text)) {
        _snack('E-mail inválido.');
        return;
      }
    }

    if (step == 1) {
      if (carBrand.text.trim().isEmpty) {
        _snack('Digite a marca do veículo.');
        return;
      }

      if (carModel.text.trim().isEmpty) {
        _snack('Digite o modelo do veículo.');
        return;
      }

      if (!_validPlate(plate.text)) {
        _snack('Placa inválida.');
        return;
      }

      if (renavam.text.trim().isEmpty) {
        _snack('Digite o número do RENAVAM.');
        return;
      }

      if (carColor.text.trim().isEmpty) {
        _snack('Digite a cor do veículo.');
        return;
      }

      if (carSeats.text.trim().isEmpty) {
        _snack('Digite o número de assentos.');
        return;
      }

      if (carYear.text.trim().isEmpty) {
        _snack('Digite o ano do veículo.');
        return;
      }
    }

    if (step == 2) {
      if (idDoc == null ||
          selfie == null ||
          cnhFront == null ||
          cnhBack == null ||
          vehicleDocumentPdf == null) {
        _snack(
          'Envie identidade, selfie, CNH frente/verso e documento do carro.',
        );
        return;
      }
    }

    if (step == 3) {
      if (carFront == null || carSide == null || carBack == null) {
        _snack('Envie as fotos do carro.');
        return;
      }
    }

    if (step >= 4) {
      submit();
      return;
    }

    setState(() {
      step++;
    });
  }

  void previousStep() {
    if (loading) return;

    if (step == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      step--;
    });
  }

  Future<void> submit() async {
    if (loading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      final safeName = name.text.trim();
      final safePhone = phone.text.trim();
      final safeEmail = email.text.trim();
      final safePlate = plate.text.trim().toUpperCase();

      final vehicleInfo =
          '${carBrand.text.trim()} ${carModel.text.trim()} • '
          '${carColor.text.trim()} • Ano ${carYear.text.trim()} • '
          '${carSeats.text.trim()} assentos • '
          'RENAVAM ${renavam.text.trim()} • '
          '${rentedVehicle ? 'Veículo locado' : 'Veículo próprio'}';

      await registrationService.registerDriver(
        fullName: safeName,
        email: safeEmail,
        phone: safePhone,
        carBrand: carBrand.text.trim(),
        carModel: carModel.text.trim(),
        carPlate: safePlate,
        carColor: carColor.text.trim(),
        carYear: carYear.text.trim(),
        carSeats: carSeats.text.trim(),
        renavam: renavam.text.trim(),
        rentedVehicle: rentedVehicle,
        idDoc: idDoc,
        selfie: selfie,
        cnhFront: cnhFront,
        cnhBack: cnhBack,
        vehicleDocumentPdf: vehicleDocumentPdf,
        carFront: carFront,
        carSide: carSide,
        carBack: carBack,
      );

      await LocalStorage().saveRegistrationDraft(
        name: safeName,
        phone: safePhone,
        email: safeEmail,
        idDocPath: idDoc?.path ?? '',
        licensePath: cnhFront?.path ?? '',
        carInfo: vehicleInfo,
        carPlate: safePlate,
      );

      await LocalStorage().saveRegistrationState(
        phone: safePhone,
        name: safeName,
        registered: true,
        approved: false,
        logged: false,
      );

      ref.read(hasRegisteredProvider.notifier).state = true;
      ref.read(registrationPhoneProvider.notifier).state = safePhone;
      ref.read(isApprovedProvider.notifier).state = false;
      ref.read(isLoggedProvider.notifier).state = false;

      if (!mounted) return;

      _snack('Cadastro enviado com sucesso.');

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthGate(),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _snack(
        'Falha no cadastro: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      debugPrint('ERRO CADASTRO AVUXO: $e');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }
  void _snack(String message) {
    if (!mounted) return;

    final safeMessage = message.trim().isEmpty
        ? 'Ação concluída.'
        : message.trim();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10151E),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: avuxoGreen.withAlpha(56),
            ),
          ),
          content: Text(
            safeMessage,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
  }

  String get stepTitle {
    if (step == 0) return 'Dados pessoais';
    if (step == 1) return 'Informações do veículo';
    if (step == 2) return 'Documentos e selfie';
    if (step == 3) return 'Fotos do carro';
    return 'Confirmação';
  }

  String get stepSubtitle {
    if (step == 0) {
      return 'Informe seus dados para entrar na AVUXO.';
    }

    if (step == 1) {
      return 'Cadastre o veículo que será usado nas corridas.';
    }

    if (step == 2) {
      return 'Envie identidade, selfie, CNH frente/verso e documento do carro.';
    }

    if (step == 3) {
      return 'Tire fotos claras do carro para validação.';
    }

    return 'Confira tudo antes de enviar para análise.';
  }

  String _safeText(
    String value, {
    String fallback = '-',
  }) {
    final text = value.trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (step + 1) / 5;

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          Positioned(
            top: -140,
            right: -120,
            child: AnimatedBuilder(
              animation: glowController,
              builder: (_, __) {
                return _glow(
                  260,
                  0.08 * glowController.value,
                );
              },
            ),
          ),
          Positioned(
            bottom: -160,
            left: -130,
            child: AnimatedBuilder(
              animation: glowController,
              builder: (_, __) {
                return _glow(
                  270,
                  0.06 * glowController.value,
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    10,
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: loading ? null : previousStep,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      _brandMini(),
                      const Spacer(),
                      const SizedBox(width: 46),
                    ],
                  ),
                ),
                Expanded(
                  child: RepaintBoundary(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        10,
                        22,
                        22,
                      ),
                      children: [
                        const SizedBox(height: 8),
                        _progressHeader(percent),
                        const SizedBox(height: 24),
                        _premiumCard(
                          child: AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 260,
                            ),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _stepContent(),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _nextButton(),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepContent() {
    if (step == 0) {
      return Column(
        key: const ValueKey('personal'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.person_rounded,
            title: stepTitle,
            subtitle: stepSubtitle,
          ),
          const SizedBox(height: 24),
          _field(
            controller: name,
            label: 'Nome completo',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _field(
            controller: phone,
            label: 'Telefone',
            icon: Icons.phone_rounded,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _field(
            controller: email,
            label: 'E-mail',
            icon: Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
          ),
        ],
      );
    }
    if (step == 1) {
      return Column(
        key: const ValueKey('vehicle'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.directions_car_filled_rounded,
            title: stepTitle,
            subtitle: stepSubtitle,
          ),
          const SizedBox(height: 24),
          _field(
            controller: carBrand,
            label: 'Marca do veículo',
            icon: Icons.factory_rounded,
          ),
          const SizedBox(height: 14),
          _field(
            controller: carModel,
            label: 'Modelo do veículo',
            icon: Icons.directions_car_rounded,
          ),
          const SizedBox(height: 14),
          _field(
            controller: plate,
            label: 'Placa do veículo',
            icon: Icons.badge_rounded,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 14),
          _field(
            controller: renavam,
            label: 'Número do RENAVAM',
            icon: Icons.confirmation_number_rounded,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _field(
                  controller: carColor,
                  label: 'Cor',
                  icon: Icons.palette_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  controller: carYear,
                  label: 'Ano',
                  icon: Icons.calendar_month_rounded,
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _field(
            controller: carSeats,
            label: 'Número de assentos',
            icon: Icons.event_seat_rounded,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _switchTile(),
        ],
      );
    }

    if (step == 2) {
      return Column(
        key: const ValueKey('documents'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.verified_user_rounded,
            title: stepTitle,
            subtitle: stepSubtitle,
          ),
          const SizedBox(height: 24),
          _photoButton(
            title: 'Documento de identidade',
            subtitle: 'RG ou documento oficial com foto',
            icon: Icons.badge_rounded,
            file: idDoc,
            onTap: () => _chooseImageSource('id'),
          ),
          const SizedBox(height: 14),
          _photoButton(
            title: 'CNH frente',
            subtitle: 'Foto frontal da CNH',
            icon: Icons.credit_card_rounded,
            file: cnhFront,
            onTap: () => _chooseImageSource('cnh_front'),
          ),
          const SizedBox(height: 14),
          _photoButton(
            title: 'CNH verso',
            subtitle: 'Foto traseira da CNH',
            icon: Icons.credit_card_rounded,
            file: cnhBack,
            onTap: () => _chooseImageSource('cnh_back'),
          ),
          const SizedBox(height: 14),
          _pdfButton(),
          const SizedBox(height: 14),
          _photoButton(
            title: 'Selfie do motorista',
            subtitle: 'Tire uma foto do rosto para validação',
            icon: Icons.face_retouching_natural_rounded,
            file: selfie,
            onTap: () => pickImage(
              type: 'selfie',
              source: ImageSource.camera,
            ),
          ),
        ],
      );
    }

    if (step == 3) {
      return Column(
        key: const ValueKey('car_photos'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.photo_camera_rounded,
            title: stepTitle,
            subtitle: stepSubtitle,
          ),
          const SizedBox(height: 24),
          _photoButton(
            title: 'Foto frontal do carro',
            subtitle: 'Mostre frente e placa se possível',
            icon: Icons.directions_car_filled_rounded,
            file: carFront,
            onTap: () => _chooseImageSource('front'),
          ),
          const SizedBox(height: 14),
          _photoButton(
            title: 'Foto lateral do carro',
            subtitle: 'Mostre o perfil do veículo',
            icon: Icons.car_rental_rounded,
            file: carSide,
            onTap: () => _chooseImageSource('side'),
          ),
          const SizedBox(height: 14),
          _photoButton(
            title: 'Foto traseira do carro',
            subtitle: 'Mostre traseira e placa',
            icon: Icons.local_taxi_rounded,
            file: carBack,
            onTap: () => _chooseImageSource('back'),
          ),
        ],
      );
    }

    return Column(
      key: const ValueKey('confirmation'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          icon: Icons.workspace_premium_rounded,
          title: stepTitle,
          subtitle: stepSubtitle,
        ),
        const SizedBox(height: 24),
        _summaryTile(
          icon: Icons.person_rounded,
          title: _safeText(name.text),
          subtitle: _safeText(phone.text),
        ),
        const SizedBox(height: 12),
        _summaryTile(
          icon: Icons.directions_car_rounded,
          title: _safeText(
            '${carBrand.text.trim()} ${carModel.text.trim()}',
          ),
          subtitle:
              '${plate.text.trim().toUpperCase()} • '
              '${carColor.text.trim()} • '
              '${carYear.text.trim()}',
        ),
        const SizedBox(height: 12),
        _summaryTile(
          icon: Icons.verified_rounded,
          title: 'Documentos enviados',
          subtitle:
              'CNH frente/verso, documento do carro, selfie e fotos',
        ),
        const SizedBox(height: 18),
        Text(
          'Seu cadastro será enviado para análise. '
          'Após aprovado, o acesso ao app AVUXO Motorista será liberado.',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withAlpha(143),
            height: 1.45,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _chooseImageSource(String type) async {
    if (loading) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: BoxDecoration(
            color: const Color(0xE005070A),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            border: Border.all(
              color: avuxoGreen.withAlpha(40),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Enviar imagem',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _sourceButton(
                  icon: Icons.photo_camera_rounded,
                  title: 'Tirar foto agora',
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(
                      type: type,
                      source: ImageSource.camera,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _sourceButton(
                  icon: Icons.photo_library_rounded,
                  title: 'Escolher da galeria',
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(
                      type: type,
                      source: ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _sourceButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: loading ? null : onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withAlpha(20),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: avuxoGreen),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandMini() {
    return const Column(
      children: [
        Text(
          'AVUXO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'MOTORISTA',
          style: TextStyle(
            color: avuxoGreen,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _progressHeader(double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cadastro premium',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: avuxoGreen.withAlpha(242),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stepTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Etapa ${step + 1} de 5',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withAlpha(133),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: percent.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withAlpha(20),
            color: avuxoGreen,
          ),
        ),
      ],
    );
  }

  Widget _premiumCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg.withAlpha(210),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: avuxoGreen.withAlpha(28),
        ),
        boxShadow: [
          BoxShadow(
            color: avuxoGreen.withAlpha(18),
            blurRadius: 22,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: avuxoGreen.withAlpha(33),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: avuxoGreen.withAlpha(51),
            ),
          ),
          child: Icon(
            icon,
            color: avuxoGreen,
            size: 27,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _safeText(title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _safeText(subtitle),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withAlpha(140),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      enabled: !loading,
      keyboardType: keyboard,
      textCapitalization: textCapitalization,
      cursorColor: avuxoGreen,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withAlpha(117),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          color: avuxoGreen,
        ),
        filled: true,
        fillColor: Colors.black.withAlpha(92),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withAlpha(23),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withAlpha(23),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withAlpha(10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: avuxoGreen,
            width: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _switchTile() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: loading
            ? null
            : () {
                setState(() {
                  rentedVehicle = !rentedVehicle;
                });
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: rentedVehicle
                  ? avuxoGreen.withAlpha(112)
                  : Colors.white.withAlpha(20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                rentedVehicle
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: rentedVehicle ? avuxoGreen : Colors.white38,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Veículo é locado?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    final success = file != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: success
                ? avuxoGreen.withAlpha(26)
                : Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: success
                  ? avuxoGreen.withAlpha(117)
                  : Colors.white.withAlpha(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(89),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: success
                        ? avuxoGreen.withAlpha(102)
                        : Colors.white.withAlpha(20),
                  ),
                ),
                child: success
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.file(
                          file!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        icon,
                        color: avuxoGreen,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      success ? '$title enviado' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      success ? 'Toque para trocar a imagem' : subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(122),
                        fontSize: 12,
                        height: 1.30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                success ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                color: success ? avuxoGreen : Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pdfButton() {
    final success = vehicleDocumentPdf != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: loading ? null : pickVehicleDocumentPdf,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: success
                ? avuxoGreen.withAlpha(26)
                : Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: success
                  ? avuxoGreen.withAlpha(117)
                  : Colors.white.withAlpha(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(89),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: success
                        ? avuxoGreen.withAlpha(102)
                        : Colors.white.withAlpha(20),
                  ),
                ),
                child: Icon(
                  success
                      ? Icons.picture_as_pdf_rounded
                      : Icons.upload_file_rounded,
                  color: avuxoGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      success
                          ? 'Documento do carro enviado'
                          : 'Documento do carro',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      success
                          ? vehicleDocumentPdf!.path.split('/').last
                          : 'Anexe o CRLV ou documento do veículo em PDF',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(122),
                        fontSize: 12,
                        height: 1.30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                success ? Icons.check_circle_rounded : Icons.attach_file_rounded,
                color: success ? avuxoGreen : Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(20),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: avuxoGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _safeText(title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _safeText(subtitle),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: 12,
                    height: 1.30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextButton() {
    final isLast = step == 4;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: loading ? null : nextStep,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: loading ? Colors.white12 : avuxoGreen,
            borderRadius: BorderRadius.circular(18),
            boxShadow: loading
                ? null
                : [
                    BoxShadow(
                      color: avuxoGreen.withAlpha(92),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2.6,
                    ),
                  )
                : Text(
                    isLast ? 'ENVIAR CADASTRO' : 'PRÓXIMO',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _glow(double size, double opacity) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: avuxoGreen.withAlpha(
            (opacity.clamp(0.0, 1.0) * 255).round(),
          ),
          boxShadow: [
            BoxShadow(
              color: avuxoGreen.withAlpha(
                (opacity.clamp(0.0, 1.0) * 160).round(),
              ),
              blurRadius: 45,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}