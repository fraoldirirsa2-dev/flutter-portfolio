import 'dart:ui' as ui;

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

    if (!_scrollController.hasClients ||
        !_scrollController.position.hasContentDimensions) {
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

    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    final maxOffset = position.maxScrollExtent;
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
          const Positioned.fill(child: _GlobalPageBackdrop()),
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
        final visible =
            controller.hasClients &&
            controller.position.hasContentDimensions &&
            controller.offset > 520;
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
        final hasDimensions =
            controller.hasClients && controller.position.hasContentDimensions;
        final position = hasDimensions ? controller.position : null;
        final max = position?.maxScrollExtent ?? 0;
        final offset = position?.pixels ?? 0;
        final progress = max <= 0 ? 0.0 : (offset / max).clamp(0.0, 1.0);
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
    final mobile = Responsive.isMobile(context);
    final tags =
        (settings.skills.isNotEmpty ? settings.skills : settings.coreStack)
            .take(mobile ? 4 : 6)
            .toList();

    return Stack(
      children: [
        const Positioned.fill(child: _HeroBackdrop()),
        PortfolioContentFrame(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              mobile ? 46 : 64,
              0,
              mobile ? 68 : 86,
            ),
            child: Column(
              children: [
                if (settings.availableForHire)
                  _AvailabilityBadge(
                    visible: true,
                    label: settings.heroAvailabilityLabel,
                  ),
                SizedBox(height: mobile ? 22 : 28),
                Builder(
                  builder: (context) {
                    final wide = MediaQuery.sizeOf(context).width >= 920;
                    final copy = _HeroCopy(
                      settings: settings,
                      tags: tags,
                      mobile: mobile,
                      onContact: onContact,
                      onProjects: onProjects,
                    );

                    if (!wide) {
                      return Column(
                        children: [
                          copy,
                          const SizedBox(height: 34),
                          _HeroVisual(settings: settings),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 11, child: copy),
                        const SizedBox(width: 46),
                        Expanded(
                          flex: 9,
                          child: _HeroVisual(settings: settings),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 42),
                _StatsBento(settings: settings),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.settings,
    required this.tags,
    required this.mobile,
    required this.onContact,
    required this.onProjects,
  });

  final SiteSettings settings;
  final List<String> tags;
  final bool mobile;
  final VoidCallback onContact;
  final VoidCallback onProjects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: mobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          settings.name.isEmpty ? 'Flutter Developer' : settings.name,
          textAlign: mobile ? TextAlign.center : TextAlign.left,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            settings.role,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _GradientHeadline(text: settings.heroTitle, mobile: mobile),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: mobile ? 680 : 650),
          child: Text(
            settings.heroSubtitle,
            textAlign: mobile ? TextAlign.center : TextAlign.left,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.78,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _GradientHeroButton(
              label: settings.heroSecondaryCta.isEmpty
                  ? 'View my work'
                  : settings.heroSecondaryCta,
              icon: Icons.arrow_forward_rounded,
              onPressed: onProjects,
            ),
            _OutlineHeroButton(
              label: settings.cvUrl.isNotEmpty
                  ? settings.heroCvLabel
                  : (settings.heroPrimaryCta.isEmpty
                        ? 'Let’s talk'
                        : settings.heroPrimaryCta),
              icon: settings.cvUrl.isNotEmpty
                  ? Icons.download_rounded
                  : Icons.chat_bubble_outline_rounded,
              onPressed: () async {
                if (settings.cvUrl.isNotEmpty) {
                  final uri = resolvePortfolioUrl(settings.cvUrl);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                } else {
                  onContact();
                }
              },
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 26),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
            children: [
              for (final tag in tags)
                _HeroTag(label: tag, icon: ContentIcon.forTechnology(tag)),
            ],
          ),
        ],
        if (settings.heroTrustItems.isNotEmpty) ...[
          const SizedBox(height: 22),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
            children: [
              for (final item in settings.heroTrustItems)
                _TrustItem(text: item),
            ],
          ),
        ],
      ],
    );
  }
}

class _GradientHeroButton extends StatefulWidget {
  const _GradientHeroButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_GradientHeroButton> createState() => _GradientHeroButtonState();
}

