import 'package:flutter/material.dart';
import 'package:flow_nav/flow_nav.dart';

// ── Choose your router setup — uncomment one ────────────────────────────────
// Option A: Default Flutter Navigator (no extra setup needed)
// Option B: GoRouter
// Option C: GetX
// Option D: AutoRoute
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── Option A: Default Flutter Navigator ───────────────────────────────────
  FlowNavConfig.init(
    tabletMinWidth: 600,
    desktopMinWidth: 1024,
    bodyPadding: const EdgeInsetsConfig.symmetric(horizontal: 16, vertical: 8),
    bodyMaxWidth: 1400,
  );

  // ── Option B: GoRouter ─────────────────────────────────────────────────────
  // FlowNavConfig.init(
  //   onPush: ({required context, required builder, fullscreenDialog = false}) {
  //     context.push('/detail');
  //     return Future.value(null);
  //   },
  //   onPop: (context) => context.pop(),
  // );

  // ── Option C: GetX ─────────────────────────────────────────────────────────
  // FlowNavConfig.init(
  //   onPush: ({required context, required builder, fullscreenDialog = false}) {
  //     return Get.to(() => builder(context));
  //   },
  //   onPop: (_) => Get.back(),
  // );

  // ── Option D: AutoRoute ────────────────────────────────────────────────────
  // FlowNavConfig.init(
  //   onPush: ({required context, required builder, fullscreenDialog = false}) {
  //     return context.router.push(DetailRoute());
  //   },
  //   onPop: (context) => context.router.pop(),
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flow_nav Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const FlowNavScreen(),
    );
  }
}

// ── Entry point widget ───────────────────────────────────────────────────────

class FlowNavScreen extends StatefulWidget {
  const FlowNavScreen({super.key});

  @override
  State<FlowNavScreen> createState() => _FlowNavScreenState();
}

class _FlowNavScreenState extends State<FlowNavScreen> {
  int _sidebarIndex = 0;
  Widget? _detailPanel;
  _Item? _selectedItem;

  final _sidebarItems = const [
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    (icon: Icons.inbox_outlined, selectedIcon: Icons.inbox, label: 'Inbox'),
    (
      icon: Icons.bookmark_outline,
      selectedIcon: Icons.bookmark,
      label: 'Saved'
    ),
    (
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings'
    ),
  ];

