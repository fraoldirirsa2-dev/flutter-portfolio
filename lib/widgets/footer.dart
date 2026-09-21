import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/site_settings.dart';
import '../theme.dart';
import 'responsive.dart';
import 'liquid_glass_foundation.dart';

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

    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.horizontalPadding(context),
        34,
        Responsive.horizontalPadding(context),
        34,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: .35),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LiquidGlassFoundation(
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              spacing: 24,
              children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${settings.name} • ${settings.role}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
                Wrap(
                  spacing: 3,
                  children: [
                    for (final entry in settings.socials.entries)
                      if (entry.value.isNotEmpty)
                        IconButton(
                          tooltip: entry.key,
                          onPressed: () => _open(entry.value),
                          icon: Icon(_icon(entry.key)),
                        ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  settings.footerTagline.isEmpty
                      ? '© ${DateTime.now().year} ${settings.name}. Built with Flutter & Firebase.'
                      : '© ${DateTime.now().year} ${settings.name}. ${settings.footerTagline}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                settings.footerRightText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _icon(String key) {
    switch (key) {
      case 'github':
        return Icons.code;
      case 'linkedin':
        return Icons.business_center_outlined;
      case 'twitter':
        return Icons.alternate_email;
      case 'stackoverflow':
        return Icons.question_answer_outlined;
      case 'medium':
        return Icons.article_outlined;
      default:
        return Icons.link;
    }
  }
}