class _GradientHeroButtonState extends State<_GradientHeroButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1,
        duration: const Duration(milliseconds: 180),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withValues(alpha: _hovered ? .34 : .20),
                blurRadius: _hovered ? 28 : 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(widget.icon, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineHeroButton extends StatefulWidget {
  const _OutlineHeroButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_OutlineHeroButton> createState() => _OutlineHeroButtonState();
}

class _OutlineHeroButtonState extends State<_OutlineHeroButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _hovered
              ? colors.onSurface.withValues(alpha: .06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: _hovered
                ? AppColors.cyan.withValues(alpha: .55)
                : AppColors.borderStrong,
          ),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 18, color: colors.onSurface),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroVisual extends StatefulWidget {
  const _HeroVisual({required this.settings});

  final SiteSettings settings;

  @override
  State<_HeroVisual> createState() => _HeroVisualState();
}

class _HeroVisualState extends State<_HeroVisual> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final settings = widget.settings;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 920;
    final height = compact ? 360.0 : 460.0;
    final stack = settings.coreStack.take(3).toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1,
        duration: const Duration(milliseconds: 220),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 22,
              left: 18,
              right: 6,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.violet.withValues(alpha: .28),
                      AppColors.cyan.withValues(alpha: .12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: height,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet.withValues(
                        alpha: _hovered ? .20 : .12,
                      ),
                      blurRadius: 60,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: LiquidGlassFoundation(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(12),
                  blur: 24,
                  color: dark
                      ? Colors.black.withValues(alpha: .28)
                      : Colors.white.withValues(alpha: .70),
                  borderColor: Colors.white.withValues(alpha: .10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: dark ? .09 : .38),
                      Colors.white.withValues(alpha: dark ? .025 : .10),
                    ],
                  ),
                  child: Column(
                    children: [
                      _WorkspaceHeader(settings: settings),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: settings.profilePhotoUrl.isEmpty
                                    ? DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.violet.withValues(
                                                alpha: .20,
                                              ),
                                              AppColors.cyan.withValues(
                                                alpha: .10,
                                              ),
                                              theme.colorScheme.surface,
                                            ],
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.code_rounded,
                                            size: 90,
                                            color: AppColors.cyan,
                                          ),
                                        ),
                                      )
                                    : PortfolioImage(
                                        source: settings.profilePhotoUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error) =>
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.surface,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.code_rounded,
                                                  size: 90,
                                                  color: AppColors.cyan,
                                                ),
                                              ),
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
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: .62),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 18,
                                right: 18,
                                bottom: 18,
                                child: _WorkspaceOverlay(
                                  settings: settings,
                                  stack: stack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CodeStrip(settings: settings),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 26,
              left: -14,
              child: FloatMotion(
                distance: 7,
                duration: const Duration(milliseconds: 2800),
                rotate: .012,
                child: _FloatingPill(
                  icon: ContentIcon.fromName(settings.heroPillOneIconName),
                  label: settings.heroPillOneLabel,
                ),
              ),
            ),
            Positioned(
              right: -18,
              bottom: 78,
              child: FloatMotion(
                distance: 8,
                duration: const Duration(milliseconds: 3200),
                delay: const Duration(milliseconds: 180),
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

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.settings});
  final SiteSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.flutter_dash_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settings.name.isEmpty ? 'Flutter Portfolio' : settings.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                settings.role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const _WindowDot(color: AppColors.green),
      ],
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 9,
    height: 9,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(color: color.withValues(alpha: .35), blurRadius: 10),
      ],
    ),
  );
}

class _WorkspaceOverlay extends StatelessWidget {
  const _WorkspaceOverlay({required this.settings, required this.stack});
  final SiteSettings settings;
  final List<String> stack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                settings.availableForHire
                    ? settings.heroAvailabilityLabel
                    : settings.availabilityFocusedValue,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            settings.heroTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          if (stack.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final item in stack) _MiniTechnologyChip(label: item),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniTechnologyChip extends StatelessWidget {
  const _MiniTechnologyChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ContentIcon.forTechnology(label), size: 13, color: AppColors.cyan),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.visible, required this.label});

  final bool visible;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: .08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
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

class _GradientHeadline extends StatelessWidget {
  const _GradientHeadline({required this.text, required this.mobile});
  final String text;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        (mobile ? theme.textTheme.displayMedium : theme.textTheme.displayLarge)
            ?.copyWith(
              fontWeight: FontWeight.w900,
              height: .98,
              letterSpacing: -2.0,
              color: theme.colorScheme.onSurface,
            );
    final words = text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
    if (words.length <= 2) {
      return Text(text, textAlign: TextAlign.center, style: style);
    }
    final normalCount = words.length - 2;
    return RichText(
      textAlign: mobile ? TextAlign.center : TextAlign.left,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: '${words.take(normalCount).join(' ')} '),
          TextSpan(
            text: words.skip(normalCount).join(' '),
            style: style?.copyWith(
              foreground: Paint()
                ..shader = AppColors.gradient.createShader(
                  const Rect.fromLTWH(0, 0, 520, 120),
                ),
            ),
          ),
        ],
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

