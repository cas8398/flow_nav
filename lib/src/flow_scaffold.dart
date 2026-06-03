import 'package:flutter/material.dart';
import 'flow_nav_breakpoint.dart';
import 'flow_nav_config.dart';
import 'flow_appbar.dart';

/// The main scaffold for flow_nav.
///
/// Automatically adapts layout based on screen size:
/// - **Phone**: standard [Scaffold] with AppBar, body fills screen.
/// - **Tablet**: two-column layout — list + detail panel side by side.
/// - **Desktop**: two or three-column layout with optional sidebar.
///
/// Example:
/// ```dart
/// FlowScaffold(
///   appBar: FlowAppBar(
///     title: Text('Home'),
///     toolbarWidget: MyDesktopToolbar(),
///   ),
///   body: MyListView(),
///   detailPanel: _selectedItem != null ? DetailView(_selectedItem!) : null,
///   sidebar: MySidebar(),
/// )
/// ```
class FlowScaffold extends StatelessWidget {
  /// The dynamic AppBar. Use [FlowAppBar] for adaptive behavior.
  final PreferredSizeWidget? appBar;

  /// Main body content (list, grid, etc).
  final Widget body;

  /// Detail panel shown beside body on tablet/desktop.
  /// On phone this is ignored — use [FlowNavController.open] instead.
  final Widget? detailPanel;

  /// Sidebar shown only on desktop (left of body).
  final Widget? sidebar;

  /// Width of the sidebar on desktop (default: 240).
  final double sidebarWidth;

  /// Width of the body/list panel on tablet and desktop (default: 320).
  final double bodyPanelWidth;

  /// Max width of the entire content area. Centers content on very wide screens.
  /// Falls back to [FlowNavConfig.instance.bodyMaxWidth] if not set.
  final double? maxWidth;

  /// Padding inside the body content area.
  /// Falls back to [FlowNavConfig.instance.bodyPadding] if not set.
  final EdgeInsets? bodyPadding;

  /// Margin around the body content area.
  /// Falls back to [FlowNavConfig.instance.bodyMargin] if not set.
  final EdgeInsets? bodyMargin;

  /// Background color of the scaffold.
  final Color? backgroundColor;

  /// Widget shown in the detail panel when nothing is selected.
  /// Defaults to a centered empty state if not provided.
  final Widget? emptyDetail;

  /// Bottom navigation bar (phone / tablet).
  final Widget? bottomNavigationBar;

  /// Floating action button.
  final Widget? floatingActionButton;

  /// Drawer for phone/tablet.
  final Widget? drawer;

  /// Force a specific screen type (useful for testing or preview).
  final FlowScreenType? forceScreenType;

  /// Alignment of the body content when maxWidth is applied.
  /// - [FlowBodyAlign.start] (default): Aligns body to the left/start.
  /// - [FlowBodyAlign.center]: Centers the body.
  final FlowBodyAlign bodyAlign;

  const FlowScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.detailPanel,
    this.sidebar,
    this.sidebarWidth = 240,
    this.bodyPanelWidth = 320,
    this.maxWidth,
    this.bodyPadding,
    this.bodyMargin,
    this.backgroundColor,
    this.emptyDetail,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.forceScreenType,
    this.bodyAlign = FlowBodyAlign.start,
  });

  EdgeInsets _resolvedPadding() {
    if (bodyPadding != null) return bodyPadding!;
    final c = FlowNavConfig.instance.bodyPadding;
    return EdgeInsets.fromLTRB(c.left, c.top, c.right, c.bottom);
  }

  EdgeInsets _resolvedMargin() {
    if (bodyMargin != null) return bodyMargin!;
    final c = FlowNavConfig.instance.bodyMargin;
    return EdgeInsets.fromLTRB(c.left, c.top, c.right, c.bottom);
  }

  double? _resolvedMaxWidth() {
    return maxWidth ?? FlowNavConfig.instance.bodyMaxWidth;
  }

  @override
  Widget build(BuildContext context) {
    final screenType = forceScreenType ?? FlowNavBreakpoint.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: drawer,
      bottomNavigationBar:
          screenType == FlowScreenType.phone ? bottomNavigationBar : null,
      floatingActionButton: floatingActionButton,
      appBar: screenType == FlowScreenType.phone ? appBar : null,
      body: _buildBody(context, screenType),
    );
  }

  Widget _buildBody(BuildContext context, FlowScreenType screenType) {
    Widget content;

    switch (screenType) {
      case FlowScreenType.phone:
        content = _buildPhoneBody();
        break;
      case FlowScreenType.tablet:
        content = _buildTabletBody();
        break;
      case FlowScreenType.desktop:
        content = _buildDesktopBody();
        break;
    }

    final resolvedMax = _resolvedMaxWidth();
    if (resolvedMax != null) {
      return Align(
        alignment: bodyAlign == FlowBodyAlign.center
            ? Alignment.topCenter
            : Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: resolvedMax),
          child: content,
        ),
      );
    }

    return content;
  }

  /// Phone: single column, body fills screen
  Widget _buildPhoneBody() {
    return Container(
      margin: _resolvedMargin(),
      padding: _resolvedPadding(),
      child: body,
    );
  }

  /// Tablet: appbar on top + body | detail side by side
  Widget _buildTabletBody() {
    return Column(
      children: [
        if (appBar != null)
          SizedBox(
            height: appBar!.preferredSize.height,
            child: appBar,
          ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: bodyPanelWidth,
                child: Container(
                  margin: _resolvedMargin(),
                  padding: _resolvedPadding(),
                  child: body,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: detailPanel ?? _defaultEmptyDetail(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Desktop: appbar on top + sidebar | body | detail
  Widget _buildDesktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sidebar != null) ...[
          SizedBox(width: sidebarWidth, child: sidebar),
          const VerticalDivider(width: 1),
        ],
        Expanded(
          child: Column(
            children: [
              if (appBar != null) ...[
                SizedBox(
                  height: appBar!.preferredSize.height,
                  width: double.infinity,
                  child: appBar,
                ),
                const Divider(height: 1),
              ],
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: bodyPanelWidth,
                      child: Container(
                        margin: _resolvedMargin(),
                        padding: _resolvedPadding(),
                        child: body,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: detailPanel ?? _defaultEmptyDetail(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _defaultEmptyDetail() {
    return emptyDetail ??
        const Center(
          child: Text(
            'Select an item',
            style: TextStyle(color: Colors.grey),
          ),
        );
  }
}

/// Enum to define the body alignment when maxWidth is applied.
enum FlowBodyAlign {
  /// Aligns the body to the left/start (default).
  start,

  /// Centers the body horizontally.
  center,
}
