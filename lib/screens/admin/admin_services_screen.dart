import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/service_model.dart';
import '../../providers.dart';
import '../../widgets/admin_scaffold.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({super.key});

  Future<void> _edit(BuildContext context, {ServiceModel? service}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ServiceEditorDialog(service: service),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text('Delete “${service.title}”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(firebaseServiceProvider).deleteService(service.id);
    ref.invalidate(servicesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    return AdminScaffold(
      title: 'Services',
      selectedPath: '/admin/services',
      child: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Services could not be loaded.')),
        data: (services) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Services CMS', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        const Text('Keep each offering focused and honest about your current capabilities.'),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _edit(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add service'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: services.isEmpty
                    ? const Center(child: Text('No services yet.'))
                    : ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: services.length,
                        onReorderItem: (oldIndex, newIndex) async {
                          final updated = [...services];
                          final item = updated.removeAt(oldIndex);
                          updated.insert(newIndex, item);
                          await ref.read(firebaseServiceProvider).setServiceOrder(updated);
                        },
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return Card(
                            key: ValueKey(service.id),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_indicator)),
                              title: Text(service.title),
                              subtitle: Text(service.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () => _edit(context, service: service),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () => _delete(context, ref, service),
                                    icon: const Icon(Icons.delete_outline),
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

class _ServiceEditorDialog extends ConsumerStatefulWidget {
  const _ServiceEditorDialog({this.service});
  final ServiceModel? service;

  @override
  ConsumerState<_ServiceEditorDialog> createState() => _ServiceEditorDialogState();
}

class _ServiceEditorDialogState extends ConsumerState<_ServiceEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _icon;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.service?.title ?? '');
    _description = TextEditingController(text: widget.service?.description ?? '');
    _icon = TextEditingController(text: widget.service?.iconName ?? 'code');
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _icon.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'iconName': _icon.text.trim(),
        'order': widget.service?.order ?? 999,
      };
      final service = ref.read(firebaseServiceProvider);
      if (widget.service == null) {
        await service.createService(data);
      } else {
        await service.updateService(widget.service!.id, data);
      }
      ref.invalidate(servicesProvider);
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
      title: Text(widget.service == null ? 'Add service' : 'Edit service'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _title, validator: _required, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextFormField(controller: _description, validator: _required, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextFormField(controller: _icon, decoration: const InputDecoration(labelText: 'Icon name', hintText: 'phone_android, web, cloud, design_services, api, bug_report')),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Supported icon names: phone_android, web, cloud, design_services, api, bug_report, code.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Saving…' : 'Save service'),
        ),
      ],
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}