// ignore: unused_element
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
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 700 ? 1 : 2;
    final cards = [
      _MiniStat(
        value: '${settings.projectsShipped}',
        label: settings.projectsShippedLabel,
      ),
      _MiniStat(
        value: '${settings.yearsExperience}',
        label: settings.yearsExperienceLabel,
      ),
      _MiniStat(
        value: settings.availableForHire
            ? settings.availabilityOpenValue
            : settings.availabilityFocusedValue,
        label: settings.availableForHire
            ? settings.availabilityOpenLabel
            : settings.availabilityFocusedLabel,
      ),
      _MiniStat(
        value: settings.qualityStatValue,
        label: settings.qualityStatLabel,
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: width < 700 ? 4.0 : 1.7,
      ),
      itemBuilder: (context, index) => _StatCard(child: cards[index]),
    );
  }
}

class _StatCard extends StatefulWidget {
  const _StatCard({required this.child});
  final Widget child;
  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: .88),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hovered
                ? AppColors.violet.withValues(alpha: .38)
                : AppColors.border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: .12),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.gradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GlobalPageBackdrop extends StatelessWidget {
  const _GlobalPageBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -160,
            child: _GlowOrb(
              size: 520,
              colors: [
                AppColors.violet.withValues(alpha: .16),
                AppColors.cyan.withValues(alpha: .035),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            bottom: -240,
            left: -190,
            child: _GlowOrb(
              size: 560,
              colors: [
                AppColors.cyan.withValues(alpha: .10),
                AppColors.violet.withValues(alpha: .035),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 34, sigmaY: 34),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: .65,
            colors: colors,
            stops: const [0, .55, 1],
          ),
        ),
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
    final mobile = Responsive.isMobile(context);
    final currently = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currently',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          _CurrentlyRow(
            icon: settings.availableForHire
                ? Icons.circle_rounded
                : Icons.pause_circle_outline_rounded,
            label: settings.availableForHire ? 'Status' : 'Status',
            value: settings.availableForHire
                ? settings.availabilityOpenValue
                : settings.availabilityFocusedValue,
            accent: settings.availableForHire
                ? AppColors.green
                : AppColors.violet,
          ),
          const SizedBox(height: 12),
          _CurrentlyRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: settings.location,
          ),
          const SizedBox(height: 12),
          _CurrentlyRow(
            icon: Icons.handshake_outlined,
            label: 'Contract',
            value: settings.contractPreference,
          ),
        ],
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          eyebrow: settings.aboutEyebrow,
          title: settings.aboutTitle,
          subtitle: settings.aboutSubtitle,
        ),
        const SizedBox(height: 24),
        Text(
          settings.about,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 26),
        if (settings.showSkills && settings.skills.isNotEmpty) ...[
          _SubSectionLabel(label: settings.skillsTitle),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in settings.skills)
                _DarkPill(label: skill, icon: Icons.check_rounded),
            ],
          ),
        ],
        if (settings.showCoreStack && settings.coreStack.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SubSectionLabel(label: settings.coreStackTitle),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final technology in settings.coreStack)
                _DarkPill(
                  label: technology,
                  icon: ContentIcon.forTechnology(technology),
                ),
            ],
          ),
        ],
        if (settings.showWorkingStyle && settings.workingStyle.isNotEmpty) ...[
          const SizedBox(height: 28),
          _SubSectionLabel(label: settings.workingStyleTitle),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < settings.workingStyle.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 18, 15),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.violet.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            ContentIcon.fromName(
                              settings.workingStyle[i].iconName,
                            ),
                            size: 17,
                            color: AppColors.violet,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(child: Text(settings.workingStyle[i].text)),
                      ],
                    ),
                  ),
                  if (i != settings.workingStyle.length - 1)
                    const Divider(height: 1, indent: 61),
                ],
              ],
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: mobile ? 72 : 92),
      child: PortfolioContentFrame(
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [content, const SizedBox(height: 24), currently],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: content),
                  const SizedBox(width: 28),
                  Expanded(flex: 4, child: currently),
                ],
              ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 92),
      child: PortfolioContentFrame(
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              HorizontalGlassRail(
                padding: const EdgeInsets.symmetric(vertical: 4),
                gap: 14,
                children: [
                  for (final project in projects.take(5))
                    SizedBox(
                      width: 360,
                      height: 405,
                      child: ProjectCard(project: project),
                    ),
                ],
              ),
              const SizedBox(height: 30),
            ],
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < categories.length; i++) ...[
                    _FilterPill(
                      label: categories[i],
                      selected: category == categories[i],
                      onTap: () => onCategoryChanged(categories[i]),
                    ),
                    if (i != categories.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 26),
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
                  final columns = constraints.maxWidth >= 1080
                      ? 3
                      : constraints.maxWidth >= 680
                      ? 2
                      : 1;
                  return GridView.builder(
                    itemCount: filtered.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: columns == 1 ? 1.05 : .93,
                    ),
                    itemBuilder: (context, index) => MotionReveal(
                      delay: Duration(milliseconds: index * 60),
                      child: ProjectCard(project: filtered[index]),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.cyan,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    settings.publishedProjectsNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
      width: double.infinity,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerLow.withValues(alpha: .55),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 90),
        child: PortfolioContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                eyebrow: settings.servicesEyebrow,
                title: settings.servicesTitle,
                subtitle: settings.servicesSubtitle,
              ),
              const SizedBox(height: 28),
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
                    final columns = constraints.maxWidth >= 1100
                        ? 3
                        : constraints.maxWidth >= 720
                        ? 2
                        : 1;
                    return GridView.builder(
                      itemCount: services.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: columns == 1 ? 1.30 : 1.08,
                      ),
                      itemBuilder: (context, index) => MotionReveal(
                        delay: Duration(milliseconds: index * 60),
                        child: ServiceCard(service: services[index]),
                      ),
                    );
                  },
                ),
              if (settings.showProcess && settings.processItems.isNotEmpty) ...[
                const SizedBox(height: 54),
                Text(
                  settings.processTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      gradient: AppColors.gradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      items[i].number,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Icon(
                    ContentIcon.fromName(items[i].iconName),
                    size: 17,
                    color: AppColors.cyan,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    items[i].label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (i != items.length - 1) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
            ],
          ],
        ],
      ),
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
    return value == null || value.trim().isEmpty
        ? 'This field is required'
        : null;
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.contactCardTitle,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            settings.contactCardBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.72,
            ),
          ),
          const SizedBox(height: 22),
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
          if (settings.socials.values.any((value) => value.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in settings.socials.entries)
                  if (entry.value.isNotEmpty)
                    _SocialPill(
                      label: entry.key,
                      icon: _socialIcon(entry.key),
                      onTap: () => onOpen(entry.value),
                    ),
              ],
            ),
          ],
        ],
      ),
    );

    final form = Container(
      padding: EdgeInsets.all(mobile ? 18 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(settings.contactFormTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final inline = constraints.maxWidth >= 560;
                final nameField = TextFormField(
                  controller: nameController,
                  validator: _required,
                  decoration: InputDecoration(
                    labelText: settings.contactNameLabel,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                );
                final emailField = TextFormField(
                  controller: emailController,
                  validator: _email,
                  keyboardType: TextInputType.emailAddress,
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
                      minLines: 6,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: settings.contactMessageLabel,
                        alignLabelWithHint: true,
                        hintText: settings.contactMessageHint,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 86),
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
              duration: const Duration(milliseconds: 200),
              child: submitted
                  ? Container(
                      key: const ValueKey('success'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: .22),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(settings.contactSuccessMessage)),
                        ],
                      ),
                    )
                  : _GradientSubmitButton(
                      key: const ValueKey('submit'),
                      label: submitting
                          ? settings.contactSendingLabel
                          : settings.contactSubmitLabel,
                      loading: submitting,
                      onPressed: submitting ? null : onSubmit,
                    ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 92),
      child: PortfolioContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              eyebrow: settings.contactEyebrow,
              title: settings.contactTitle,
              subtitle: settings.contactSubtitle,
            ),
            const SizedBox(height: 28),
            if (mobile)
              Column(children: [details, const SizedBox(height: 16), form])
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: details),
                  const SizedBox(width: 18),
                  Expanded(flex: 6, child: form),
                ],
              ),
          ],
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

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _DarkPill(label: label, icon: icon);
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.cyan),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.labelMedium;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.gradient : null,
            color: selected ? null : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.borderStrong,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: .18),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: text?.copyWith(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.cyan,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _CurrentlyRow extends StatelessWidget {
  const _CurrentlyRow({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (accent ?? AppColors.violet).withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: accent ?? AppColors.violet),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cyan,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 13),
      ),
    );
  }
}

class _GradientSubmitButton extends StatelessWidget {
  const _GradientSubmitButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppColors.gradient,
        color: onPressed == null ? AppColors.surfaceElevated : null,
        borderRadius: BorderRadius.circular(999),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: .18),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (loading)
                    const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      Icons.send_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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
