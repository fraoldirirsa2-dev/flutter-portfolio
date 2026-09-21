import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../providers.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/portfolio_media.dart';

class AdminProjectsScreen extends ConsumerWidget {
  const AdminProjectsScreen({super.key});

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Project? project,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ProjectEditorDialog(project: project),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
          'Delete “${project.title}” from the portfolio? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(firebaseServiceProvider).deleteProject(project);
      ref.invalidate(allProjectsProvider);
      ref.invalidate(publishedProjectsProvider);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(allProjectsProvider);

    return AdminScaffold(
      title: 'Projects',
      selectedPath: '/admin/projects',
      child: projectsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Projects could not be loaded.\n$error'),
        ),
        data: (projects) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project CMS',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${projects.length} projects • reorder with drag handles',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openEditor(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add project'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: projects.isEmpty
                    ? const Center(
                        child: Text(
                          'No projects yet. Add your first project.',
                        ),
                      )
                    : ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: projects.length,
                        onReorderItem: (oldIndex, newIndex) async {
                          final updated = [...projects];
                          final item = updated.removeAt(oldIndex);
                          updated.insert(newIndex, item);
                          await ref
                              .read(firebaseServiceProvider)
                              .setProjectOrder(updated);
                          ref.invalidate(allProjectsProvider);
                          ref.invalidate(publishedProjectsProvider);
                        },
                        itemBuilder: (context, index) {
                          final project = projects[index];

                          return Card(
                            key: ValueKey(project.id),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              leading: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(
                                  Icons.drag_indicator,
                                ),
                              ),
                              title: Text(project.title),
                              subtitle: Text(
                                '${project.category} • ${project.techStack.join(', ')}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Wrap(
                                spacing: 2,
                                crossAxisAlignment:
                                    WrapCrossAlignment.center,
                                children: [
                                  Switch.adaptive(
                                    value: project.published,
                                    onChanged: (value) async {
                                      await ref
                                          .read(firebaseServiceProvider)
                                          .updateProject(
                                        project.id,
                                        {'published': value},
                                      );
                                      ref.invalidate(
                                          allProjectsProvider);
                                      ref.invalidate(
                                          publishedProjectsProvider);
                                    },
                                  ),
                                  IconButton(
                                    tooltip: project.featured
                                        ? 'Unfeature'
                                        : 'Feature',
                                    onPressed: () async {
                                      await ref
                                          .read(firebaseServiceProvider)
                                          .updateProject(
                                        project.id,
                                        {
                                          'featured':
                                              !project.featured,
                                        },
                                      );
                                      ref.invalidate(
                                          allProjectsProvider);
                                      ref.invalidate(
                                          publishedProjectsProvider);
                                    },
                                    icon: Icon(
                                      project.featured
                                          ? Icons.star
                                          : Icons.star_border,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () => _openEditor(
                                      context,
                                      ref,
                                      project: project,
                                    ),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () => _confirmDelete(
                                      context,
                                      ref,
                                      project,
                                    ),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectEditorDialog extends ConsumerStatefulWidget {
  const _ProjectEditorDialog({this.project});

  final Project? project;

  @override
  ConsumerState<_ProjectEditorDialog> createState() =>
      _ProjectEditorDialogState();
}

class _ProjectEditorDialogState
    extends ConsumerState<_ProjectEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _imageUrl;
  late final TextEditingController _github;
  late final TextEditingController _live;
  late final TextEditingController _techStack;

  late String _category;
  late bool _published;
  late bool _featured;
  bool _saving = false;

  static const _categories = [
    'Mobile Apps',
    'Web Apps',
    'Packages',
    'UI/UX',
    'Open Source',
  ];

  @override
  void initState() {
    super.initState();

    final project = widget.project;

    _title = TextEditingController(text: project?.title ?? '');
    _description = TextEditingController(
      text: project?.description ?? '',
    );
    _imageUrl = TextEditingController(
      text: project?.imageUrl ?? '',
    );
    _github = TextEditingController(
      text: project?.githubUrl ?? '',
    );
    _live = TextEditingController(
      text: project?.liveUrl ?? '',
    );
    _techStack = TextEditingController(
      text: project?.techStack.join(', ') ?? '',
    );
    _category = project?.category ?? _categories.first;
    _published = project?.published ?? false;
    _featured = project?.featured ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _imageUrl.dispose();
    _github.dispose();
    _live.dispose();
    _techStack.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);

    try {
      final data = <String, dynamic>{
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'category': _category,
        'techStack': _techStack.text
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(),
        'imageUrl': _imageUrl.text.trim(),
        'githubUrl': _github.text.trim(),
        'liveUrl': _live.text.trim(),
        'featured': _featured,
        'published': _published,
        'order': widget.project?.order ?? 999,
      };

      final service = ref.read(firebaseServiceProvider);

      if (widget.project == null) {
        await service.createProject(data);
      } else {
        await service.updateProject(
          widget.project!.id,
          data,
        );
      }

      ref.invalidate(allProjectsProvider);
      ref.invalidate(publishedProjectsProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.project == null
            ? 'Add project'
            : 'Edit project',
      ),
      content: SizedBox(
        width: 760,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 560;

                    final titleField = TextFormField(
                      controller: _title,
                      validator: _required,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    );

                    final categoryField =
                        DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: [
                        for (final category in _categories)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _category = value ?? _category;
                        });
                      },
                    );

                    if (compact) {
                      return Column(
                        children: [
                          titleField,
                          const SizedBox(height: 12),
                          categoryField,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Expanded(child: titleField),
                        const SizedBox(width: 12),
                        Expanded(child: categoryField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  validator: _required,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _techStack,
                  validator: _required,
                  decoration: const InputDecoration(
                    labelText: 'Tech stack',
                    hintText:
                        'Flutter, Dart, Firebase, Riverpod',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Project image path or HTTPS URL',
                    hintText:
                        'assets/images/project_01.webp or https://…',
                    prefixIcon:
                        Icon(Icons.image_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 560;

                    final githubField = TextFormField(
                      controller: _github,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'GitHub URL',
                      ),
                    );

                    final liveField = TextFormField(
                      controller: _live,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Live Demo URL',
                      ),
                    );

                    if (compact) {
                      return Column(
                        children: [
                          githubField,
                          const SizedBox(height: 12),
                          liveField,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Expanded(child: githubField),
                        const SizedBox(width: 12),
                        Expanded(child: liveField),
                      ],
                    );
                  },
                ),
                if (_imageUrl.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: PortfolioImage(
                        source: _imageUrl.text.trim(),
                      ),
                    ),
                  ),
                ],
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _published,
                  onChanged: (value) => setState(() {
                    _published = value;
                  }),
                  title: const Text('Published'),
                  subtitle: const Text(
                    'Published projects appear on the public gallery.',
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _featured,
                  onChanged: (value) => setState(() {
                    _featured = value;
                  }),
                  title: const Text('Featured'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Saving…' : 'Save project'),
        ),
      ],
    );
  }

  static String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
