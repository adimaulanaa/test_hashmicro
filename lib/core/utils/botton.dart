import 'package:attendance_app/core/constants/media_colors.dart';
import 'package:flutter/material.dart';

enum UIButtonType { filled, tonal, outlined, text }

enum UIButtonSize { verySmall, extraSmall, small, medium }

class UIButton extends StatelessWidget {
  final String label;
  final UIButtonType type;
  final UIButtonSize size;
  final Color color;
  final Color? colorText;
  final bool enabled;
  final bool expanded;
  final VoidCallback? onPressed;

  const UIButton({
    super.key,
    required this.label,
    this.type = UIButtonType.filled,
    this.size = UIButtonSize.medium,
    this.color = AppColors.primary,
    this.colorText,
    this.enabled = true,
    this.expanded = true,
    this.onPressed,
  });

  EdgeInsets get _padding {
    switch (size) {
      case UIButtonSize.verySmall:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case UIButtonSize.extraSmall:
        return const EdgeInsets.symmetric(vertical: 6, horizontal: 24);
      case UIButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 9, horizontal: 24);
      case UIButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 14, horizontal: 24);
    }
  }

  TextStyle getTextStyle(Color effectiveTextColor) {
    switch (size) {
      case UIButtonSize.verySmall:
      case UIButtonSize.extraSmall:
        return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: effectiveTextColor);
      case UIButtonSize.small:
        return TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: effectiveTextColor);
      case UIButtonSize.medium:
        return TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: effectiveTextColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveTextColor = type == UIButtonType.filled ? Colors.white : color;

    // radius fixed 8
    final BorderRadius borderRadius = BorderRadius.circular(8);

    final ButtonStyle baseStyle = switch (type) {
      UIButtonType.filled => FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: effectiveTextColor,
          padding: _padding,
          textStyle: getTextStyle(effectiveTextColor),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      UIButtonType.tonal => FilledButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          padding: _padding,
          textStyle: getTextStyle(color),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      UIButtonType.outlined => OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          foregroundColor: color,
          padding: _padding,
          textStyle: getTextStyle(color),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      UIButtonType.text => TextButton.styleFrom(
          foregroundColor: color,
          padding: _padding,
          textStyle: getTextStyle(color),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
    };

    final Widget btnChild = switch (type) {
      UIButtonType.filled || UIButtonType.tonal => FilledButton(
          onPressed: enabled ? onPressed : null,
          style: baseStyle,
          child: Text(label),
        ),
      UIButtonType.outlined => OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: baseStyle,
          child: Text(label),
        ),
      UIButtonType.text => TextButton(
          onPressed: enabled ? onPressed : null,
          style: baseStyle,
          child: Text(label),
        ),
    };

    // wrapper Expanded otomatis kalau expanded == true
    final Widget wrapped =
        expanded ? SizedBox(width: double.infinity, child: btnChild) : btnChild;

    // InkWell opsional (kalau mau efek ripple manual)
    return wrapped;
  }
}
