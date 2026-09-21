import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/project.dart';
import 'liquid_glass_foundation.dart';
import 'portfolio_media.dart';
import 'responsive.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({required this.project, super.key});

  final Project project;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;
  bool _expanded = false;

  bool get _showDetails => _hovered || _expanded;

  Future<void> _open(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final theme = Theme.of(context);
    final compact = Responsive.isMobile(context);
    final radius = BorderRadius.circular(30);

    return Semantics(
      label: '${p.title} project card',
      button: compact,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered && !compact ? 1.012 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: InkWell(
            borderRadius: radius,
            onTap: compact
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (p.imageUrl.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.secondaryContainer,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.code_rounded,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    PortfolioImage(
                      source: p.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: .02),
                            Colors.black.withValues(alpha: .12),
                            Colors.black.withValues(alpha: .82),
                          ],
                          stops: const [0, .44, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: 15,
                    right: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (p.featured)
                          const LiquidGlassPill(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        LiquidGlassPill(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            p.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: LiquidGlassFoundation(
                        borderRadius: 24,
                        blur: 20,
                        padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: .18),
                            Colors.white.withValues(alpha: .06),
                          ],
                        ),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                p.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 7),
                              if (!_showDetails)
                                _CompactTechRow(tech: p.techStack)
                              else ...[
                                Text(
                                  p.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.42,
                                  ),
                                ),
                                const SizedBox(height: 11),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: p.techStack.take(5).map((tech) {
                                    return LiquidGlassPill(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        tech,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (p.githubUrl.isNotEmpty || p.liveUrl.isNotEmpty)
                                  const SizedBox(height: 11),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (p.githubUrl.isNotEmpty)
                                      _LinkButton(
                                        label: 'GitHub',
                                        icon: Icons.code_rounded,
                                        onTap: () => _open(p.githubUrl),
                                      ),
                                    if (p.liveUrl.isNotEmpty)
                                      _LinkButton(
                                        label: 'Live demo',
                                        icon: Icons.arrow_outward_rounded,
                                        onTap: () => _open(p.liveUrl),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactTechRow extends StatelessWidget {
  const _CompactTechRow({required this.tech});

  final List<String> tech;

  @override
  Widget build(BuildContext context) {
    final visible = tech.take(3).toList();
    return Row(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Text(
                '•',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          Flexible(
            child: Text(
              visible[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 11),
        backgroundColor: Colors.white.withValues(alpha: .10),
        foregroundColor: Colors.white,
        side: BorderSide(
          color: Colors.white.withValues(alpha: .18),
        ),
        overlayColor: Colors.white.withValues(alpha: .08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }
}
