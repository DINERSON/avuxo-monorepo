import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverStatusToggle extends StatelessWidget {
  const DriverStatusToggle({
    super.key,
    required this.online,
    required this.onChanged,
  });

  final bool online;
  final ValueChanged<bool> onChanged;

  static const Color avuxoGreen = Color(0xFF24F877);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            HapticFeedback.mediumImpact();
            onChanged(!online);
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 250,
            ),
            curve: Curves.easeOutCubic,
            width: 150,
            height: 70,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(999),
              color: online
                  ? avuxoGreen
                  : const Color(0xEB0B1117),
              border: Border.all(
                color: online
                    ? avuxoGreen
                    : Colors.white12,
              ),
              boxShadow: [
                BoxShadow(
                  color: online
                      ? avuxoGreen.withAlpha(70)
                      : Colors.black26,
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedAlign(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  curve: Curves.easeOutCubic,
                  alignment: online
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: online
                          ? Colors.black
                          : avuxoGreen,
                      boxShadow: [
                        BoxShadow(
                          color: online
                              ? Colors.black38
                              : avuxoGreen
                                  .withAlpha(70),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      online
                          ? Icons.flash_on_rounded
                          : Icons.power_settings_new,
                      color: online
                          ? avuxoGreen
                          : Colors.black,
                      size: 28,
                    ),
                  ),
                ),

                IgnorePointer(
                  child: Text(
                    online
                        ? 'ONLINE'
                        : 'OFFLINE',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: online
                          ? Colors.black
                          : Colors.white,
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}