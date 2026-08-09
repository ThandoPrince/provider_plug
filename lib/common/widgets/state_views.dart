import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';

/// A unified state view for empty, error, and network states.
/// Provides consistent UX across all screens.
class StateView extends StatelessWidget {
  /// The type of state to display
  final StateViewType type;

  /// Custom message (overrides default)
  final String? message;

  /// Custom title (overrides default)
  final String? title;

  /// Custom icon (overrides default)
  final IconData? icon;

  /// Optional action button
  final VoidCallback? onAction;

  /// Action button label
  final String? actionLabel;

  /// Action button icon
  final IconData? actionIcon;

  /// Whether to show a retry button (for error/network states)
  final bool showRetry;

  /// Custom background color (for gradient screens)
  final Color? backgroundColor;

  /// Custom icon color
  final Color? iconColor;

  /// Custom text color
  final Color? textColor;

  /// Optional illustration asset (for empty states)
  final String? illustrationAsset;

  const StateView._({
    required this.type,
    this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
    this.showRetry = false,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.illustrationAsset,
  });

  /// Empty state - no data found
  const StateView.empty({
    super.key,
    this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.illustrationAsset,
  }) : type = StateViewType.empty,
       showRetry = false;

  /// Error state - something went wrong
  const StateView.error({
    super.key,
    this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionLabel = 'Retry',
    this.actionIcon = Icons.refresh,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.illustrationAsset,
  }) : type = StateViewType.error,
       showRetry = true;

  /// Network error state - no internet / connection failed
  const StateView.networkError({
    super.key,
    this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionLabel = 'Try Again',
    this.actionIcon = Icons.wifi_off,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.illustrationAsset,
  }) : type = StateViewType.networkError,
       showRetry = true;

  /// Loading state with optional message
  const StateView.loading({
    super.key,
    this.message,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  }) : type = StateViewType.loading,
       title = null,
       icon = null,
       onAction = null,
       actionLabel = null,
       actionIcon = null,
       showRetry = false,
       illustrationAsset = null;

  /// Generic "something went wrong" state
  const StateView.somethingWentWrong({
    super.key,
    this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionLabel = 'Retry',
    this.actionIcon = Icons.refresh,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.illustrationAsset,
  }) : type = StateViewType.somethingWentWrong,
       showRetry = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = backgroundColor ?? (isDark ? Colors.black : Colors.white);
    final defaultIconColor = iconColor ?? (isDark ? Colors.white38 : Colors.grey);
    final defaultTextColor = textColor ?? (isDark ? Colors.white70 : Colors.grey[700]!);
    final actionColor = Kolors.kPrimary;

    Widget content;

    switch (type) {
      case StateViewType.loading:
        content = _buildLoading(message ?? 'Loading...', defaultIconColor, defaultTextColor);
        break;
      case StateViewType.empty:
        content = _buildEmptyState(defaultIconColor, defaultTextColor);
        break;
      case StateViewType.error:
        content = _buildErrorState('Error', defaultIconColor, defaultTextColor, actionColor);
        break;
      case StateViewType.networkError:
        content = _buildErrorState('No Connection', defaultIconColor, defaultTextColor, actionColor);
        break;
      case StateViewType.somethingWentWrong:
        content = _buildErrorState('Something Went Wrong', defaultIconColor, defaultTextColor, actionColor);
        break;
    }

    return Container(
      color: bgColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      ),
    );
  }

  Widget _buildLoading(String message, Color iconColor, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: iconColor,
          strokeWidth: 3,
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(Color iconColor, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (illustrationAsset != null) ...[
          Image.asset(
            illustrationAsset!,
            width: 120,
            height: 120,
            color: iconColor,
            errorBuilder: (_, __, ___) => _buildDefaultIcon(iconColor),
          ),
        ] else ...[
          _buildDefaultIcon(iconColor),
        ],
        const SizedBox(height: 20),
        Text(
          title ?? _defaultEmptyTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 24),
          _buildActionButton(actionColor: iconColor),
        ],
      ],
    );
  }

  Widget _buildErrorState(
    String defaultTitle,
    Color iconColor,
    Color textColor,
    Color actionColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDefaultIcon(iconColor, isError: true),
        const SizedBox(height: 20),
        Text(
          title ?? defaultTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
        if (showRetry && onAction != null) ...[
          const SizedBox(height: 24),
          _buildActionButton(actionColor: actionColor, isRetry: true),
        ],
      ],
    );
  }

  Widget _buildDefaultIcon(Color iconColor, {bool isError = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isError
            ? Colors.red.withOpacity(0.1)
            : iconColor.withOpacity(0.1),
      ),
      child: Icon(
        icon ??
            (isError
                ? Icons.error_outline
                : Icons.inbox_outlined),
        size: 40,
        color: iconColor,
      ),
    );
  }

  Widget _buildActionButton({required Color actionColor, bool isRetry = false}) {
    return ElevatedButton.icon(
      onPressed: onAction,
      icon: Icon(actionIcon ?? (isRetry ? Icons.refresh : Icons.add), size: 18),
      label: Text(
        actionLabel ?? (isRetry ? 'Retry' : 'Action'),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: actionColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  String get _defaultEmptyTitle {
    switch (type) {
      case StateViewType.empty:
        return 'No Data';
      case StateViewType.error:
        return 'Error';
      case StateViewType.networkError:
        return 'No Connection';
      case StateViewType.somethingWentWrong:
        return 'Something Went Wrong';
      case StateViewType.loading:
        return 'Loading';
    }
  }
}

enum StateViewType {
  empty,
  error,
  networkError,
  somethingWentWrong,
  loading,
}

/// A sliver version for use in CustomScrollView
class SliverStateView extends StatelessWidget {
  final StateViewType type;
  final String? message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? actionIcon;
  final bool showRetry;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final String? illustrationAsset;

  const SliverStateView({
    super.key,
    required this.type,
    this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
    this.showRetry = false,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.illustrationAsset,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: StateView._(
        type: type,
        message: message,
        title: title,
        icon: icon,
        onAction: onAction,
        actionLabel: actionLabel,
        actionIcon: actionIcon,
        showRetry: showRetry,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        textColor: textColor,
        illustrationAsset: illustrationAsset,
      ),
    );
  }
}

/// A refreshable list wrapper that shows state views
class RefreshableStateView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final StateViewType emptyType;
  final String? emptyMessage;
  final String? emptyTitle;
  final IconData? emptyIcon;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;
  final IconData? emptyActionIcon;
  final Color? backgroundColor;

  const RefreshableStateView({
    super.key,
    required this.onRefresh,
    required this.child,
    this.emptyType = StateViewType.empty,
    this.emptyMessage,
    this.emptyTitle,
    this.emptyIcon,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.emptyActionIcon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Kolors.kPrimary,
      backgroundColor: Colors.white,
      child: child,
    );
  }
}