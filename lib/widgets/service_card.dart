import 'package:flutter/material.dart';

import '../models/service_model.dart';
import '../theme.dart';

class ServiceCard extends StatefulWidget {
  const ServiceCard({required this.service, super.key});

  final ServiceModel service;

  static IconData iconFor(String name) {
    switch (name) {
      case 'phone_android': return Icons.phone_android_rounded;
      case 'web': return Icons.web_rounded;
      case 'cloud': return Icons.cloud_rounded;
      case 'design_services': return Icons.design_services_rounded;
      case 'api': return Icons.api_rounded;
      case 'bug_report': return Icons.bug_report_rounded;
      default: return Icons.code_rounded;
    }
  }

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hovered
                ? AppColors.cyan.withValues(alpha: .35)
                : AppColors.border,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: AppColors.cyan.withValues(alpha: .08), blurRadius: 26)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(ServiceCard.iconFor(widget.service.iconName), color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(widget.service.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 9),
            Expanded(
              child: Text(
                widget.service.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.62,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Explore',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 5),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.only(left: _hovered ? 3 : 0),
                  child: const Icon(Icons.arrow_forward_rounded, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
