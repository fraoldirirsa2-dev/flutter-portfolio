import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.eyebrow,
    required this.title,
    this.subtitle,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: .10),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              eyebrow.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(title, style: theme.textTheme.headlineLarge),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 13),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.72,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
