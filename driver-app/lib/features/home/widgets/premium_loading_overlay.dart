import 'package:flutter/material.dart';

class PremiumLoadingOverlay extends StatefulWidget {
  const PremiumLoadingOverlay({
    super.key,
    required this.message,
  });

  final String message;

  @override
  State<PremiumLoadingOverlay> createState() =>
      _PremiumLoadingOverlayState();
}

class _PremiumLoadingOverlayState
    extends State<PremiumLoadingOverlay>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController _controller;

  String get _safeMessage {
    final value = widget.message.trim();

    if (value.isEmpty) {
      return 'Processando...';
    }

    return value;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1600,
      ),
      lowerBound: 0.98,
      upperBound: 1.02,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: Container(
            color: Colors.black.withAlpha(165),
            child: Center(
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xEB0B1117),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: avuxoGreen.withAlpha(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: avuxoGreen.withAlpha(25),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _controller,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: avuxoGreen.withAlpha(20),
                          border: Border.all(
                            color: avuxoGreen.withAlpha(60),
                          ),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(
                              color: avuxoGreen,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      _safeMessage,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Aguarde enquanto a plataforma AVUXO processa sua solicitação.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(150),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}