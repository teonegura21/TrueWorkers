import 'package:flutter/material.dart';

/// Accessibility utilities for WCAG 2.1 AA compliance
/// Provides helpers for Semantics, touch targets, and screen reader support
class AccessibilityUtils {
  /// Minimum touch target size for WCAG compliance
  /// Android: 48x48 dp (Material Design)
  /// iOS: 44x44 dp (Human Interface Guidelines)
  static const double minTouchTarget = 48.0;

  /// Wrap an IconButton with accessibility features
  ///
  /// Usage:
  /// ```dart
  /// AccessibilityUtils.accessibleIconButton(
  ///   icon: Icons.add,
  ///   label: 'Adaugă proiect nou',
  ///   tooltip: 'Apasă pentru a adăuga un proiect nou',
  ///   onPressed: () => _addProject(),
  /// )
  /// ```
  static Widget accessibleIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    String? tooltip,
    Color? color,
    double? size,
  }) {
    final button = IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed,
      tooltip: tooltip ?? label,
    );

    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }

  /// Wrap any widget with minimum touch target size
  ///
  /// Ensures widget meets WCAG AA standards for touch targets
  static Widget ensureTouchTarget({
    required Widget child,
    VoidCallback? onTap,
    double minSize = minTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: onTap != null
          ? GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: child,
            )
          : child,
    );
  }

  /// Wrap an ElevatedButton with accessibility features
  static Widget accessibleButton({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    String? hint,
  }) {
    Widget button;

    if (icon != null) {
      button = ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : icon,
        label: Text(label),
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : Text(label),
      );
    }

    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null && !isLoading,
      hint: hint,
      child: ExcludeSemantics(child: button),
    );
  }

  /// Wrap an Image with semantic label for screen readers
  static Widget accessibleImage({
    required ImageProvider image,
    required String label,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Semantics(
      label: label,
      image: true,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: label,
      ),
    );
  }

  /// Wrap a Card with semantic label and role
  static Widget accessibleCard({
    required Widget child,
    required String label,
    VoidCallback? onTap,
    String? hint,
  }) {
    return Semantics(
      label: label,
      button: onTap != null,
      onTap: onTap,
      hint: hint,
      child: Card(child: child),
    );
  }

  /// Create a screen reader announcement
  /// Use for dynamic content updates
  static Widget liveRegion({
    required String message,
    required Widget child,
    bool polite = true,
  }) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: child,
    );
  }

  /// Exclude decorative elements from screen reader
  /// Use for purely visual elements with no semantic meaning
  static Widget decorative({required Widget child}) {
    return ExcludeSemantics(child: child);
  }

  /// Create accessible text field with proper labels
  static InputDecoration accessibleInputDecoration({
    required String label,
    String? hint,
    String? error,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon != null && onSuffixIconPressed != null
          ? accessibleIconButton(
              icon: suffixIcon,
              label: 'Acțiune $label',
              onPressed: onSuffixIconPressed,
            )
          : (suffixIcon != null ? Icon(suffixIcon) : null),
    );
  }

  /// Create accessible bottom navigation bar item
  static BottomNavigationBarItem accessibleNavItem({
    required IconData icon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Semantics(
        label: label,
        button: true,
        child: Icon(icon),
      ),
      label: label,
      tooltip: label,
    );
  }

  /// Create accessible list tile
  static Widget accessibleListTile({
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel ?? '$title${subtitle != null ? ', $subtitle' : ''}',
      button: onTap != null,
      onTap: onTap,
      child: ListTile(
        leading: leading != null ? ExcludeSemantics(child: leading) : null,
        title: ExcludeSemantics(child: Text(title)),
        subtitle: subtitle != null ? ExcludeSemantics(child: Text(subtitle)) : null,
        trailing: trailing != null ? ExcludeSemantics(child: trailing) : null,
        onTap: onTap,
      ),
    );
  }

  /// Announce a message to screen readers
  /// Useful for dynamic updates like "Item added to cart"
  static void announce(BuildContext context, String message) {
    // Using SemanticsService to announce to screen readers
    SemanticsService.announce(message, TextDirection.ltr);
  }
}

/// Extension on BuildContext for easier accessibility announcements
extension AccessibilityExtension on BuildContext {
  /// Announce a message to screen readers from any BuildContext
  void announce(String message) {
    AccessibilityUtils.announce(this, message);
  }
}
