import 'package:flutter/material.dart';

class AvuxoDriverLogo extends StatelessWidget {
  const AvuxoDriverLogo({
    super.key,
    this.large = false,
  });

  final bool large;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    final logoSize = large ? 110.0 : 72.0;
    final fontSize = large ? 34.0 : 24.0;

    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xEB0B1117),
              border: Border.all(
                color: avuxoGreen.withAlpha(60),
              ),
              boxShadow: [
                BoxShadow(
                  color: avuxoGreen.withAlpha(30),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: logoSize * 0.52,
                  height: logoSize * 0.52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avuxoGreen.withAlpha(24),
                  ),
                ),

                Icon(
                  Icons.flash_on_rounded,
                  color: avuxoGreen,
                  size: logoSize * 0.42,
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFF24F877),
                      Color(0xFF8CFFB8),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  'AVUXO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'MOTORISTA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withAlpha(158),
                  fontSize: large ? 13 : 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}