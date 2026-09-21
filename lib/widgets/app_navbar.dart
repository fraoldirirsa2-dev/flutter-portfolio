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

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: PortfolioContentFrame(
        child: LiquidGlassFoundation(
          height: 64,
          borderRadius: 999,
          blur: 24,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [
                    Colors.white.withValues(alpha: .12),
                    Colors.white.withValues(alpha: .03),
                  ]
                : [
                    Colors.white.withValues(alpha: .72),
                    Colors.white.withValues(alpha: .30),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Brand(
                    prefix: settings.brandPrefix,
                    name: settings.name,
                    onTap: () => onSectionSelected('hero'),
                  ),
                ),
                if (!compact)
                  Center(
                    child: _DesktopNavLinks(
                      settings: settings,
                      onSectionSelected: onSectionSelected,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LiquidGlassIconAction(
                        tooltip: dark
                            ? 'Switch to light mode'
                            : 'Switch to dark mode',
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).state = dark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                        },
                        icon: dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                      ),
                      if (compact) ...[
                        const SizedBox(width: 8),
                        LiquidGlassIconAction(
                          tooltip: 'Open navigation',
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
              ],
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
      barrierColor: Colors.black54,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: LiquidGlassFoundation(
            borderRadius: 28,
            padding: const EdgeInsets.all(16),
            blur: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const LiquidGlassFoundation(
              width: 28,
              height: 28,
              borderRadius: 12,
              padding: EdgeInsets.zero,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              child: Icon(
                Icons.flutter_dash_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 9),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (prefix.trim().isNotEmpty) ...[
                    Text(
                      prefix.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
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
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: _NavbarCtaButton(
            label: settings.navCtaLabel,
            onPressed: () => onSectionSelected('contact'),
          ),
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < links.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          links[i],
        ],
      ],
    );
  }
}

class _NavbarCtaButton extends StatelessWidget {
  const _NavbarCtaButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Keep the original glass CTA in dark mode. In light mode, use a
    // deliberate high-contrast surface so the label can never disappear
    // against the translucent white navbar.
    if (dark) {
      return LiquidGlassActionButton(
        onPressed: onPressed,
        borderRadius: 15,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Text(label),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .24),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: TextButton(
          onPressed: widget.onTap,
          style: TextButton.styleFrom(
            foregroundColor: _hovered
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          child: Text(widget.label),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}
