import 'package:flutter/material.dart';

import '../models/service_model.dart';
import '../theme.dart';
import 'liquid_glass_foundation.dart';

class ServiceCard extends StatefulWidget {
  const ServiceCard({required this.service, super.key});

  final ServiceModel service;

  static IconData iconFor(String name) {
    switch (name) {
      case 'phone_android':
        return Icons.phone_android_rounded;
      case 'web':
        return Icons.web_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'design_services':
        return Icons.design_services_rounded;
      case 'api':
        return Icons.api_rounded;
      case 'bug_report':
        return Icons.bug_report_rounded;
      default:
        return Icons.code_rounded;
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
    final dark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: LiquidGlassFoundation(
          borderRadius: 26,
          blur: 20,
          padding: const EdgeInsets.all(23),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [Colors.white.withValues(alpha: .10), Colors.white.withValues(alpha: .025)]
                : [Colors.white.withValues(alpha: .72), Colors.white.withValues(alpha: .32)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _hovered ? .24 : .12),
                      blurRadius: _hovered ? 24 : 14,
                    ),
                  ],
                ),
                child: Icon(
                  ServiceCard.iconFor(widget.service.iconName),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                widget.service.title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                widget.service.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Explore',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 160),
                    padding: EdgeInsets.only(left: _hovered ? 3 : 0),
                    child: const Icon(Icons.arrow_forward_rounded, size: 17),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
