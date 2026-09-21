import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/project.dart';
import '../../models/service_model.dart';
import '../../models/site_settings.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/content_icon.dart';
import '../../widgets/footer.dart';
import '../../widgets/liquid_glass_foundation.dart';
import '../../widgets/motion_foundation.dart';
import '../../widgets/portfolio_media.dart';
import '../../widgets/project_card.dart';
import '../../widgets/responsive.dart';
import '../../widgets/section_title.dart';
import '../../widgets/service_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _heroKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _servicesKey = GlobalKey();
  final _contactKey = GlobalKey();
  final _scrollViewKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final _contactFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _budgetController = TextEditingController();
  final _messageController = TextEditingController();

  String _category = 'All';
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _budgetController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final targetContext = key.currentContext;
    final viewportContext = _scrollViewKey.currentContext;

    if (targetContext == null || viewportContext == null) {
      return;
    }

    if (!_scrollController.hasClients) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeInOutCubicEmphasized,
        alignment: 0.08,
      );
      return;
    }

    final targetRenderObject = targetContext.findRenderObject();
    final viewportRenderObject = viewportContext.findRenderObject();

    if (targetRenderObject is! RenderBox ||
        viewportRenderObject is! RenderBox) {
      return;
    }

    final targetGlobal = targetRenderObject.localToGlobal(Offset.zero);
    final viewportGlobal = viewportRenderObject.localToGlobal(Offset.zero);
    final headerHeight = MediaQuery.paddingOf(context).top + 84.0;
    final desiredOffset =
        _scrollController.offset +
        targetGlobal.dy -
        viewportGlobal.dy -
        headerHeight -
        14.0;

    final maxOffset = _scrollController.position.maxScrollExtent;
    final clampedOffset = desiredOffset.clamp(0.0, maxOffset).toDouble();

    await _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void _selectSection(String section) {
    switch (section) {
      case 'hero':
        _scrollTo(_heroKey);
        break;
      case 'about':
        _scrollTo(_aboutKey);
        break;
      case 'projects':
        _scrollTo(_projectsKey);
        break;
      case 'services':
        _scrollTo(_servicesKey);
        break;
      case 'contact':
        _scrollTo(_contactKey);
        break;
    }
  }

  Future<void> _open(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _submitContact() async {
    if (!_contactFormKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _submitted = false;
    });

    try {
      await ref
          .read(firebaseServiceProvider)
          .createContactMessage(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            budget: _budgetController.text.trim(),
            message: _messageController.text.trim(),
          );

      _nameController.clear();
      _emailController.clear();
      _budgetController.clear();
      _messageController.clear();

      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send your message: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(siteSettingsProvider);
    final projectsAsync = ref.watch(publishedProjectsProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final settings = settingsAsync.value ?? SiteSettings.defaults;
    final settingsUnavailable = settingsAsync.hasError;
    final categories = <String>[
      'All',
      ...settings.projectFilterCategories.where((item) => item != 'All'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          if (settingsUnavailable)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 24,
              right: 24,
              child: IgnorePointer(
                child: Center(
                  child: Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(
                        'Live portfolio settings are temporarily unavailable. Showing local defaults.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SelectionArea(
            child: CustomScrollView(
              key: _scrollViewKey,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 84,
                  titleSpacing: 0,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: Stack(
                    children: [
                      AppNavbar(
                        onSectionSelected: _selectSection,
                        onContactSelected: () => _scrollTo(_contactKey),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 1,
                        child: PortfolioContentFrame(
                          child: _ScrollProgress(controller: _scrollController),
                        ),
                      ),
                    ],
                  ),
                ),
                if (settings.showHero)
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _heroKey,
                      child: _HeroSection(
                        settings: settings,
                        onContact: () => _scrollTo(_contactKey),
                        onProjects: () => _scrollTo(_projectsKey),
                      ),
                    ),
                  ),
                if (settings.showTechStack)
                  SliverToBoxAdapter(
                    child: ScrollReveal(
                      controller: _scrollController,
                      delay: const Duration(milliseconds: 90),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          Responsive.horizontalPadding(context),
                          0,
                          Responsive.horizontalPadding(context),
                          20,
                        ),
                        child: HorizontalGlassRail(
                          showHint: true,
                          showArrow: true,
                          autoScroll: settings.techStackAutoScroll,
                          autoScrollDuration: Duration(
                            seconds: settings.techStackScrollSeconds.clamp(
                              8,
                              60,
                            ),
                          ),
                          pauseOnHover: true,
                          pauseOnInteraction: true,
                          children: [
                            for (final technology in settings.coreStack)
                              _TechPill(
                                icon: ContentIcon.forTechnology(technology),
                                label: technology,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (settings.showAbout)
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _aboutKey,
                      child: ScrollReveal(
                        controller: _scrollController,
                        delay: const Duration(milliseconds: 120),
                        child: _AboutSection(settings: settings),
                      ),
                    ),
                  ),
                if (settings.showProjects)
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _projectsKey,
                      child: ScrollReveal(
                        controller: _scrollController,
                        delay: const Duration(milliseconds: 150),
                        child: _ProjectsSection(
                          settings: settings,
                          projectsAsync: projectsAsync,
                          category: categories.contains(_category)
                              ? _category
                              : 'All',
                          categories: categories,
                          onCategoryChanged: (value) {
                            setState(() => _category = value);
                          },
                        ),
                      ),
                    ),
                  ),
                if (settings.showServices)
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _servicesKey,
                      child: ScrollReveal(
                        controller: _scrollController,
                        delay: const Duration(milliseconds: 180),
                        child: _ServicesSection(
                          settings: settings,
                          servicesAsync: servicesAsync,
                        ),
                      ),
                    ),
                  ),
                if (settings.showContact)
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _contactKey,
                      child: ScrollReveal(
                        controller: _scrollController,
                        delay: const Duration(milliseconds: 210),
                        child: _ContactSection(
                          settings: settings,
                          formKey: _contactFormKey,
                          nameController: _nameController,
                          emailController: _emailController,
                          budgetController: _budgetController,
                          messageController: _messageController,
                          submitting: _submitting,
                          submitted: _submitted,
                          onSubmit: _submitContact,
                          onOpen: _open,
                        ),
                      ),
                    ),
                  ),
                if (settings.showFooter)
                  SliverToBoxAdapter(
                    child: PortfolioFooter(settings: settings),
                  ),
              ],
            ),
          ),
          Positioned(
            right: Responsive.horizontalPadding(context),
            bottom: 24,
            child: _ScrollTopButton(controller: _scrollController),
          ),
        ],
      ),
    );
  }
}

