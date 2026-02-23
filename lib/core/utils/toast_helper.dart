import 'package:flutter/material.dart';

/// error
// ToastHelper.errorToast(context, state.message);

/// success
// ToastHelper.successToast(context, state.message);

/// info
// ToastHelper.infoToast(context, 'Pesan info');

class ToastHelper {
  static void errorToast(BuildContext context, String msg, {int? duration}) {
    _showToast(
      context,
      msg: msg,
      backgroundColor: Colors.red,
      duration: duration ?? 3,
    );
  }

  static void infoToast(BuildContext context, String msg, {int? duration}) {
    _showToast(
      context,
      msg: msg,
      backgroundColor: Colors.grey.shade700,
      duration: duration ?? 3,
    );
  }

  static void successToast(
    BuildContext context,
    String msg, {
    int? duration,
    Color? color,
  }) {
    _showToast(
      context,
      msg: msg,
      backgroundColor: color ?? Colors.green,
      duration: duration ?? 3,
    );
  }

  static void _showToast(
    BuildContext context, {
    required String msg,
    required Color backgroundColor,
    required int duration,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) =>
          _ToastWidget(msg: msg, backgroundColor: backgroundColor),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: duration), () {
      overlayEntry.remove();
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String msg;
  final Color backgroundColor;

  const _ToastWidget({required this.msg, required this.backgroundColor});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.msg,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
