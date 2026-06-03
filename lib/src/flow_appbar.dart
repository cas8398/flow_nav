import 'package:flutter/material.dart';
import 'flow_nav_breakpoint.dart';

/// A dynamic AppBar that automatically switches between:
/// - Normal [AppBar] on phone
/// - Custom toolbar widget on tablet/desktop (large screen)
///
/// Supports [SliverAppBar] mode via [asSliver] flag.
///
/// Example:
/// ```dart
/// FlowAppBar(
///   title: Text('My App'),
///   toolbarWidget: MyDesktopToolbar(),
///   asSliver: false,
/// )
/// ```
class FlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title shown in the normal AppBar (phone).
  final Widget? title;

  /// Leading widget for the normal AppBar (phone).
  final Widget? leading;

  /// Actions for the normal AppBar (phone).
  final List<Widget>? actions;

  /// Background color for the normal AppBar.
  final Color? backgroundColor;

  /// Elevation for the normal AppBar.
  final double? elevation;

  /// Custom toolbar widget shown on tablet/desktop instead of AppBar.
  /// If null, falls back to normal AppBar on all screen sizes.
  final Widget? toolbarWidget;

  /// Height of the toolbar on large screens (default: 56).
  final double toolbarHeight;

  /// If true, renders as a [SliverAppBar] on phone screens.
  final bool asSliver;

  /// SliverAppBar — whether it floats back when scrolling down.
  final bool floating;

  /// SliverAppBar — whether it pins at the top when scrolling.
  final bool pinned;

  /// SliverAppBar — whether it snaps into view when floating.
  final bool snap;

  /// SliverAppBar — expanded height for large header.
  final double? expandedHeight;

  /// SliverAppBar — flexible space widget (e.g. FlexibleSpaceBar).
  final Widget? flexibleSpace;

  /// Force a specific screen type override (useful for testing).
  final FlowScreenType? forceScreenType;

  const FlowAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.toolbarWidget,
    this.toolbarHeight = 56,
    this.asSliver = false,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.expandedHeight,
    this.flexibleSpace,
    this.forceScreenType,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  FlowScreenType _resolveScreenType(BuildContext context) {
    return forceScreenType ?? FlowNavBreakpoint.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenType = _resolveScreenType(context);
    final isLarge = screenType != FlowScreenType.phone;

    // Large screen with custom toolbar
    if (isLarge && toolbarWidget != null) {
      return SizedBox(
        height: toolbarHeight,
        child: toolbarWidget!,
      );
    }

    // Phone — SliverAppBar
    if (asSliver) {
      return SliverAppBar(
        title: title,
        leading: leading,
        actions: actions,
        backgroundColor: backgroundColor,
        elevation: elevation,
        floating: floating,
        pinned: pinned,
        snap: snap,
        expandedHeight: expandedHeight,
        flexibleSpace: flexibleSpace,
        toolbarHeight: toolbarHeight,
      );
    }

    // Phone — Normal AppBar
    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
      flexibleSpace: flexibleSpace,
    );
  }
}
