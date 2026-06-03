/// flow_nav — Dynamic navigation and layout orchestration for Flutter.
///
/// Automatically adapts:
/// - AppBar → toolbar/menubar on large screens, normal AppBar on phone
/// - Page open → full screen push on phone, detail panel swap on large screens
/// - Layout → single column (phone), split (tablet), three column (desktop)
/// - Router → works with default Navigator, GoRouter, GetX, AutoRoute, or any custom router
///
/// ## Quick Start
///
/// ### 1. Initialize in main.dart
/// ```dart
/// void main() {
///   FlowNavConfig.init(
///     tabletMinWidth: 600,
///     desktopMinWidth: 1024,
///   );
///   runApp(MyApp());
/// }
/// ```
///
/// ### 2. With GoRouter
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
/// ### 3. With GetX
/// ```dart
/// FlowNavConfig.init(
///   onPush: ({required context, required builder, fullscreenDialog = false}) {
///     return Get.to(() => builder(context));
///   },
///   onPop: (_) => Get.back(),
/// );
/// ```
///
/// ### 4. With AutoRoute
/// ```dart
/// FlowNavConfig.init(
///   onPush: ({required context, required builder, fullscreenDialog = false}) {
///     return context.router.push(MyRoute());
///   },
///   onPop: (context) => context.router.pop(),
/// );
/// ```
///
/// ### 5. Use FlowScaffold
/// ```dart
/// FlowScaffold(
///   appBar: FlowAppBar(
///     title: Text('My App'),
///     toolbarWidget: MyDesktopToolbar(),
///   ),
///   body: MyListView(
///     onItemTap: (item) {
///       FlowNavController.open(
///         context: context,
///         builder: (_) => DetailPage(item: item),
///         onDetailOpen: (w) => setState(() => _detail = w),
///       );
///     },
///   ),
///   detailPanel: _detail,
///   sidebar: MySidebar(),
/// )
/// ```
library flow_nav;

export 'src/flow_nav_config.dart';
export 'src/flow_nav_breakpoint.dart';
export 'src/flow_appbar.dart';
export 'src/flow_nav_controller.dart';
export 'src/flow_scaffold.dart';
