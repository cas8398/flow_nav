import 'package:flutter/material.dart';
import 'flow_nav_breakpoint.dart';
import 'flow_nav_config.dart';

/// Callback type when a detail/page is opened.
typedef FlowPageBuilder = Widget Function(BuildContext context);

/// Controls how pages open based on screen size.
///
/// - **Phone**: pushes a full screen route using the configured push handler.
///   Defaults to [Navigator.push] but respects [FlowNavConfig.onPush] so it
///   works with GoRouter, GetX, AutoRoute, and any other router.
/// - **Tablet/Desktop**: calls [onDetailOpen] to swap the detail panel
///   in the parent layout — no navigation needed.
///
/// ## Default Flutter navigator
/// ```dart
/// FlowNavController.open(
///   context: context,
///   builder: (_) => DetailPage(item: item),
///   onDetailOpen: (w) => setState(() => _detail = w),
/// );
/// ```
///
/// ## GoRouter — set once in FlowNavConfig.init()
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
/// ## GetX — set once in FlowNavConfig.init()
/// ```dart
/// FlowNavConfig.init(
///   onPush: ({required context, required builder, fullscreenDialog = false}) {
///     return Get.to(() => builder(context));
///   },
///   onPop: (_) => Get.back(),
/// );
/// ```
///
/// ## AutoRoute — set once in FlowNavConfig.init()
/// ```dart
/// FlowNavConfig.init(
///   onPush: ({required context, required builder, fullscreenDialog = false}) {
///     return context.router.push(MyRoute());
///   },
///   onPop: (context) => context.router.pop(),
/// );
/// ```
class FlowNavController {
  /// Opens a page or detail panel depending on screen size.
  ///
  /// On **phone**: calls the push handler from [FlowNavConfig.onPush] if set,
  /// otherwise falls back to [Navigator.push].
  ///
  /// On **tablet/desktop**: calls [onDetailOpen] with the built widget to swap
  /// the detail panel in place — no route push happens.
  ///
  /// [context] — required for screen size detection and navigation.
  /// [builder] — builds the page/detail widget.
  /// [onDetailOpen] — called on tablet/desktop with the built widget.
  /// [fullscreenDialog] — passed to the push handler (phone only).
  /// [forceScreenType] — override screen type (useful for testing).
  static Future<T?> open<T>({
    required BuildContext context,
    required FlowPageBuilder builder,
    ValueChanged<Widget>? onDetailOpen,
    bool fullscreenDialog = false,
    FlowScreenType? forceScreenType,
  }) {
    final screenType = forceScreenType ?? FlowNavBreakpoint.of(context);

    if (screenType == FlowScreenType.phone) {
      final customPush = FlowNavConfig.instance.onPush;

      // Use custom push handler if provided (GoRouter / GetX / AutoRoute)
      if (customPush != null) {
        return customPush<T>(
          context: context,
          builder: builder,
          fullscreenDialog: fullscreenDialog,
        );
      }

      // Default: Flutter Navigator — uses adaptive route that auto-pops
      // when screen size changes from phone to tablet/desktop.
      return Navigator.of(context).push<T>(
        _AdaptivePageRoute<T>(
          builder: builder,
          fullscreenDialog: fullscreenDialog,
        ),
      );
    }

    // Tablet / Desktop → swap detail panel, no push
    if (onDetailOpen != null) {
      onDetailOpen(builder(context));
    }
    return Future.value(null);
  }

  /// Closes the current route (phone) or clears the detail panel (tablet/desktop).
  ///
  /// On **phone**: calls [FlowNavConfig.onPop] if set, otherwise [Navigator.pop].
  /// On **tablet/desktop**: calls [onDetailClose] to clear the panel.
  ///
  /// [onDetailClose] — called on tablet/desktop to clear the detail panel.
  /// [forceScreenType] — override screen type (useful for testing).
  static void close({
    required BuildContext context,
    VoidCallback? onDetailClose,
    FlowScreenType? forceScreenType,
  }) {
    final screenType = forceScreenType ?? FlowNavBreakpoint.of(context);

    if (screenType == FlowScreenType.phone) {
      final customPop = FlowNavConfig.instance.onPop;

      // Use custom pop handler if provided
      if (customPop != null) {
        customPop(context);
        return;
      }

      // Default: Flutter Navigator
      Navigator.of(context).pop();
    } else {
      onDetailClose?.call();
    }
  }
}

/// A [MaterialPageRoute] that automatically pops when the screen size
/// changes from phone to tablet/desktop. This prevents layout conflicts
/// when the user resizes the window while a phone-style full-screen
/// route is active.
class _AdaptivePageRoute<T> extends MaterialPageRoute<T> {
  _AdaptivePageRoute({
    required super.builder,
    super.fullscreenDialog,
  });

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Check screen size on every rebuild — pop if no longer phone.
    if (!FlowNavBreakpoint.isPhone(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator?.canPop() == true) {
          navigator?.pop();
        }
      });
    }

    return super.buildPage(context, animation, secondaryAnimation);
  }
}
