import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/site_settings.dart';
import '../../providers.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/content_icon.dart';
import '../../widgets/liquid_glass_foundation.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _c = {};
  final Map<String, TextEditingController> _socials = {};

  bool _initialized = false;
  bool _saving = false;
  bool _availableForHire = true;
  bool _showHero = true;
  bool _showTechStack = true;
  bool _showAbout = true;
  bool _showSkills = true;
  bool _showCoreStack = true;
  bool _showWorkingStyle = true;
  bool _showProjects = true;
  bool _showFeaturedProjects = true;
  bool _showServices = true;
  bool _showProcess = true;
  bool _showContact = true;
  bool _showFooter = true;
  bool _techStackAutoScroll = true;

  TextEditingController _controller(String key) {
    return _c.putIfAbsent(key, TextEditingController.new);
  }

  String _text(String key) => _c[key]?.text.trim() ?? '';

  @override
  void dispose() {
    for (final controller in _c.values) {
      controller.dispose();
    }
    for (final controller in _socials.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _load(SiteSettings settings) {
    if (_initialized) return;
    _initialized = true;

    final values = <String, String>{
      'name': settings.name,
      'role': settings.role,
      'brandPrefix': settings.brandPrefix,
      'heroTitle': settings.heroTitle,
      'heroSubtitle': settings.heroSubtitle,
      'heroPrimaryCta': settings.heroPrimaryCta,
      'heroSecondaryCta': settings.heroSecondaryCta,
      'heroCvLabel': settings.heroCvLabel,
      'heroAvailabilityLabel': settings.heroAvailabilityLabel,
      'heroPillOneLabel': settings.heroPillOneLabel,
      'heroPillOneIconName': settings.heroPillOneIconName,
      'heroPillTwoLabel': settings.heroPillTwoLabel,
      'heroPillTwoIconName': settings.heroPillTwoIconName,
      'heroTrustItems': settings.heroTrustItems.join('\n'),
      'codeStripText': settings.codeStripText,
      'aboutEyebrow': settings.aboutEyebrow,
      'aboutTitle': settings.aboutTitle,
      'aboutSubtitle': settings.aboutSubtitle,
      'about': settings.about,
      'skillsTitle': settings.skillsTitle,
      'skills': settings.skills.join('\n'),
      'coreStackTitle': settings.coreStackTitle,
      'coreStack': settings.coreStack.join('\n'),
      'workingStyleTitle': settings.workingStyleTitle,
      'workingStyle': settings.workingStyle
          .map((item) => '${item.iconName} | ${item.text}')
          .join('\n'),
      'projectsEyebrow': settings.projectsEyebrow,
      'projectsTitle': settings.projectsTitle,
      'projectsSubtitle': settings.projectsSubtitle,
      'featuredProjectsLabel': settings.featuredProjectsLabel,
      'publishedProjectsNote': settings.publishedProjectsNote,
      'projectFilterCategories': settings.projectFilterCategories.join('\n'),
      'servicesEyebrow': settings.servicesEyebrow,
      'servicesTitle': settings.servicesTitle,
      'servicesSubtitle': settings.servicesSubtitle,
      'processTitle': settings.processTitle,
      'processItems': settings.processItems
          .map((item) => '${item.number} | ${item.iconName} | ${item.label}')
          .join('\n'),
      'contactEyebrow': settings.contactEyebrow,
      'contactTitle': settings.contactTitle,
      'contactSubtitle': settings.contactSubtitle,
      'contactCardTitle': settings.contactCardTitle,
      'contactCardBody': settings.contactCardBody,
      'contactFormTitle': settings.contactFormTitle,
      'contactNameLabel': settings.contactNameLabel,
      'contactEmailLabel': settings.contactEmailLabel,
      'contactBudgetLabel': settings.contactBudgetLabel,
      'contactBudgetHint': settings.contactBudgetHint,
      'contactMessageLabel': settings.contactMessageLabel,
      'contactMessageHint': settings.contactMessageHint,
      'contactSubmitLabel': settings.contactSubmitLabel,
      'contactSendingLabel': settings.contactSendingLabel,
      'contactSuccessMessage': settings.contactSuccessMessage,
      'footerTagline': settings.footerTagline,
      'footerRightText': settings.footerRightText,
      'navAboutLabel': settings.navAboutLabel,
      'navProjectsLabel': settings.navProjectsLabel,
      'navServicesLabel': settings.navServicesLabel,
      'navCtaLabel': settings.navCtaLabel,
      'yearsExperience': '${settings.yearsExperience}',
      'projectsShipped': '${settings.projectsShipped}',
      'projectsShippedLabel': settings.projectsShippedLabel,
      'yearsExperienceLabel': settings.yearsExperienceLabel,
      'availabilityOpenValue': settings.availabilityOpenValue,
      'availabilityOpenLabel': settings.availabilityOpenLabel,
      'availabilityFocusedValue': settings.availabilityFocusedValue,
      'availabilityFocusedLabel': settings.availabilityFocusedLabel,
      'cvUrl': settings.cvUrl,
      'profilePhotoUrl': settings.profilePhotoUrl,
      'email': settings.email,
      'phone': settings.phone,
      'location': settings.location,
      'techStackScrollSeconds': '${settings.techStackScrollSeconds}',
      'seoTitle': settings.seoTitle,
      'seoDescription': settings.seoDescription,
      'seoKeywords': settings.seoKeywords,
    };

    for (final entry in values.entries) {
      _controller(entry.key).text = entry.value;
    }

    for (final key in SiteSettings.defaults.socials.keys) {
      final controller = TextEditingController(
        text: settings.socials[key] ?? '',
      );
      _socials[key] = controller;
    }

    _availableForHire = settings.availableForHire;
    _showHero = settings.showHero;
    _showTechStack = settings.showTechStack;
    _showAbout = settings.showAbout;
    _showSkills = settings.showSkills;
    _showCoreStack = settings.showCoreStack;
    _showWorkingStyle = settings.showWorkingStyle;
    _showProjects = settings.showProjects;
    _showFeaturedProjects = settings.showFeaturedProjects;
    _showServices = settings.showServices;
    _showProcess = settings.showProcess;
    _showContact = settings.showContact;
    _showFooter = settings.showFooter;
    _techStackAutoScroll = settings.techStackAutoScroll;
  }

  SiteSettings _currentSettings(SiteSettings existing) {
    return existing.copyWith(
      name: _text('name'),
      role: _text('role'),
      brandPrefix: _text('brandPrefix'),
      heroTitle: _text('heroTitle'),
      heroSubtitle: _text('heroSubtitle'),
      heroPrimaryCta: _text('heroPrimaryCta'),
      heroSecondaryCta: _text('heroSecondaryCta'),
      heroCvLabel: _text('heroCvLabel'),
      heroAvailabilityLabel: _text('heroAvailabilityLabel'),
      heroPillOneLabel: _text('heroPillOneLabel'),
      heroPillOneIconName: _text('heroPillOneIconName'),
      heroPillTwoLabel: _text('heroPillTwoLabel'),
      heroPillTwoIconName: _text('heroPillTwoIconName'),
      heroTrustItems: _parseLines(_text('heroTrustItems')),
      codeStripText: _text('codeStripText'),
      aboutEyebrow: _text('aboutEyebrow'),
      aboutTitle: _text('aboutTitle'),
      aboutSubtitle: _text('aboutSubtitle'),
      about: _text('about'),
      skillsTitle: _text('skillsTitle'),
      skills: _parseLines(_text('skills')),
      coreStackTitle: _text('coreStackTitle'),
      coreStack: _parseLines(_text('coreStack')),
      workingStyleTitle: _text('workingStyleTitle'),
      workingStyle: _parseWorkingStyle(_text('workingStyle')),
      projectsEyebrow: _text('projectsEyebrow'),
      projectsTitle: _text('projectsTitle'),
      projectsSubtitle: _text('projectsSubtitle'),
      featuredProjectsLabel: _text('featuredProjectsLabel'),
      publishedProjectsNote: _text('publishedProjectsNote'),
      projectFilterCategories: _parseLines(_text('projectFilterCategories')),
      servicesEyebrow: _text('servicesEyebrow'),
      servicesTitle: _text('servicesTitle'),
      servicesSubtitle: _text('servicesSubtitle'),
      processTitle: _text('processTitle'),
      processItems: _parseProcessItems(_text('processItems')),
      contactEyebrow: _text('contactEyebrow'),
      contactTitle: _text('contactTitle'),
      contactSubtitle: _text('contactSubtitle'),
      contactCardTitle: _text('contactCardTitle'),
      contactCardBody: _text('contactCardBody'),
      contactFormTitle: _text('contactFormTitle'),
      contactNameLabel: _text('contactNameLabel'),
      contactEmailLabel: _text('contactEmailLabel'),
      contactBudgetLabel: _text('contactBudgetLabel'),
      contactBudgetHint: _text('contactBudgetHint'),
      contactMessageLabel: _text('contactMessageLabel'),
      contactMessageHint: _text('contactMessageHint'),
      contactSubmitLabel: _text('contactSubmitLabel'),
      contactSendingLabel: _text('contactSendingLabel'),
      contactSuccessMessage: _text('contactSuccessMessage'),
      footerTagline: _text('footerTagline'),
      footerRightText: _text('footerRightText'),
      navAboutLabel: _text('navAboutLabel'),
      navProjectsLabel: _text('navProjectsLabel'),
      navServicesLabel: _text('navServicesLabel'),
      navCtaLabel: _text('navCtaLabel'),
      yearsExperience: int.tryParse(_text('yearsExperience')),
      projectsShipped: int.tryParse(_text('projectsShipped')),
      projectsShippedLabel: _text('projectsShippedLabel'),
      yearsExperienceLabel: _text('yearsExperienceLabel'),
      availabilityOpenValue: _text('availabilityOpenValue'),
      availabilityOpenLabel: _text('availabilityOpenLabel'),
      availabilityFocusedValue: _text('availabilityFocusedValue'),
      availabilityFocusedLabel: _text('availabilityFocusedLabel'),
      availableForHire: _availableForHire,
      cvUrl: _text('cvUrl'),
      profilePhotoUrl: _text('profilePhotoUrl'),
      email: _text('email'),
      phone: _text('phone'),
      location: _text('location'),
      socials: {
        for (final entry in _socials.entries)
          entry.key: entry.value.text.trim(),
      },
      showHero: _showHero,
      showTechStack: _showTechStack,
      showAbout: _showAbout,
      showSkills: _showSkills,
      showCoreStack: _showCoreStack,
      showWorkingStyle: _showWorkingStyle,
      showProjects: _showProjects,
      showFeaturedProjects: _showFeaturedProjects,
      showServices: _showServices,
      showProcess: _showProcess,
      showContact: _showContact,
      showFooter: _showFooter,
      techStackAutoScroll: _techStackAutoScroll,
      techStackScrollSeconds:
          int.tryParse(_text('techStackScrollSeconds')) ??
          existing.techStackScrollSeconds,
      seoTitle: _text('seoTitle'),
      seoDescription: _text('seoDescription'),
      seoKeywords: _text('seoKeywords'),
    );
  }

  Future<void> _save(SiteSettings existing) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final updated = _currentSettings(existing);
      await ref.read(firebaseServiceProvider).saveSettings(updated);
      ref.invalidate(siteSettingsProvider);
      _initialized = false;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All public content was saved and verified in Firestore.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static List<String> _parseLines(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<WorkingStyleItem> _parseWorkingStyle(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((line) {
          final parts = line.split('|');
          if (parts.length < 2) return null;
          final iconName = parts.first.trim();
          final text = parts.sublist(1).join('|').trim();
          if (text.isEmpty) return null;
          return WorkingStyleItem(
            iconName: iconName.isEmpty
                ? 'check_circle_outline_rounded'
                : iconName,
            text: text,
          );
        })
        .whereType<WorkingStyleItem>()
        .toList();
  }

  static List<ProcessItem> _parseProcessItems(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((line) {
          final parts = line.split('|');
          if (parts.length < 3) return null;
          final number = parts[0].trim();
          final iconName = parts[1].trim();
          final label = parts.sublist(2).join('|').trim();
          if (label.isEmpty) return null;
          return ProcessItem(
            number: number.isEmpty ? '01' : number,
            iconName: iconName.isEmpty
                ? 'check_circle_outline_rounded'
                : iconName,
            label: label,
          );
        })
        .whereType<ProcessItem>()
        .toList();
  }

  Widget _field(
    String key,
    String label, {
    bool required = false,
    int maxLines = 1,
    String? helperText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: _controller(key),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: required
          ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _pair(BuildContext context, Widget first, Widget second) {
    if (MediaQuery.sizeOf(context).width < 760) {
      return Column(children: [first, const SizedBox(height: 12), second]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }

  Widget _toggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(siteSettingsProvider);

    return AdminScaffold(
      title: 'Settings & Content',
      selectedPath: '/admin/settings',
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Settings could not be loaded.\n$error'),
          ),
        ),
        data: (settings) {
          _load(settings);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CmsHeader(settings: settings),
                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '01 · Identity & navigation',
                    subtitle:
                        'Change the name, role, brand prefix, and every visible navbar label.',
                    child: Column(
                      children: [
                        _pair(
                          context,
                          _field('name', 'Name', required: true),
                          _field('role', 'Role', required: true),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'brandPrefix',
                          'Brand prefix',
                          helperText:
                              'Example: Flutter. Leave empty for name-only branding.',
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('navAboutLabel', 'About navigation label'),
                          _field(
                            'navProjectsLabel',
                            'Projects navigation label',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field(
                            'navServicesLabel',
                            'Services navigation label',
                          ),
                          _field('navCtaLabel', 'Navbar CTA label'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '02 · Visibility & site controls',
                    subtitle:
                        'Switch public sections and sub-sections on or off without touching code.',
                    child: Column(
                      children: [
                        _toggle(
                          'Hero',
                          'Show the main hero area.',
                          _showHero,
                          (v) => setState(() => _showHero = v),
                        ),
                        _toggle(
                          'Tech stack rail',
                          'Show the horizontal technology rail.',
                          _showTechStack,
                          (v) => setState(() => _showTechStack = v),
                        ),
                        _toggle(
                          'About',
                          'Show the About section.',
                          _showAbout,
                          (v) => setState(() => _showAbout = v),
                        ),
                        _toggle(
                          'Skills',
                          'Show skill chips inside About.',
                          _showSkills,
                          (v) => setState(() => _showSkills = v),
                        ),
                        _toggle(
                          'Core stack',
                          'Show the Core stack area inside About.',
                          _showCoreStack,
                          (v) => setState(() => _showCoreStack = v),
                        ),
                        _toggle(
                          'Working style',
                          'Show the Working style area inside About.',
                          _showWorkingStyle,
                          (v) => setState(() => _showWorkingStyle = v),
                        ),
                        _toggle(
                          'Projects',
                          'Show the Projects section.',
                          _showProjects,
                          (v) => setState(() => _showProjects = v),
                        ),
                        _toggle(
                          'Featured projects',
                          'Show the featured horizontal project rail.',
                          _showFeaturedProjects,
                          (v) => setState(() => _showFeaturedProjects = v),
                        ),
                        _toggle(
                          'Services',
                          'Show the Services section.',
                          _showServices,
                          (v) => setState(() => _showServices = v),
                        ),
                        _toggle(
                          'How I work',
                          'Show the process timeline.',
                          _showProcess,
                          (v) => setState(() => _showProcess = v),
                        ),
                        _toggle(
                          'Contact',
                          'Show the contact section and form.',
                          _showContact,
                          (v) => setState(() => _showContact = v),
                        ),
                        _toggle(
                          'Footer',
                          'Show the footer.',
                          _showFooter,
                          (v) => setState(() => _showFooter = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '03 · Hero',
                    subtitle:
                        'Everything visitor-facing in the hero is editable.',
                    child: Column(
                      children: [
                        _field(
                          'heroTitle',
                          'Hero title',
                          required: true,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'heroSubtitle',
                          'Hero subtitle',
                          required: true,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('heroPrimaryCta', 'Primary CTA'),
                          _field('heroSecondaryCta', 'Secondary CTA'),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('heroCvLabel', 'CV button label'),
                          _field(
                            'heroAvailabilityLabel',
                            'Availability badge label',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('heroPillOneLabel', 'Floating pill 1 label'),
                          _field('heroPillTwoLabel', 'Floating pill 2 label'),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field(
                            'heroPillOneIconName',
                            'Floating pill 1 icon',
                            helperText: 'Example: flutter_dash_rounded',
                          ),
                          _field(
                            'heroPillTwoIconName',
                            'Floating pill 2 icon',
                            helperText: 'Example: cloud_outlined',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'heroTrustItems',
                          'Hero trust items',
                          maxLines: 5,
                          helperText:
                              'One item per line. Example: Addis Ababa, Ethiopia',
                        ),
                        const SizedBox(height: 12),
                        _field('codeStripText', 'Hero code strip text'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '04 · Stats & availability',
                    subtitle:
                        'Edit the numbers, labels, and all availability copy.',
                    child: Column(
                      children: [
                        _pair(
                          context,
                          _field(
                            'yearsExperience',
                            'Years experience',
                            keyboardType: TextInputType.number,
                            required: true,
                          ),
                          _field(
                            'projectsShipped',
                            'Projects shipped',
                            keyboardType: TextInputType.number,
                            required: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('yearsExperienceLabel', 'Years label'),
                          _field('projectsShippedLabel', 'Projects label'),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field(
                            'availabilityOpenValue',
                            'Availability open value',
                          ),
                          _field(
                            'availabilityOpenLabel',
                            'Availability open label',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field(
                            'availabilityFocusedValue',
                            'Availability focused value',
                          ),
                          _field(
                            'availabilityFocusedLabel',
                            'Availability focused label',
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _availableForHire,
                          onChanged: (v) =>
                              setState(() => _availableForHire = v),
                          title: const Text('Available for hire'),
                          subtitle: Text(
                            _availableForHire
                                ? 'The public availability badge is visible.'
                                : 'The public availability badge is hidden.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '05 · About, skills, core stack & working style',
                    subtitle: 'Control all visible About copy and lists.',
                    child: Column(
                      children: [
                        _pair(
                          context,
                          _field('aboutEyebrow', 'About eyebrow'),
                          _field('skillsTitle', 'Skills title'),
                        ),
                        const SizedBox(height: 12),
                        _field('aboutTitle', 'About title', maxLines: 2),
                        const SizedBox(height: 12),
                        _field('aboutSubtitle', 'About subtitle', maxLines: 4),
                        const SizedBox(height: 12),
                        _field(
                          'about',
                          'About body',
                          required: true,
                          maxLines: 7,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'skills',
                          'Skills',
                          maxLines: 12,
                          helperText: 'One skill per line.',
                        ),
                        const SizedBox(height: 12),
                        _field('coreStackTitle', 'Core stack title'),
                        const SizedBox(height: 12),
                        _field(
                          'coreStack',
                          'Core stack / tech carousel',
                          maxLines: 12,
                          helperText:
                              'One technology per line. Example: Flutter, Dart, Firebase, Riverpod.',
                        ),
                        const SizedBox(height: 12),
                        _field('workingStyleTitle', 'Working style title'),
                        const SizedBox(height: 12),
                        _field(
                          'workingStyle',
                          'Working style items',
                          maxLines: 10,
                          helperText:
                              'Format: iconName | text. Example: devices_outlined | Responsive from the start',
                        ),
                        const SizedBox(height: 12),
                        const _IconHelper(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '06 · Projects',
                    subtitle:
                        'Control every section heading, note, feature label, and filter category. Use Admin → Projects for actual project records.',
                    child: Column(
                      children: [
                        _field('projectsEyebrow', 'Projects eyebrow'),
                        const SizedBox(height: 12),
                        _field('projectsTitle', 'Projects title', maxLines: 2),
                        const SizedBox(height: 12),
                        _field(
                          'projectsSubtitle',
                          'Projects subtitle',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('featuredProjectsLabel', 'Featured label'),
                          _field('publishedProjectsNote', 'Published note'),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'projectFilterCategories',
                          'Project filter categories',
                          maxLines: 8,
                          helperText:
                              'One category per line. “All” is added automatically.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '07 · Services & How I work',
                    subtitle:
                        'Service records remain in Admin → Services. This controls their surrounding copy and the six-step timeline labels/icons.',
                    child: Column(
                      children: [
                        _field('servicesEyebrow', 'Services eyebrow'),
                        const SizedBox(height: 12),
                        _field('servicesTitle', 'Services title', maxLines: 2),
                        const SizedBox(height: 12),
                        _field(
                          'servicesSubtitle',
                          'Services subtitle',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        _field('processTitle', 'How I work title'),
                        const SizedBox(height: 12),
                        _field(
                          'processItems',
                          'Process items',
                          maxLines: 12,
                          helperText: 'Format: 01 | search_rounded | Discovery',
                        ),
                        const SizedBox(height: 12),
                        _ProcessPreview(source: _text('processItems')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '08 · Contact & conversion',
                    subtitle:
                        'Every contact heading, paragraph, label, hint, button, and success message is editable.',
                    child: Column(
                      children: [
                        _field('contactEyebrow', 'Contact eyebrow'),
                        const SizedBox(height: 12),
                        _field('contactTitle', 'Contact title', maxLines: 2),
                        const SizedBox(height: 12),
                        _field(
                          'contactSubtitle',
                          'Contact subtitle',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'contactCardTitle',
                          'Contact card title',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'contactCardBody',
                          'Contact card body',
                          maxLines: 5,
                        ),
                        const SizedBox(height: 12),
                        _field('contactFormTitle', 'Form title'),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('contactNameLabel', 'Name field label'),
                          _field('contactEmailLabel', 'Email field label'),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('contactBudgetLabel', 'Budget field label'),
                          _field('contactBudgetHint', 'Budget hint'),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('contactMessageLabel', 'Message field label'),
                          _field('contactMessageHint', 'Message hint'),
                        ),
                        const SizedBox(height: 12),
                        _pair(
                          context,
                          _field('contactSubmitLabel', 'Submit label'),
                          _field('contactSendingLabel', 'Sending label'),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'contactSuccessMessage',
                          'Success message',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '09 · Contact details & social links',
                    child: Column(
                      children: [
                        _pair(
                          context,
                          _field(
                            'email',
                            'Email',
                            required: true,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _field(
                            'phone',
                            'Phone',
                            required: true,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _field('location', 'Location', required: true),
                        const SizedBox(height: 18),
                        for (final entry in _socials.entries) ...[
                          TextFormField(
                            controller: entry.value,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              labelText:
                                  '${entry.key[0].toUpperCase()}${entry.key.substring(1)} URL',
                              prefixIcon: const Icon(Icons.link_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '10 · Media (Spark/free)',
                    subtitle:
                        'No Firebase Storage. Use a Flutter asset path or a public HTTPS URL.',
                    child: Column(
                      children: [
                        _field(
                          'profilePhotoUrl',
                          'Profile photo path / URL',
                          helperText: 'Example: assets/images/profile.webp',
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'cvUrl',
                          'CV path / URL',
                          helperText:
                              'Example: assets/cv/junior_flutter_cv.pdf',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '11 · Tech stack animation',
                    subtitle:
                        'Control the end-to-end horizontal automatic scroll.',
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _techStackAutoScroll,
                          onChanged: (v) =>
                              setState(() => _techStackAutoScroll = v),
                          title: const Text('Automatic horizontal scroll'),
                        ),
                        _field(
                          'techStackScrollSeconds',
                          'Loop duration (seconds)',
                          keyboardType: TextInputType.number,
                          helperText: 'Recommended 12–30.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '12 · Footer',
                    child: Column(
                      children: [
                        _field('footerTagline', 'Footer tagline', maxLines: 2),
                        const SizedBox(height: 12),
                        _field('footerRightText', 'Footer right text'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: '13 · SEO',
                    subtitle: 'Editable SEO metadata for the public portfolio.',
                    child: Column(
                      children: [
                        _field('seoTitle', 'SEO title', required: true),
                        const SizedBox(height: 12),
                        _field(
                          'seoDescription',
                          'SEO description',
                          required: true,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          'seoKeywords',
                          'SEO keywords',
                          maxLines: 3,
                          helperText: 'Comma-separated keywords.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : () => _save(settings),
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _saving
                            ? 'Saving & verifying…'
                            : 'Save 100% public content',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CmsHeader extends StatelessWidget {
  const _CmsHeader({required this.settings});

  final SiteSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LiquidGlassFoundation(
      borderRadius: 26,
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withValues(alpha: .12),
          theme.colorScheme.surface.withValues(alpha: .08),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dashboard_customize_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Public Content Control',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${settings.name} · ${settings.role}',
                  style: theme.textTheme.bodyMedium?.copyWith(
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _IconHelper extends StatelessWidget {
  const _IconHelper();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const values = [
      'flutter_dash_rounded',
      'cloud_outlined',
      'search_rounded',
      'auto_awesome_rounded',
      'code_rounded',
      'check_circle_outline_rounded',
      'rocket_launch_rounded',
      'support_agent_rounded',
      'visibility_outlined',
      'devices_outlined',
      'speed_outlined',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Supported icon names:'),
          for (final name in values)
            Chip(
              avatar: Icon(ContentIcon.fromName(name), size: 16),
              label: Text(name),
            ),
        ],
      ),
    );
  }
}

class _ProcessPreview extends StatelessWidget {
  const _ProcessPreview({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final items = source
        .split(RegExp(r'\r?\n'))
        .map((line) {
          final parts = line.split('|');
          if (parts.length < 3) return null;
          final number = parts[0].trim();
          final iconName = parts[1].trim();
          final label = parts.sublist(2).join('|').trim();
          if (label.isEmpty) return null;
          return ProcessItem(number: number, iconName: iconName, label: label);
        })
        .whereType<ProcessItem>()
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Chip(
            avatar: CircleAvatar(
              radius: 12,
              child: Icon(ContentIcon.fromName(item.iconName), size: 14),
            ),
            label: Text('${item.number} ${item.label}'),
          ),
      ],
    );
  }
}
