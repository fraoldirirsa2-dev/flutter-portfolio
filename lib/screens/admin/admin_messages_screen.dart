import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/contact_message.dart';
import '../../providers.dart';
import '../../widgets/admin_scaffold.dart';

class AdminMessagesScreen extends ConsumerWidget {
  const AdminMessagesScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, ContactMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message?'),
        content: Text('Delete the message from ${message.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(firebaseServiceProvider).deleteMessage(message.id);
    }
  }

  Future<void> _email(ContactMessage message) async {
    final uri = Uri(
      scheme: 'mailto',
      path: message.email,
      queryParameters: {'subject': 'Re: Your project inquiry'},
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider);
    return AdminScaffold(
      title: 'Messages',
      selectedPath: '/admin/messages',
      child: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Messages could not be loaded.')),
        data: (messages) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Client messages', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 5),
              Text('${messages.where((m) => !m.read).length} unread of ${messages.length} total'),
              const SizedBox(height: 20),
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text('No contact messages yet.'))
                    : ListView.separated(
                        itemCount: messages.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return Card(
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                child: Text(message.name.isEmpty ? '?' : message.name[0].toUpperCase()),
                              ),
                              title: Text(message.name),
                              subtitle: Text('${message.email} • ${DateFormat.yMMMd().add_jm().format(message.createdAt)}'),
                              trailing: Switch(
                                value: message.read,
                                onChanged: (value) => ref.read(firebaseServiceProvider).updateMessageRead(message.id, value),
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (message.budget.isNotEmpty)
                                        Text('Budget: ${message.budget}', style: Theme.of(context).textTheme.labelLarge),
                                      const SizedBox(height: 10),
                                      Text(message.message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55)),
                                      const SizedBox(height: 14),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          FilledButton.tonalIcon(onPressed: () => _email(message), icon: const Icon(Icons.reply_outlined), label: const Text('Reply by email')),
                                          TextButton.icon(onPressed: () => _delete(context, ref, message), icon: const Icon(Icons.delete_outline), label: const Text('Delete')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
