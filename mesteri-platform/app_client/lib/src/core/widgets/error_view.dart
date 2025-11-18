import 'package:flutter/material.dart';
import '../errors/error_type.dart';
import '../theme/app_theme.dart';

/// Reusable error view widget with retry functionality
class ErrorView extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final EdgeInsets padding;

  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.retryButtonText,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon based on type
            Icon(
              _getIconForErrorType(error.type),
              size: 64,
              color: _getColorForErrorType(error.type),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Error title
            Text(
              _getTitleForErrorType(error.type),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MesteriColors.onSurface,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Error message
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MesteriColors.onSurfaceSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Retry button (if error can be retried)
            if (error.canRetry && onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Încearcă din nou'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MesteriColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForErrorType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.forbidden:
        return Icons.block;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.timeout:
        return Icons.hourglass_empty;
      case ErrorType.validation:
        return Icons.warning_amber_outlined;
      default:
        return Icons.error_outline;
    }
  }

  Color _getColorForErrorType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
        return MesteriColors.warning;
      case ErrorType.authentication:
      case ErrorType.forbidden:
      case ErrorType.validation:
        return MesteriColors.error;
      case ErrorType.server:
        return MesteriColors.error;
      default:
        return MesteriColors.onSurfaceSecondary;
    }
  }

  String _getTitleForErrorType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Problemă de conexiune';
      case ErrorType.authentication:
        return 'Sesiune expirată';
      case ErrorType.notFound:
        return 'Nu s-a găsit';
      case ErrorType.forbidden:
        return 'Acces interzis';
      case ErrorType.server:
        return 'Eroare server';
      case ErrorType.timeout:
        return 'Conexiune expirată';
      case ErrorType.validation:
        return 'Date invalide';
      default:
        return 'Eroare';
    }
  }
}

/// Compact error message widget for forms and inline errors
class ErrorMessage extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;

  const ErrorMessage({
    super.key,
    required this.message,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (color ?? MesteriColors.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? MesteriColors.error).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: color ?? MesteriColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color ?? MesteriColors.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
