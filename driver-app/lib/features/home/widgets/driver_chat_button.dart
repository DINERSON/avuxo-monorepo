import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverChatButton extends StatefulWidget {
  const DriverChatButton({
    super.key,
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final VoidCallback onTap;

  @override
  State<DriverChatButton> createState() =>
      _DriverChatButtonState();
}

class _DriverChatButtonState
    extends State<DriverChatButton>
    with SingleTickerProviderStateMixin {
  static const Color avuxoGreen = Color(0xFF24F877);

  late final AnimationController _controller;
  bool _animating = false;

  int get _safeUnreadCount {
    if (widget.unreadCount < 0) {
      return 0;
    }

    return widget.unreadCount;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.98,
      upperBound: 1.02,
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant DriverChatButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.unreadCount != widget.unreadCount) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    final hasUnread = _safeUnreadCount > 0;

    if (hasUnread) {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _badgeText {
    if (_safeUnreadCount > 99) {
      return '99+';
    }

    return '$_safeUnreadCount';
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _safeUnreadCount > 0;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: hasUnread
            ? _controller
            : const AlwaysStoppedAnimation(1.0),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xEB0B1117),
                border: Border.all(
                  color: avuxoGreen.withAlpha(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: avuxoGreen.withAlpha(26),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_rounded,
                    color: avuxoGreen,
                    size: 34,
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 10,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withAlpha(120),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          _badgeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
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
  }
}