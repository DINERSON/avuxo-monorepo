import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverPremiumButton extends StatelessWidget {
  const DriverPremiumButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.loading = false,
    this.expanded = true,
  });

  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  static const Color avuxoGreen = Color(0xFF24F877);

  String get _safeText {
    final value = text.trim();

    if (value.isEmpty) {
      return 'CONTINUAR';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final button = RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: loading
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onTap();
                },
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: loading
                  ? avuxoGreen.withAlpha(160)
                  : avuxoGreen,
              border: Border.all(
                color: avuxoGreen,
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(60),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: Colors.black,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            _safeText,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}