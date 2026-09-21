import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import 'responsive.dart';
import 'liquid_glass_foundation.dart';

class AdminScaffold extends ConsumerWidget {
  const AdminScaffold({
    required this.title,
    required this.selectedPath,
    required this.child,
    super.key,
  });

  final String title;
  final String selectedPath;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigation = AdminNavigation(
      selectedPath: selectedPath,
      onLogout: () => _logout(context, ref),
    );

    return Scaffold(
      drawer: Responsive.isDesktop(context) ? null : Drawer(child: navigation),
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'View public portfolio',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.public),
          ),
          if (Responsive.isDesktop(context))
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: LiquidGlassActionButton(
                onPressed: () => _logout(context, ref),
                child: const Text('Logout'),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          if (Responsive.isDesktop(context))
            SizedBox(width: 250, child: LiquidGlassFoundation(
              borderRadius: 24,
              margin: const EdgeInsets.fromLTRB(12, 12, 0, 12),
              child: navigation,
            )),
          Expanded(child: child),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(firebaseServiceProvider).signOut();
    if (context.mounted) context.go('/admin/login');
  }
}

class AdminNavigation extends StatelessWidget {
  const AdminNavigation({
    required this.selectedPath,
    required this.onLogout,
    super.key,
  });

  final String selectedPath;
  final VoidCallback onLogout;

  static const _items = [
    (label: 'Overview', icon: Icons.dashboard_outlined, path: '/admin'),
    (label: 'Projects', icon: Icons.folder_copy_outlined, path: '/admin/projects'),
    (label: 'Services', icon: Icons.design_services_outlined, path: '/admin/services'),
    (label: 'Settings', icon: Icons.settings_outlined, path: '/admin/settings'),
    (label: 'Messages', icon: Icons.mail_outline_rounded, path: '/admin/messages'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (final item in _items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        selected: selectedPath == item.path,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Icon(item.icon),
                        title: Text(item.label),
                        onTap: () {
                          Navigator.of(context).maybePop();
                          context.go(item.path);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
