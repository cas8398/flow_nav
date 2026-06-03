import 'package:flutter/widgets.dart';
import 'flow_nav_config.dart';

/// Represents the current screen type based on width.
enum FlowScreenType { phone, tablet, desktop }

/// Utility to resolve current screen type from context or width.
class FlowNavBreakpoint {
  /// Resolve screen type from a [BuildContext].
  static FlowScreenType of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return fromWidth(width);
  }

  /// Resolve screen type from a raw [width] value.
  static FlowScreenType fromWidth(double width) {
    final config = FlowNavConfig.instance;
    if (width >= config.desktopMinWidth) return FlowScreenType.desktop;
    if (width >= config.tabletMinWidth) return FlowScreenType.tablet;
    return FlowScreenType.phone;
  }

  /// Returns true if current screen is phone.
  static bool isPhone(BuildContext context) =>
      of(context) == FlowScreenType.phone;

  /// Returns true if current screen is tablet.
  static bool isTablet(BuildContext context) =>
      of(context) == FlowScreenType.tablet;

  /// Returns true if current screen is desktop.
  static bool isDesktop(BuildContext context) =>
      of(context) == FlowScreenType.desktop;

  /// Returns true if screen is tablet or larger.
  static bool isLarge(BuildContext context) =>
      of(context) != FlowScreenType.phone;
}
