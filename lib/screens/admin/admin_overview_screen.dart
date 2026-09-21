import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../models/site_settings.dart';
import '../../providers.dart';
import '../../widgets/admin_scaffold.dart';

class AdminOverviewScreen extends ConsumerWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(allProjectsProvider);
    final messages = ref.watch(messagesProvider);
    final settingsAsync = ref.watch(siteSettingsProvider);
    final settings = settingsAsync.value ?? SiteSettings.defaults;

    return AdminScaffold(
      title: 'Overview',
      selectedPath: '/admin',
      child: projects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _AdminLoadError(message: 'Projects could not be loaded.'),
        data: (projectList) => messages.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const _AdminLoadError(message: 'Messages could not be loaded.'),
          data: (messageList) {
            final unread = messageList.where((message) => !message.read).length;
            return LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good to see you.', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Keep the public portfolio accurate, current, and honest about your junior-level experience.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 26),
                      GridView.count(
                        crossAxisCount: compact ? 2 : 4,
                        childAspectRatio: compact ? 1.4 : 1.75,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _MetricCard(label: 'Total projects', value: '${projectList.length}', icon: Icons.folder_outlined),
                          _MetricCard(label: 'Messages', value: '${messageList.length}', icon: Icons.mail_outline),
                          _MetricCard(label: 'Unread', value: '$unread', icon: Icons.mark_email_unread_outlined),
                          _MetricCard(label: 'Projects shipped', value: '${settings.projectsShipped}', icon: Icons.rocket_launch_outlined),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _MetricCard(label: 'Years experience', value: '${settings.yearsExperience}', icon: Icons.timeline_outlined, wide: true),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent projects', style: Theme.of(context).textTheme.titleLarge),
                          Text('${projectList.where((p) => p.published).length} published'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (projectList.isEmpty)
                        const Text('No projects yet. Add your first project from Projects.')
                      else
                        ...projectList.take(5).map((project) => _ProjectRow(project: project)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, this.wide = false});
  final String label;
  final String value;
  final IconData icon;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: wide ? 34 : 28)),
                  const SizedBox(height: 3),
                  Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(project.published ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        title: Text(project.title),
        subtitle: Text('${project.category} • ${project.techStack.take(3).join(' • ')}'),
        trailing: project.featured ? const Icon(Icons.star, size: 20) : null,
      ),
    );
  }
}

class _AdminLoadError extends StatelessWidget {
  const _AdminLoadError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(message)));
  }
}
