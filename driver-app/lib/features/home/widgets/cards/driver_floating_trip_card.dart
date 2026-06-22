import 'dart:ui';

import 'package:flutter/material.dart';

class DriverFloatingTripCard extends StatelessWidget {
  const DriverFloatingTripCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trailing,
    this.padding,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  String get _safeTitle {
    final value = title.trim();

    if (value.isEmpty || value == 'null') {
      return '--';
    }

    return value;
  }

  String get _safeSubtitle {
    final value = subtitle.trim();

    if (value.isEmpty || value == 'null') {
      return '--';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 12,
                sigmaY: 12,
              ),
              child: Container(
                padding: padding ??
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1117)
                      .withOpacity(0.92),
                  borderRadius:
                      BorderRadius.circular(28),
                  border: Border.all(
                    color: color.withOpacity(0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.10),
                        border: Border.all(
                          color:
                              color.withOpacity(0.22),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Text(
                            _safeTitle,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _safeSubtitle,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.60),
                              fontWeight:
                                  FontWeight.w600,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 12),
                      trailing!,
                    ],
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