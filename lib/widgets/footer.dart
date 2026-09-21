import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/site_settings.dart';
import 'responsive.dart';

class PortfolioFooter extends StatelessWidget {
  const PortfolioFooter({required this.settings, super.key});

  final SiteSettings settings;

  Future<void> _open(String value) async {
    final uri = Uri.tryParse(value);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PortfolioContentFrame(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          0,
          26,
          0,
          Responsive.isMobile(context) ? 28 : 38,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: .08),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 18,
              runSpacing: 12,
              children: [
                Text(
                  settings.footerTagline.isEmpty
                      ? '${settings.name} — ${settings.role}'
                      : settings.footerTagline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final entry in settings.socials.entries)
                      if (entry.value.isNotEmpty)
                        IconButton(
                          tooltip: entry.key,
                          onPressed: () => _open(entry.value),
                          icon: Icon(_icon(entry.key)),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '© ${DateTime.now().year} ${settings.name}. ${settings.footerRightText}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _icon(String key) {
    switch (key) {
      case 'github':
        return Icons.code_rounded;
      case 'linkedin':
        return Icons.business_center_outlined;
      case 'twitter':
        return Icons.alternate_email;
      case 'stackoverflow':
        return Icons.question_answer_outlined;
      case 'medium':
        return Icons.article_outlined;
      default:
        return Icons.link_rounded;
    }
  }
}
