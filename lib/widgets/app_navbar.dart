import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/site_settings.dart';
import '../providers.dart';
import '../theme.dart';
import 'liquid_glass_foundation.dart';
import 'responsive.dart';

class AppNavbar extends ConsumerWidget {
  const AppNavbar({
    required this.onSectionSelected,
    required this.onContactSelected,
    super.key,
  });

  final void Function(String section) onSectionSelected;
  final VoidCallback onContactSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final settings =
        ref.watch(siteSettingsProvider).value ?? SiteSettings.defaults;
    final compact = MediaQuery.sizeOf(context).width < 980;

    return PortfolioContentFrame(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withValues(alpha: dark ? .08 : .05),
                blurRadius: 28,
                spreadRadius: -4,
              ),
            ],
          ),
          child: LiquidGlassFoundation(
            height: 64,
            borderRadius: 999,
            blur: 24,
            borderColor: dark ? AppColors.borderStrong : const Color(0x1A111118),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      Colors.white.withValues(alpha: .075),
                      Colors.white.withValues(alpha: .025),
                    ]
                  : [
                      Colors.white.withValues(alpha: .82),
                      Colors.white.withValues(alpha: .62),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: compact ? 1 : 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _Brand(
                        prefix: settings.brandPrefix,
                        name: settings.name,
                        onTap: () => onSectionSelected('hero'),
                      ),
                    ),
                  ),
                  if (!compact)
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: _DesktopNavLinks(
                          settings: settings,
                          onSectionSelected: onSectionSelected,
                        ),
                      ),
                    ),
                  Expanded(
                    flex: compact ? 1 : 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _NavbarLanguagePill(
                            label: 'EN',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          _ThemeToggle(dark: dark, ref: ref),
                          if (compact) ...[
                            const SizedBox(width: 8),
                            LiquidGlassIconAction(
                              tooltip: 'Open navigation',
                              size: 40,
                              onPressed: () => _showMobileMenu(
                                context,
                                settings,
                                onSectionSelected,
                                onContactSelected,
                              ),
                              icon: Icons.menu_rounded,
                            ),
                          ],
                        ],
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

  Future<void> _showMobileMenu(
    BuildContext context,
    SiteSettings settings,
    void Function(String) onSectionSelected,
    VoidCallback onContactSelected,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .66),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: LiquidGlassFoundation(
            borderRadius: 28,
            padding: const EdgeInsets.all(12),
            blur: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                if (settings.showAbout)
                  _SheetLink(settings.navAboutLabel, () {
                    Navigator.pop(context);
                    onSectionSelected('about');
                  }),
                if (settings.showProjects)
                  _SheetLink(settings.navProjectsLabel, () {
                    Navigator.pop(context);
                    onSectionSelected('projects');
                  }),
                if (settings.showServices)
                  _SheetLink(settings.navServicesLabel, () {
                    Navigator.pop(context);
                    onSectionSelected('services');
                  }),
                if (settings.showContact) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: _NavbarCtaButton(
                      label: settings.navCtaLabel,
                      onPressed: () {
                        Navigator.pop(context);
                        onContactSelected();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.prefix, required this.name, required this.onTap});

  final String prefix;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: .25),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Icon(
                Icons.flutter_dash_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 9),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 230),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefix.trim().isNotEmpty) ...[
                    _GradientText(
                      prefix.trim(),
                      style: theme.textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      name.isEmpty ? 'Flutter Developer' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.gradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}

class _DesktopNavLinks extends StatelessWidget {
  const _DesktopNavLinks({
    required this.settings,
    required this.onSectionSelected,
  });

  final SiteSettings settings;
  final void Function(String section) onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final links = <Widget>[
      if (settings.showAbout)
        _NavLink(
          label: settings.navAboutLabel,
          onTap: () => onSectionSelected('about'),
        ),
      if (settings.showProjects)
        _NavLink(
          label: settings.navProjectsLabel,
          onTap: () => onSectionSelected('projects'),
        ),
      if (settings.showServices)
        _NavLink(
          label: settings.navServicesLabel,
          onTap: () => onSectionSelected('services'),
        ),
      if (settings.showContact)
        _NavbarCtaButton(
          label: settings.navCtaLabel,
          onPressed: () => onSectionSelected('contact'),
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < links.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          links[i],
        ],
      ],
    );
  }
}

class _NavbarLanguagePill extends StatelessWidget {
  const _NavbarLanguagePill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: color.onSurface.withValues(alpha: .035),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.onSurface.withValues(alpha: .08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 17),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.dark, required this.ref});

  final bool dark;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassIconAction(
      tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
      size: 40,
      onPressed: () {
        ref.read(themeModeProvider.notifier).state =
            dark ? ThemeMode.light : ThemeMode.dark;
      },
      icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
    );
  }
}

class _NavbarCtaButton extends StatelessWidget {
  const _NavbarCtaButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: AppColors.gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: .24),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TextButton(
        onPressed: widget.onTap,
        style: TextButton.styleFrom(
          foregroundColor: _hovered
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SheetLink extends StatelessWidget {
  const _SheetLink(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(label),
      onTap: onTap,
    );
  }
}