class _ScrollTopButton extends StatelessWidget {
  const _ScrollTopButton({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final visible = controller.hasClients && controller.offset > 520;
        return AnimatedScale(
          scale: visible ? 1 : .7,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !visible,
              child: LiquidGlassIconAction(
                tooltip: 'Back to top',
                icon: Icons.arrow_upward_rounded,
                onPressed: () {
                  controller.animateTo(
                    0,
                    duration: const Duration(milliseconds: 720),
                    curve: Curves.easeInOutCubicEmphasized,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScrollProgress extends StatelessWidget {
  const _ScrollProgress({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final position = controller.hasClients ? controller.position : null;
        final max = position?.maxScrollExtent ?? 0;
        final progress = max <= 0
            ? 0.0
            : (controller.offset / max).clamp(0.0, 1.0);
        final colors = Theme.of(context).colorScheme;

        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 3,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: colors.onSurface.withValues(alpha: .08),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, AppColors.secondary],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.settings,
    required this.onContact,
    required this.onProjects,
  });

  final SiteSettings settings;
  final VoidCallback onContact;
  final VoidCallback onProjects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mobile = Responsive.isMobile(context);

    return Stack(
      children: [
        const Positioned.fill(child: _HeroBackdrop()),
        Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.horizontalPadding(context),
            mobile ? 34 : 60,
            Responsive.horizontalPadding(context),
            mobile ? 68 : 96,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 900;
                      final intro = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AvailabilityBadge(
                            visible: settings.availableForHire,
                            label: settings.heroAvailabilityLabel,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            settings.name.isEmpty
                                ? 'Flutter Developer'
                                : settings.name,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.role,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _GradientHeadline(
                            text: settings.heroTitle,
                            mobile: mobile,
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 690),
                            child: Text(
                              settings.heroSubtitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.65,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: onContact,
                                icon: const Icon(Icons.arrow_outward_rounded),
                                label: Text(settings.heroPrimaryCta),
                              ),
                              OutlinedButton.icon(
                                onPressed: onProjects,
                                icon: const Icon(Icons.grid_view_rounded),
                                label: Text(settings.heroSecondaryCta),
                              ),
                              if (settings.cvUrl.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => _openUrl(settings.cvUrl),
                                  icon: const Icon(Icons.download_rounded),
                                  label: Text(settings.heroCvLabel),
                                ),
                            ],
                          ),
                          const SizedBox(height: 34),
                          _TrustLine(settings: settings),
                        ],
                      );

                      final visual = FloatMotion(
                        distance: 10,
                        duration: const Duration(milliseconds: 3600),
                        child: _HeroVisual(settings: settings),
                      );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            intro,
                            const SizedBox(height: 42),
                            Center(child: visual),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: intro),
                          const SizedBox(width: 52),
                          Expanded(flex: 4, child: Center(child: visual)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 54),
                  _StatsBento(settings: settings),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> _openUrl(String value) async {
    final uri = resolvePortfolioUrl(value);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.visible, required this.label});

  final bool visible;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return PulseMotion(
      minScale: .99,
      maxScale: 1.025,
      duration: const Duration(milliseconds: 2000),
      child: LiquidGlassFoundation(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: 999,
        blur: 18,
        borderColor: AppColors.secondary.withValues(alpha: .45),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientHeadline extends StatefulWidget {
  const _GradientHeadline({required this.text, required this.mobile});

  final String text;
  final bool mobile;

  @override
  State<_GradientHeadline> createState() => _GradientHeadlineState();
}

class _GradientHeadlineState extends State<_GradientHeadline>
    with SingleTickerProviderStateMixin {
  bool _started = false;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || MediaQuery.disableAnimationsOf(context)) return;

    _started = true;
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        (widget.mobile
                ? theme.textTheme.displayMedium
                : theme.textTheme.displayLarge)
            ?.copyWith(fontWeight: FontWeight.w800);

    if (MediaQuery.disableAnimationsOf(context)) {
      return _buildText(theme, style, 0.5);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _buildText(theme, style, _controller.value);
      },
    );
  }

  Widget _buildText(ThemeData theme, TextStyle? style, double value) {
    final dark = theme.brightness == Brightness.dark;
    final sweep = -1.3 + (value * 2.6);

    return Semantics(
      header: true,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(sweep - 1.0, -1),
            end: Alignment(sweep + 1.0, 1),
            colors: dark
                ? const [
                    Colors.white,
                    Color(0xFFD8D3FF),
                    AppColors.primary,
                    Colors.white,
                  ]
                : const [
                    AppColors.ink,
                    AppColors.primaryDeep,
                    AppColors.primary,
                    AppColors.ink,
                  ],
            stops: const [0.0, 0.40, 0.70, 1.0],
          ).createShader(bounds);
        },
        child: Text(widget.text, style: style),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.settings});

  final SiteSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 430),
      child: AspectRatio(
        aspectRatio: .88,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: 18,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary.withValues(alpha: .16),
                      colors.secondary.withValues(alpha: .12),
                    ],
                  ),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: .22),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 0,
              top: 0,
              bottom: 18,
              child: LiquidGlassFoundation(
                borderRadius: 34,
                padding: const EdgeInsets.all(14),
                blur: 24,
                color: dark
                    ? Colors.black.withValues(alpha: .18)
                    : Colors.white.withValues(alpha: .30),
                borderColor: colors.outlineVariant.withValues(alpha: .55),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? .16 : .08),
                    blurRadius: 50,
                    offset: const Offset(0, 24),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: dark ? .10 : .36),
                    Colors.white.withValues(alpha: .03),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(27),
                        child: settings.profilePhotoUrl.isEmpty
                            ? Container(
                                color: colors.surfaceContainerHighest,
                                child: Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 118,
                                    color: colors.primary.withValues(alpha: .8),
                                  ),
                                ),
                              )
                            : PortfolioImage(
                                source: settings.profilePhotoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error) {
                                  return Container(
                                    color: colors.surfaceContainerHighest,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 118,
                                      color: colors.primary.withValues(
                                        alpha: .8,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CodeStrip(settings: settings),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 28,
              left: 28,
              child: FloatMotion(
                distance: 6,
                duration: const Duration(milliseconds: 2800),
                rotate: .012,
                child: _FloatingPill(
                  icon: ContentIcon.fromName(settings.heroPillOneIconName),
                  label: settings.heroPillOneLabel,
                ),
              ),
            ),
            Positioned(
              right: -8,
              bottom: 56,
              child: FloatMotion(
                distance: 8,
                duration: const Duration(milliseconds: 3300),
                delay: const Duration(milliseconds: 240),
                rotate: -.01,
                child: _FloatingPill(
                  icon: ContentIcon.fromName(settings.heroPillTwoIconName),
                  label: settings.heroPillTwoLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeStrip extends StatelessWidget {
  const _CodeStrip({required this.settings});

  final SiteSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return LiquidGlassFoundation(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      borderRadius: 17,
      blur: 16,
      child: Row(
        children: [
          const Icon(Icons.terminal_rounded, size: 16),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              settings.codeStripText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            settings.yearsExperience == 1
                ? '1 year'
                : '${settings.yearsExperience} years',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingPill extends StatelessWidget {
  const _FloatingPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LiquidGlassPill(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustLine extends StatelessWidget {
  const _TrustLine({required this.settings});

  final SiteSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = settings.heroTrustItems.isEmpty
        ? <String>[settings.location]
        : settings.heroTrustItems;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Icon(Icons.circle, size: 4, color: theme.colorScheme.outline),
          Text(
            items[i],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatsBento extends StatelessWidget {
  const _StatsBento({required this.settings});

  final SiteSettings settings;

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

    final cards = [
      _MiniStat(
        value: '${settings.projectsShipped}',
        label: settings.projectsShippedLabel,
        icon: Icons.rocket_launch_rounded,
      ),
      _MiniStat(
        value: '${settings.yearsExperience}',
        label: settings.yearsExperienceLabel,
        icon: Icons.trending_up_rounded,
      ),
      _MiniStat(
        value: settings.availableForHire
            ? settings.availabilityOpenValue
            : settings.availabilityFocusedValue,
        label: settings.availableForHire
            ? settings.availabilityOpenLabel
            : settings.availabilityFocusedLabel,
        icon: settings.availableForHire
            ? Icons.mark_email_read_rounded
            : Icons.self_improvement_rounded,
      ),
    ];

    final columns = mobile ? 1 : 3;
    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: mobile ? 3.25 : 2.0,
      ),
      itemBuilder: (context, index) =>
          NeoGlassSurface(borderRadius: 24, depth: 12, child: cards[index]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: -120,
            child: _SoftGlow(size: 360, color: theme.colorScheme.primary),
          ),
          Positioned(
            bottom: -70,
            left: -110,
            child: _SoftGlow(size: 300, color: theme.colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: .15), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.settings});

  final SiteSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: 88,
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 820;
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    eyebrow: settings.aboutEyebrow,
                    title: settings.aboutTitle,
                    subtitle: settings.aboutSubtitle,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    settings.about,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.75,
                    ),
                  ),
                ],
              );

              final stack = Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Text(
                            settings.coreStackTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (settings.showSkills) ...[
                        Text(
                          settings.skillsTitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final skill in settings.skills)
                              Chip(
                                label: Text(skill),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                      if (settings.showCoreStack) ...[
                        const SizedBox(height: 20),
                        Text(
                          settings.coreStackTitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final technology in settings.coreStack)
                              Chip(
                                avatar: Icon(
                                  ContentIcon.forTechnology(technology),
                                  size: 17,
                                ),
                                label: Text(technology),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                      if (settings.showWorkingStyle) ...[
                        const SizedBox(height: 20),
                        Text(
                          settings.workingStyleTitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final item in settings.workingStyle)
                          _WorkingStyleRow(
                            icon: ContentIcon.fromName(item.iconName),
                            text: item.text,
                          ),
                      ],
                    ],
                  ),
                ),
              );

              if (mobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 24), stack],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: copy),
                  const SizedBox(width: 36),
                  Expanded(flex: 4, child: stack),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WorkingStyleRow extends StatelessWidget {
  const _WorkingStyleRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({
    required this.settings,
    required this.projectsAsync,
    required this.category,
    required this.categories,
    required this.onCategoryChanged,
  });

  final SiteSettings settings;
  final AsyncValue<List<Project>> projectsAsync;
  final String category;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final projects = projectsAsync.value ?? const <Project>[];
    final filtered = category == 'All'
        ? projects
        : projects.where((project) => project.category == category).toList();
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.horizontalPadding(context),
        92,
        Responsive.horizontalPadding(context),
        92,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                eyebrow: settings.projectsEyebrow,
                title: settings.projectsTitle,
                subtitle: settings.projectsSubtitle,
              ),
              const SizedBox(height: 28),
              if (settings.showFeaturedProjects && projects.isNotEmpty) ...[
                Text(
                  settings.featuredProjectsLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                HorizontalGlassRail(
                  padding: const EdgeInsets.only(top: 4, bottom: 6),
                  children: [
                    for (final project in projects.take(5))
                      SizedBox(
                        width: 360,
                        height: 340,
                        child: ProjectCard(project: project),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < categories.length; i++) ...[
                      ChoiceChip(
                        selected: category == categories[i],
                        label: Text(categories[i]),
                        onSelected: (_) => onCategoryChanged(categories[i]),
                      ),
                      if (i != categories.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (projectsAsync.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (projectsAsync.hasError)
                const _InlineError(
                  message:
                      'Projects could not be loaded. Check Firebase configuration and Firestore rules.',
                )
              else if (filtered.isEmpty)
                const _EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'No projects in this category yet',
                  message:
                      'Publish a project from the admin dashboard and it will appear here automatically.',
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1160
                        ? 3
                        : constraints.maxWidth >= 720
                        ? 2
                        : 1;
                    return GridView.builder(
                      itemCount: filtered.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: columns == 1 ? 1.15 : 1.05,
                      ),
                      itemBuilder: (context, index) {
                        return MotionReveal(
                          delay: Duration(milliseconds: index * 70),
                          child: ProjectCard(project: filtered[index]),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.lock_open_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    settings.publishedProjectsNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.settings, required this.servicesAsync});

  final SiteSettings settings;
  final AsyncValue<List<ServiceModel>> servicesAsync;

  @override
  Widget build(BuildContext context) {
    final services = servicesAsync.value ?? const <ServiceModel>[];

    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.horizontalPadding(context),
        88,
        Responsive.horizontalPadding(context),
        94,
      ),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                eyebrow: settings.servicesEyebrow,
                title: settings.servicesTitle,
                subtitle: settings.servicesSubtitle,
              ),
              const SizedBox(height: 30),
              if (servicesAsync.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (servicesAsync.hasError)
                const _InlineError(message: 'Services could not be loaded.')
              else if (services.isEmpty)
                const _EmptyState(
                  icon: Icons.design_services_rounded,
                  title: 'No services yet',
                  message:
                      'Create services from the protected admin dashboard.',
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1180
                        ? 4
                        : constraints.maxWidth >= 760
                        ? 2
                        : 1;
                    return GridView.builder(
                      itemCount: services.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: columns == 1 ? 1.35 : 1.12,
                      ),
                      itemBuilder: (context, index) {
                        return MotionReveal(
                          delay: Duration(milliseconds: index * 70),
                          child: ServiceCard(service: services[index]),
                        );
                      },
                    );
                  },
                ),
              if (settings.showProcess) ...[
                const SizedBox(height: 56),
                Text(
                  settings.processTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                _ProcessRail(items: settings.processItems),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessRail extends StatelessWidget {
  const _ProcessRail({required this.items});

  final List<ProcessItem> items;
  static const purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HorizontalGlassRail(
      showHint: true,
      showArrow: true,
      gap: 12,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 9),
      children: [
        for (final item in items)
          NeoGlassSurface(
            padding: const EdgeInsets.fromLTRB(7, 7, 16, 7),
            borderRadius: 999,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: purple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    ContentIcon.fromName(item.iconName),
                    size: 17,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  item.number,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.settings,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.budgetController,
    required this.messageController,
    required this.submitting,
    required this.submitted,
    required this.onSubmit,
    required this.onOpen,
  });

  final SiteSettings settings;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController budgetController;
  final TextEditingController messageController;
  final bool submitting;
  final bool submitted;
  final VoidCallback onSubmit;
  final Future<void> Function(String value) onOpen;

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    return valid ? null : 'Enter a valid email';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = Responsive.isMobile(context);

    final details = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: .14),
            theme.colorScheme.secondary.withValues(alpha: .10),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: .20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: .78),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            settings.contactCardTitle,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            settings.contactCardBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 25),
          _ContactLine(
            icon: Icons.email_outlined,
            label: settings.email,
            onTap: settings.email.isEmpty
                ? null
                : () => onOpen('mailto:${settings.email}'),
          ),
          _ContactLine(
            icon: Icons.phone_outlined,
            label: settings.phone,
            onTap: settings.phone.isEmpty
                ? null
                : () => onOpen('tel:${settings.phone.replaceAll(' ', '')}'),
          ),
          _ContactLine(
            icon: Icons.location_on_outlined,
            label: settings.location,
            onTap: null,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 4,
            children: [
              for (final entry in settings.socials.entries)
                if (entry.value.isNotEmpty)
                  IconButton(
                    tooltip: entry.key,
                    onPressed: () => onOpen(entry.value),
                    icon: Icon(_socialIcon(entry.key)),
                  ),
            ],
          ),
        ],
      ),
    );

    final form = Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.contactFormTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final inline = constraints.maxWidth >= 560;
              final nameField = TextFormField(
                controller: nameController,
                validator: _required,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: settings.contactNameLabel,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              );
              final emailField = TextFormField(
                controller: emailController,
                validator: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: settings.contactEmailLabel,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                ),
              );

              return Column(
                children: [
                  if (inline)
                    Row(
                      children: [
                        Expanded(child: nameField),
                        const SizedBox(width: 12),
                        Expanded(child: emailField),
                      ],
                    )
                  else ...[
                    nameField,
                    const SizedBox(height: 12),
                    emailField,
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: budgetController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: settings.contactBudgetLabel,
                      hintText: settings.contactBudgetHint,
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: messageController,
                    validator: _required,
                    maxLines: 7,
                    decoration: InputDecoration(
                      labelText: settings.contactMessageLabel,
                      alignLabelWithHint: true,
                      hintText: settings.contactMessageHint,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 108),
                        child: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: submitted
                ? Container(
                    key: const ValueKey('success'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded),
                        const SizedBox(width: 10),
                        Expanded(child: Text(settings.contactSuccessMessage)),
                      ],
                    ),
                  )
                : FilledButton.icon(
                    key: const ValueKey('submit'),
                    onPressed: submitting ? null : onSubmit,
                    icon: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      submitting
                          ? settings.contactSendingLabel
                          : settings.contactSubmitLabel,
                    ),
                  ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.horizontalPadding(context),
        90,
        Responsive.horizontalPadding(context),
        94,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                eyebrow: settings.contactEyebrow,
                title: settings.contactTitle,
                subtitle: settings.contactSubtitle,
              ),
              const SizedBox(height: 34),
              if (mobile)
                Column(children: [details, const SizedBox(height: 20), form])
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: details),
                    const SizedBox(width: 28),
                    Expanded(flex: 5, child: form),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _socialIcon(String key) {
    switch (key) {
      case 'github':
        return Icons.code_rounded;
      case 'linkedin':
        return Icons.business_center_rounded;
      case 'twitter':
        return Icons.alternate_email_rounded;
      case 'stackoverflow':
        return Icons.question_answer_outlined;
      case 'medium':
        return Icons.article_outlined;
      default:
        return Icons.link_rounded;
    }
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _TechPill extends StatelessWidget {
  const _TechPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return NeoGlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      borderRadius: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