  void _onItemTap(_Item item) {
    FlowNavController.open(
      context: context,
      builder: (_) => _DetailPage(item: item),
      onDetailOpen: (widget) {
        setState(() {
          _selectedItem = item;
          _detailPanel = widget;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      appBar: FlowAppBar(
        title: const Text('flow_nav demo'),
        toolbarWidget: _DesktopToolbar(
          sidebarIndex: _sidebarIndex,
          items: _sidebarItems,
          onTap: (i) => setState(() => _sidebarIndex = i),
        ),
        toolbarHeight: 52,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {},
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      sidebar: _Sidebar(
        selectedIndex: _sidebarIndex,
        items: _sidebarItems,
        onTap: (i) => setState(() => _sidebarIndex = i),
      ),
      body: _ItemList(
        items: _items,
        selectedItem: _selectedItem,
        onTap: _onItemTap,
      ),
      detailPanel: _detailPanel,
      emptyDetail: const _EmptyDetail(),
      sidebarWidth: 200,
      bodyPanelWidth: 300,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sidebarIndex,
        onDestinationSelected: (i) => setState(() => _sidebarIndex = i),
        destinations: _sidebarItems
            .map((e) => NavigationDestination(
                  icon: Icon(e.icon),
                  selectedIcon: Icon(e.selectedIcon),
                  label: e.label,
                ))
            .toList(),
      ),
    );
  }
}

// ── Desktop toolbar ──────────────────────────────────────────────────────────

class _DesktopToolbar extends StatelessWidget {
  final int sidebarIndex;
  final List<({IconData icon, IconData selectedIcon, String label})> items;
  final ValueChanged<int> onTap;

  const _DesktopToolbar({
    required this.sidebarIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = FlowNavBreakpoint.isDesktop(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (!isDesktop) ...[
            Icon(Icons.route_rounded,
                color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'flow_nav',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: theme.colorScheme.primary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 32),
          ],
          ...items.asMap().entries.map((e) {
            final selected = e.key == sidebarIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  backgroundColor: selected
                      ? theme.colorScheme.primary.withOpacity(0.08)
                      : Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: Icon(selected ? e.value.selectedIcon : e.value.icon,
                    size: 16),
                label:
                    Text(e.value.label, style: const TextStyle(fontSize: 13)),
                onPressed: () => onTap(e.key),
              ),
            );
          }),
          const Spacer(),
          _ScreenBadge(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {},
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}

// ── Screen type badge ────────────────────────────────────────────────────────

class _ScreenBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final type = FlowNavBreakpoint.of(context);
    final (label, color, icon) = switch (type) {
      FlowScreenType.phone => ('Phone', Colors.orange, Icons.phone_android),
      FlowScreenType.tablet => ('Tablet', Colors.teal, Icons.tablet_android),
      FlowScreenType.desktop => ('Desktop', Colors.indigo, Icons.desktop_mac),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sidebar ──────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<({IconData icon, IconData selectedIcon, String label})> items;
  final ValueChanged<int> onTap;

  const _Sidebar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Icon(Icons.route_rounded,
                    color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'flow_nav',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((e) {
            final selected = e.key == selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: ListTile(
                selected: selected,
                selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                leading: Icon(
                  selected ? e.value.selectedIcon : e.value.icon,
                  size: 20,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                title: Text(
                  e.value.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () => onTap(e.key),
                dense: true,
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _ScreenBadge(),
          ),
        ],
      ),
    );
  }
}

// ── Item list ────────────────────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final List<_Item> items;
  final _Item? selectedItem;
  final ValueChanged<_Item> onTap;

  const _ItemList({
    required this.items,
    required this.selectedItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLarge = FlowNavBreakpoint.isLarge(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
          child: Text(
            'ITEMS',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = isLarge && selectedItem?.id == item.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onTap(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon, size: 18, color: item.color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: selected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected
                                        ? theme.colorScheme.onPrimaryContainer
                                            .withOpacity(0.7)
                                        : theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: selected
                                ? theme.colorScheme.onPrimaryContainer
                                    .withOpacity(0.5)
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Empty detail state ───────────────────────────────────────────────────────

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.15),
          ),
          const SizedBox(height: 12),
          Text(
            'Select an item',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Details will appear here',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail page ──────────────────────────────────────────────────────────────

class _DetailPage extends StatelessWidget {
  final _Item item;
  const _DetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPhone = FlowNavBreakpoint.isPhone(context);

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 26, color: item.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: item.color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 15, color: item.color),
                    const SizedBox(width: 6),
                    Text(
                      'flow_nav behavior',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: item.color),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isPhone
                      ? '📱 Phone: this page was pushed as a full screen route via Navigator.push'
                      : '🖥️ Large screen: this widget was swapped into the detail panel — no route push happened',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Content',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.7,
              color: theme.colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );

    if (isPhone) {
      return Scaffold(
        appBar: AppBar(
          title: Text(item.title),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: content,
      );
    }

    return content;
  }
}

// ── Data model ───────────────────────────────────────────────────────────────

class _Item {
  final int id;
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
  final Color color;

  const _Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    required this.color,
  });
}

final _items = List.generate(5, (i) {
  final colors = [
    Colors.indigo,
    Colors.teal,
    Colors.orange,
    Colors.pink,
    Colors.purple
  ];
  final icons = [
    Icons.article_outlined,
    Icons.bookmark_outline,
    Icons.label_outline,
    Icons.star_outline,
    Icons.flag_outlined
  ];
  return _Item(
    id: i + 1,
    title: 'Item ${i + 1}',
    subtitle: 'Subtitle for item ${i + 1}',
    body: 'This is the detail content for Item ${i + 1}.\n\n'
        'On phone this page was pushed fullscreen via Navigator.\n'
        'On tablet/desktop it opened here in the detail panel — no route push happened.\n\n'
        'That is flow_nav working correctly.',
    icon: icons[i % icons.length],
    color: colors[i % colors.length],
  );
});
