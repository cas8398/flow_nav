import 'package:flutter/material.dart';

/// Signature for a custom push handler.
/// Used to integrate with GoRouter, GetX, AutoRoute, etc.
///
/// [context] — the current build context.
/// [builder] — builds the page widget to push.
/// [fullscreenDialog] — whether the route is a fullscreen dialog.
typedef FlowPushHandler = Future<T?> Function<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool fullscreenDialog,
});

/// Signature for a custom pop handler.
typedef FlowPopHandler = void Function(BuildContext context);

/// Global configuration for FlowNav.
/// Initialize once in main.dart via [FlowNavConfig.init].
///
/// ## Basic setup
/// ```dart
/// void main() {
///   FlowNavConfig.init();
///   runApp(MyApp());
/// }
/// ```
///
/// ## With GoRouter
/// ```dart
/// FlowNavConfig.init(
///   onPush: ({required context, required builder, fullscreenDialog = false}) {
///     context.push('/detail');
///     return Future.value(null);
///   },
///   onPop: (context) => context.pop(),
/// );
/// ```
///
/// ## With GetX
/// ```dart
/// FlowNavConfig.init(
///   onPush: ({required context, required builder, fullscreenDialog = false}) {
///     return Get.to(() => builder(context));
///   },
///   onPop: (_) => Get.back(),
/// );
/// ```
///
/// ## With AutoRoute
/// ```dart
/// FlowNavConfig.init(
///   onPush: ({required context, required builder, fullscreenDialog = false}) {
///     return context.router.push(MyRoute());
///   },
///   onPop: (context) => context.router.pop(),
/// );
/// ```
class FlowNavConfig {
  static FlowNavConfig? _instance;

  /// Minimum width to be considered a phone (default: 599)
  final double phoneMaxWidth;

  /// Minimum width to be considered a tablet (default: 600)
  final double tabletMinWidth;

  /// Minimum width to be considered a desktop (default: 1024)
  final double desktopMinWidth;

  /// Default max width for body content
  final double? bodyMaxWidth;

  /// Default padding for body content
  final EdgeInsetsConfig bodyPadding;

  /// Default margin for body content
  final EdgeInsetsConfig bodyMargin;

  /// Custom push handler for phone navigation.
  /// If null, defaults to [Navigator.of(context).push].
  ///
  /// Use this to integrate with GoRouter, GetX, AutoRoute, etc.
  final FlowPushHandler? onPush;

  /// Custom pop handler for phone navigation.
  /// If null, defaults to [Navigator.of(context).pop].
  final FlowPopHandler? onPop;

  const FlowNavConfig._({
    required this.phoneMaxWidth,
    required this.tabletMinWidth,
    required this.desktopMinWidth,
    this.bodyMaxWidth,
    required this.bodyPadding,
    required this.bodyMargin,
    this.onPush,
    this.onPop,
  });

  /// Initialize FlowNav global config. Call this in main.dart before runApp.
  static void init({
    double phoneMaxWidth = 599,
    double tabletMinWidth = 600,
    double desktopMinWidth = 1024,
    double? bodyMaxWidth,
    EdgeInsetsConfig bodyPadding = const EdgeInsetsConfig.all(16),
    EdgeInsetsConfig bodyMargin = const EdgeInsetsConfig.all(0),
    FlowPushHandler? onPush,
    FlowPopHandler? onPop,
  }) {
    _instance = FlowNavConfig._(
      phoneMaxWidth: phoneMaxWidth,
      tabletMinWidth: tabletMinWidth,
      desktopMinWidth: desktopMinWidth,
      bodyMaxWidth: bodyMaxWidth,
      bodyPadding: bodyPadding,
      bodyMargin: bodyMargin,
      onPush: onPush,
      onPop: onPop,
    );
  }

  /// Get the current global instance. Falls back to defaults if not initialized.
  static FlowNavConfig get instance {
    return _instance ??
        const FlowNavConfig._(
          phoneMaxWidth: 599,
          tabletMinWidth: 600,
          desktopMinWidth: 1024,
          bodyPadding: EdgeInsetsConfig.all(16),
          bodyMargin: EdgeInsetsConfig.all(0),
        );
  }
}

/// Simple edge insets configuration (avoids importing Flutter in config).
class EdgeInsetsConfig {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const EdgeInsetsConfig.all(double value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  const EdgeInsetsConfig.symmetric({
    double horizontal = 0,
    double vertical = 0,
  })  : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  const EdgeInsetsConfig.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });
}
