import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_nav/flow_nav.dart';

void main() {
  // ── FlowNavConfig ──────────────────────────────────────────────────────────

  group('FlowNavConfig', () {
    test('uses default values when not initialized', () {
      final config = FlowNavConfig.instance;
      expect(config.tabletMinWidth, 600);
      expect(config.desktopMinWidth, 1024);
      expect(config.phoneMaxWidth, 599);
    });

    test('applies custom values after init', () {
      FlowNavConfig.init(
        tabletMinWidth: 700,
        desktopMinWidth: 1200,
      );
      final config = FlowNavConfig.instance;
      expect(config.tabletMinWidth, 700);
      expect(config.desktopMinWidth, 1200);
    });
  });

  // ── FlowNavBreakpoint ──────────────────────────────────────────────────────

  group('FlowNavBreakpoint', () {
    // Reset to defaults before each test
    setUp(() => FlowNavConfig.init());

    test('returns phone for width below tabletMinWidth', () {
      expect(FlowNavBreakpoint.fromWidth(400), FlowScreenType.phone);
    });

    test('returns tablet for width between tablet and desktop', () {
      expect(FlowNavBreakpoint.fromWidth(800), FlowScreenType.tablet);
    });

    test('returns desktop for width above desktopMinWidth', () {
      expect(FlowNavBreakpoint.fromWidth(1280), FlowScreenType.desktop);
    });

    test('returns phone at exact phoneMaxWidth boundary', () {
      expect(FlowNavBreakpoint.fromWidth(599), FlowScreenType.phone);
    });

    test('returns tablet at exact tabletMinWidth boundary', () {
      expect(FlowNavBreakpoint.fromWidth(600), FlowScreenType.tablet);
    });

    test('returns desktop at exact desktopMinWidth boundary', () {
      expect(FlowNavBreakpoint.fromWidth(1024), FlowScreenType.desktop);
    });
  });

  // ── FlowScaffold widget tests ──────────────────────────────────────────────

  group('FlowScaffold', () {
    setUp(() => FlowNavConfig.init());

    testWidgets('renders body widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.phone,
            body: const Text('Hello Body'),
          ),
        ),
      );
      expect(find.text('Hello Body'), findsOneWidget);
    });

    testWidgets('renders AppBar on phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.phone,
            appBar: AppBar(title: const Text('Phone AppBar')),
            body: const SizedBox(),
          ),
        ),
      );
      expect(find.text('Phone AppBar'), findsOneWidget);
    });

    testWidgets('does NOT render AppBar widget directly on desktop',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.desktop,
            appBar: AppBar(title: const Text('Phone AppBar')),
            body: const SizedBox(),
          ),
        ),
      );
      // On desktop, appBar is placed inside Column, not as Scaffold.appBar
      // The Scaffold itself should have no appBar
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, isNull);
    });

    testWidgets('shows detail panel on tablet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.tablet,
            body: const Text('List'),
            detailPanel: const Text('Detail Panel'),
          ),
        ),
      );
      expect(find.text('Detail Panel'), findsOneWidget);
    });

    testWidgets('shows empty detail state when detailPanel is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.tablet,
            body: const SizedBox(),
            emptyDetail: const Text('Nothing selected'),
          ),
        ),
      );
      expect(find.text('Nothing selected'), findsOneWidget);
    });

    testWidgets('shows sidebar on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.desktop,
            body: const SizedBox(),
            sidebar: const Text('Sidebar'),
          ),
        ),
      );
      expect(find.text('Sidebar'), findsOneWidget);
    });

    testWidgets('does NOT show sidebar on phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.phone,
            body: const SizedBox(),
            sidebar: const Text('Sidebar'),
          ),
        ),
      );
      expect(find.text('Sidebar'), findsNothing);
    });

    testWidgets('shows bottomNavigationBar on phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.phone,
            body: const SizedBox(),
            bottomNavigationBar: const Text('BottomNav'),
          ),
        ),
      );
      expect(find.text('BottomNav'), findsOneWidget);
    });

    testWidgets('hides bottomNavigationBar on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowScaffold(
            forceScreenType: FlowScreenType.desktop,
            body: const SizedBox(),
            bottomNavigationBar: const Text('BottomNav'),
          ),
        ),
      );
      expect(find.text('BottomNav'), findsNothing);
    });
  });

  // ── FlowAppBar ─────────────────────────────────────────────────────────────

  group('FlowAppBar', () {
    testWidgets('shows title on phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: FlowAppBar(
              title: const Text('App Title'),
              forceScreenType: FlowScreenType.phone,
            ),
            body: const SizedBox(),
          ),
        ),
      );
      expect(find.text('App Title'), findsOneWidget);
    });

    testWidgets('shows toolbarWidget on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: FlowAppBar(
              title: const Text('App Title'),
              toolbarWidget: const Text('Desktop Toolbar'),
              forceScreenType: FlowScreenType.desktop,
            ),
            body: const SizedBox(),
          ),
        ),
      );
      expect(find.text('Desktop Toolbar'), findsOneWidget);
    });

    testWidgets('falls back to AppBar when toolbarWidget is null on desktop',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: FlowAppBar(
              title: const Text('Fallback Title'),
              forceScreenType: FlowScreenType.desktop,
            ),
            body: const SizedBox(),
          ),
        ),
      );
      expect(find.text('Fallback Title'), findsOneWidget);
    });
  });
}
