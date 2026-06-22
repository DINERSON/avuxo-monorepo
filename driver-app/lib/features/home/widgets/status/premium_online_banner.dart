import 'package:flutter/material.dart';

class PremiumOnlineBanner extends StatefulWidget {
  const PremiumOnlineBanner({
    super.key,
    required this.online,
    required this.driverName,
  });

  final bool online;
  final String driverName;

  @override
  State<PremiumOnlineBanner> createState() =>
      _PremiumOnlineBannerState();
}

class _PremiumOnlineBannerState
    extends State<PremiumOnlineBanner>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController _controller;

  bool _animating = false;

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
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(
    covariant PremiumOnlineBanner oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.online != widget.online) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.online) {
      if (!_animating) {
        _animating = true;
        _controller.repeat(reverse: true);
      }
    } else {
      if (_animating) {
        _animating = false;
        _controller.stop();
        _controller.value = 1.0;
      }
    }
  }

  String get _safeDriverName {
    final value = widget.driverName.trim();

    if (value.isEmpty) {
      return 'Motorista';
    }

    return value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ScaleTransition(
        scale: widget.online
            ? _controller
            : const AlwaysStoppedAnimation(1.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xEB0B1117),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: widget.online
                  ? avuxoGreen.withAlpha(56)
                  : Colors.white12,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.online
                    ? avuxoGreen.withAlpha(24)
                    : Colors.black26,
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.online
                      ? avuxoGreen.withAlpha(26)
                      : Colors.white12,
                  border: Border.all(
                    color: widget.online
                        ? avuxoGreen.withAlpha(56)
                        : Colors.white12,
                  ),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: widget.online
                      ? avuxoGreen
                      : Colors.white38,
                  size: 38,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.online
                          ? 'VOCÊ ESTÁ ONLINE'
                          : 'VOCÊ ESTÁ OFFLINE',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.online
                            ? avuxoGreen
                            : Colors.white54,
                        fontWeight:
                            FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.6,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.online
                          ? '$_safeDriverName, a AVUXO está procurando corridas próximas.'
                          : 'Ative o modo online para receber corridas.',
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            Colors.white.withAlpha(165),
                        fontWeight:
                            FontWeight.w600,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 250,
                ),
                curve: Curves.easeOutCubic,
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.online
                      ? avuxoGreen
                      : Colors.white24,
                  boxShadow: widget.online
                      ? [
                          BoxShadow(
                            color: avuxoGreen
                                .withAlpha(180),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}