import 'package:cloud_firestore/cloud_firestore.dart';

class WorkingStyleItem {
  const WorkingStyleItem({required this.iconName, required this.text});

  final String iconName;
  final String text;

  factory WorkingStyleItem.fromMap(Map<String, dynamic> map) {
    return WorkingStyleItem(
      iconName: map['iconName'] as String? ?? 'check_circle_outline_rounded',
      text: map['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'iconName': iconName,
        'text': text,
      };
}

class ProcessItem {
  const ProcessItem({
    required this.number,
    required this.iconName,
    required this.label,
  });

  final String number;
  final String iconName;
  final String label;

  factory ProcessItem.fromMap(Map<String, dynamic> map) {
    return ProcessItem(
      number: map['number'] as String? ?? '01',
      iconName: map['iconName'] as String? ?? 'check_circle_outline_rounded',
      label: map['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'number': number,
        'iconName': iconName,
        'label': label,
      };
}

class SiteSettings {
  const SiteSettings({
    required this.name,
    required this.role,
    required this.brandPrefix,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroPrimaryCta,
    required this.heroSecondaryCta,
    required this.heroCvLabel,
    required this.heroAvailabilityLabel,
    required this.heroPillOneLabel,
    required this.heroPillOneIconName,
    required this.heroPillTwoLabel,
    required this.heroPillTwoIconName,
    required this.heroTrustItems,
    required this.codeStripText,
    required this.aboutEyebrow,
    required this.aboutTitle,
    required this.aboutSubtitle,
    required this.about,
    required this.skillsTitle,
    required this.skills,
    required this.coreStackTitle,
    required this.coreStack,
    required this.workingStyleTitle,
    required this.workingStyle,
    required this.projectsEyebrow,
    required this.projectsTitle,
    required this.projectsSubtitle,
    required this.featuredProjectsLabel,
    required this.publishedProjectsNote,
    required this.projectFilterCategories,
    required this.servicesEyebrow,
    required this.servicesTitle,
    required this.servicesSubtitle,
    required this.processTitle,
    required this.processItems,
    required this.contactEyebrow,
    required this.contactTitle,
    required this.contactSubtitle,
    required this.contactCardTitle,
    required this.contactCardBody,
    required this.contactFormTitle,
    required this.contactNameLabel,
    required this.contactEmailLabel,
    required this.contactBudgetLabel,
    required this.contactBudgetHint,
    required this.contactMessageLabel,
    required this.contactMessageHint,
    required this.contactSubmitLabel,
    required this.contactSendingLabel,
    required this.contactSuccessMessage,
    required this.footerTagline,
    required this.footerRightText,
    required this.navAboutLabel,
    required this.navProjectsLabel,
    required this.navServicesLabel,
    required this.navCtaLabel,
    required this.yearsExperience,
    required this.projectsShipped,
    required this.projectsShippedLabel,
    required this.yearsExperienceLabel,
    required this.availabilityOpenValue,
    required this.availabilityOpenLabel,
    required this.availabilityFocusedValue,
    required this.availabilityFocusedLabel,
    required this.availableForHire,
    required this.cvUrl,
    required this.profilePhotoUrl,
    required this.email,
    required this.phone,
    required this.location,
    required this.socials,
    required this.showHero,
    required this.showTechStack,
    required this.showAbout,
    required this.showSkills,
    required this.showCoreStack,
    required this.showWorkingStyle,
    required this.showProjects,
    required this.showFeaturedProjects,
    required this.showServices,
    required this.showProcess,
    required this.showContact,
    required this.showFooter,
    required this.techStackAutoScroll,
    required this.techStackScrollSeconds,
    required this.seoTitle,
    required this.seoDescription,
    required this.seoKeywords,
  });

  final String name;
  final String role;
  final String brandPrefix;
  final String heroTitle;
  final String heroSubtitle;
  final String heroPrimaryCta;
  final String heroSecondaryCta;
  final String heroCvLabel;
  final String heroAvailabilityLabel;
  final String heroPillOneLabel;
  final String heroPillOneIconName;
  final String heroPillTwoLabel;
  final String heroPillTwoIconName;
  final List<String> heroTrustItems;
  final String codeStripText;

  final String aboutEyebrow;
  final String aboutTitle;
  final String aboutSubtitle;
  final String about;
  final String skillsTitle;
  final List<String> skills;
  final String coreStackTitle;
  final List<String> coreStack;
  final String workingStyleTitle;
  final List<WorkingStyleItem> workingStyle;

  final String projectsEyebrow;
  final String projectsTitle;
  final String projectsSubtitle;
  final String featuredProjectsLabel;
  final String publishedProjectsNote;
  final List<String> projectFilterCategories;

  final String servicesEyebrow;
  final String servicesTitle;
  final String servicesSubtitle;
  final String processTitle;
  final List<ProcessItem> processItems;

  final String contactEyebrow;
  final String contactTitle;
  final String contactSubtitle;
  final String contactCardTitle;
  final String contactCardBody;
  final String contactFormTitle;
  final String contactNameLabel;
  final String contactEmailLabel;
  final String contactBudgetLabel;
  final String contactBudgetHint;
  final String contactMessageLabel;
  final String contactMessageHint;
  final String contactSubmitLabel;
  final String contactSendingLabel;
  final String contactSuccessMessage;

  final String footerTagline;
  final String footerRightText;
  final String navAboutLabel;
  final String navProjectsLabel;
  final String navServicesLabel;
  final String navCtaLabel;

  final int yearsExperience;
  final int projectsShipped;
  final String projectsShippedLabel;
  final String yearsExperienceLabel;
  final String availabilityOpenValue;
  final String availabilityOpenLabel;
  final String availabilityFocusedValue;
  final String availabilityFocusedLabel;
  final bool availableForHire;

  final String cvUrl;
  final String profilePhotoUrl;
  final String email;
  final String phone;
  final String location;
  final Map<String, String> socials;

  final bool showHero;
  final bool showTechStack;
  final bool showAbout;
  final bool showSkills;
  final bool showCoreStack;
  final bool showWorkingStyle;
  final bool showProjects;
  final bool showFeaturedProjects;
  final bool showServices;
  final bool showProcess;
  final bool showContact;
  final bool showFooter;
  final bool techStackAutoScroll;
  final int techStackScrollSeconds;
  final String seoTitle;
  final String seoDescription;
  final String seoKeywords;

  static const defaults = SiteSettings(
    name: 'Fraol Dirirsa',
    role: 'Junior Flutter Developer',
    brandPrefix: 'Flutter',
    heroTitle: 'I build clean, useful Flutter apps for mobile and web.',
    heroSubtitle:
        'Junior Flutter Developer focused on building responsive interfaces, Firebase-powered applications, and practical digital experiences. I enjoy turning ideas into polished products while continuously improving my engineering skills.',
    heroPrimaryCta: 'Let’s work together',
    heroSecondaryCta: 'View my work',
    heroCvLabel: 'CV',
    heroAvailabilityLabel: 'Available for hire',
    heroPillOneLabel: 'Flutter',
    heroPillOneIconName: 'flutter_dash_rounded',
    heroPillTwoLabel: 'Firebase',
    heroPillTwoIconName: 'cloud_outlined',
    heroTrustItems: [
      'Addis Ababa, Ethiopia',
      'Flutter + Firebase',
      'Mobile & Web',
    ],
    codeStripText: 'build → ship → learn',
    aboutEyebrow: 'About me',
    aboutTitle: 'Curious by default. Careful with the details.',
    aboutSubtitle:
        'I am building my career around Flutter, Firebase, and thoughtful product experiences — learning quickly, shipping steadily, and improving with every release.',
    about:
        'I am a junior Flutter developer building real products while growing strong foundations in clean code, Firebase, responsive UI, and testing.',
    skillsTitle: 'Skills',
    skills: [
      'Dart',
      'Flutter',
      'Firebase',
      'REST APIs',
      'Riverpod',
      'Responsive UI',
      'Git',
      'CI/CD',
      'Testing',
    ],
    coreStackTitle: 'Core stack',
    coreStack: [
      'Flutter',
      'Dart',
      'Firebase',
      'REST APIs',
      'Responsive UI',
      'Riverpod',
      'Testing',
    ],
    workingStyleTitle: 'Working style',
    workingStyle: [
      WorkingStyleItem(
        iconName: 'visibility_outlined',
        text: 'Clear scope before code',
      ),
      WorkingStyleItem(
        iconName: 'devices_outlined',
        text: 'Responsive from the start',
      ),
      WorkingStyleItem(
        iconName: 'speed_outlined',
        text: 'Small, shippable iterations',
      ),
    ],
    projectsEyebrow: 'Selected work',
    projectsTitle: 'A small body of work, built to be useful.',
    projectsSubtitle:
        'Explore the projects I have chosen to publish. Each one is a place to practice product thinking, engineering, and polish.',
    featuredProjectsLabel: 'Featured work',
    publishedProjectsNote: 'Only published projects are visible publicly.',
    projectFilterCategories: [
      'Mobile Apps',
      'Web Apps',
      'Packages',
      'UI/UX',
      'Open Source',
    ],
    servicesEyebrow: 'Services & process',
    servicesTitle: 'From first conversation to a clean release.',
    servicesSubtitle:
        'The offer stays practical: clarify the problem, design the experience, build the product, test the edges, and launch with confidence.',
    processTitle: 'How I work',
    processItems: [
      ProcessItem(number: '01', iconName: 'search_rounded', label: 'Discovery'),
      ProcessItem(number: '02', iconName: 'auto_awesome_rounded', label: 'Design'),
      ProcessItem(number: '03', iconName: 'code_rounded', label: 'Build'),
      ProcessItem(
        number: '04',
        iconName: 'check_circle_outline_rounded',
        label: 'Test',
      ),
      ProcessItem(
        number: '05',
        iconName: 'rocket_launch_rounded',
        label: 'Launch',
      ),
      ProcessItem(number: '06', iconName: 'support_agent_rounded', label: 'Support'),
    ],
    contactEyebrow: 'Contact',
    contactTitle: 'Have something worth building?',
    contactSubtitle:
        'No pressure, no giant brief required. A few clear sentences are enough to start the conversation.',
    contactCardTitle: 'Let’s make the next project a good one.',
    contactCardBody:
        'Tell me what you are building, the outcome you want, and your timeline. I’ll reply with the next practical step.',
    contactFormTitle: 'Start a conversation',
    contactNameLabel: 'Name',
    contactEmailLabel: 'Email',
    contactBudgetLabel: 'Project budget',
    contactBudgetHint: 'e.g. 30,000–60,000 ETB',
    contactMessageLabel: 'Message',
    contactMessageHint: 'What are you building? What should it achieve?',
    contactSubmitLabel: 'Send inquiry',
    contactSendingLabel: 'Sending…',
    contactSuccessMessage: 'Message sent. Thanks — I’ll get back to you soon.',
    footerTagline: 'Built with care, shipped with Flutter.',
    footerRightText: 'Made for the web',
    navAboutLabel: 'About',
    navProjectsLabel: 'Projects',
    navServicesLabel: 'Services',
    navCtaLabel: 'Let’s talk',
    yearsExperience: 1,
    projectsShipped: 4,
    projectsShippedLabel: 'Projects shipped',
    yearsExperienceLabel: 'Year of experience',
    availabilityOpenValue: 'Open',
    availabilityOpenLabel: 'For new opportunities',
    availabilityFocusedValue: 'Focused',
    availabilityFocusedLabel: 'Current availability',
    availableForHire: true,
    cvUrl: '',
    profilePhotoUrl: '',
    email: 'hello@example.com',
    phone: '+251 900 000 000',
    location: 'Addis Ababa, Ethiopia',
    socials: {
      'github': '',
      'linkedin': '',
      'twitter': '',
      'stackoverflow': '',
      'medium': '',
    },
    showHero: true,
    showTechStack: true,
    showAbout: true,
    showSkills: true,
    showCoreStack: true,
    showWorkingStyle: true,
    showProjects: true,
    showFeaturedProjects: true,
    showServices: true,
    showProcess: true,
    showContact: true,
    showFooter: true,
    techStackAutoScroll: true,
    techStackScrollSeconds: 16,
    seoTitle: 'Fraol Dirirsa — Junior Flutter Developer',
    seoDescription:
        'Portfolio of Fraol Dirirsa, a Junior Flutter Developer building responsive mobile and web experiences with Flutter and Firebase.',
    seoKeywords:
        'Fraol Dirirsa, Flutter Developer, Junior Flutter Developer, Flutter, Dart, Firebase, Ethiopia',
  );

  factory SiteSettings.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawSocials = _asStringMap(data['socials']);

    return SiteSettings(
      name: _asString(data['name'], defaults.name),
      role: _asString(data['role'], defaults.role),
      brandPrefix: _asString(data['brandPrefix'], defaults.brandPrefix),
      heroTitle: _asString(data['heroTitle'], defaults.heroTitle),
      heroSubtitle: _asString(data['heroSubtitle'], defaults.heroSubtitle),
      heroPrimaryCta: _asString(data['heroPrimaryCta'], defaults.heroPrimaryCta),
      heroSecondaryCta: _asString(data['heroSecondaryCta'], defaults.heroSecondaryCta),
      heroCvLabel: _asString(data['heroCvLabel'], defaults.heroCvLabel),
      heroAvailabilityLabel: _asString(data['heroAvailabilityLabel'], defaults.heroAvailabilityLabel),
      heroPillOneLabel: _asString(data['heroPillOneLabel'], defaults.heroPillOneLabel),
      heroPillOneIconName: _asString(data['heroPillOneIconName'], defaults.heroPillOneIconName),
      heroPillTwoLabel: _asString(data['heroPillTwoLabel'], defaults.heroPillTwoLabel),
      heroPillTwoIconName: _asString(data['heroPillTwoIconName'], defaults.heroPillTwoIconName),
      heroTrustItems: _asStringList(data['heroTrustItems'], fallback: defaults.heroTrustItems),
      codeStripText: _asString(data['codeStripText'], defaults.codeStripText),
      aboutEyebrow: _asString(data['aboutEyebrow'], defaults.aboutEyebrow),
      aboutTitle: _asString(data['aboutTitle'], defaults.aboutTitle),
      aboutSubtitle: _asString(data['aboutSubtitle'], defaults.aboutSubtitle),
      about: _asString(data['about'], defaults.about),
      skillsTitle: _asString(data['skillsTitle'], defaults.skillsTitle),
      skills: _asStringList(data['skills'], fallback: defaults.skills),
      coreStackTitle: _asString(data['coreStackTitle'], defaults.coreStackTitle),
      coreStack: _asStringList(data['coreStack'], fallback: defaults.coreStack),
      workingStyleTitle: _asString(data['workingStyleTitle'], defaults.workingStyleTitle),
      workingStyle: _asWorkingStyleList(data['workingStyle'], fallback: defaults.workingStyle),
      projectsEyebrow: _asString(data['projectsEyebrow'], defaults.projectsEyebrow),
      projectsTitle: _asString(data['projectsTitle'], defaults.projectsTitle),
      projectsSubtitle: _asString(data['projectsSubtitle'], defaults.projectsSubtitle),
      featuredProjectsLabel: _asString(data['featuredProjectsLabel'], defaults.featuredProjectsLabel),
      publishedProjectsNote: _asString(data['publishedProjectsNote'], defaults.publishedProjectsNote),
      projectFilterCategories: _asStringList(data['projectFilterCategories'], fallback: defaults.projectFilterCategories),
      servicesEyebrow: _asString(data['servicesEyebrow'], defaults.servicesEyebrow),
      servicesTitle: _asString(data['servicesTitle'], defaults.servicesTitle),
      servicesSubtitle: _asString(data['servicesSubtitle'], defaults.servicesSubtitle),
      processTitle: _asString(data['processTitle'], defaults.processTitle),
      processItems: _asProcessList(data['processItems'], fallback: defaults.processItems),
      contactEyebrow: _asString(data['contactEyebrow'], defaults.contactEyebrow),
      contactTitle: _asString(data['contactTitle'], defaults.contactTitle),
      contactSubtitle: _asString(data['contactSubtitle'], defaults.contactSubtitle),
      contactCardTitle: _asString(data['contactCardTitle'], defaults.contactCardTitle),
      contactCardBody: _asString(data['contactCardBody'], defaults.contactCardBody),
      contactFormTitle: _asString(data['contactFormTitle'], defaults.contactFormTitle),
      contactNameLabel: _asString(data['contactNameLabel'], defaults.contactNameLabel),
      contactEmailLabel: _asString(data['contactEmailLabel'], defaults.contactEmailLabel),
      contactBudgetLabel: _asString(data['contactBudgetLabel'], defaults.contactBudgetLabel),
      contactBudgetHint: _asString(data['contactBudgetHint'], defaults.contactBudgetHint),
      contactMessageLabel: _asString(data['contactMessageLabel'], defaults.contactMessageLabel),
      contactMessageHint: _asString(data['contactMessageHint'], defaults.contactMessageHint),
      contactSubmitLabel: _asString(data['contactSubmitLabel'], defaults.contactSubmitLabel),
      contactSendingLabel: _asString(data['contactSendingLabel'], defaults.contactSendingLabel),
      contactSuccessMessage: _asString(data['contactSuccessMessage'], defaults.contactSuccessMessage),
      footerTagline: _asString(data['footerTagline'], defaults.footerTagline),
      footerRightText: _asString(data['footerRightText'], defaults.footerRightText),
      navAboutLabel: _asString(data['navAboutLabel'], defaults.navAboutLabel),
      navProjectsLabel: _asString(data['navProjectsLabel'], defaults.navProjectsLabel),
      navServicesLabel: _asString(data['navServicesLabel'], defaults.navServicesLabel),
      navCtaLabel: _asString(data['navCtaLabel'], defaults.navCtaLabel),
      yearsExperience: _asInt(data['yearsExperience'], defaults.yearsExperience),
      projectsShipped: _asInt(data['projectsShipped'], defaults.projectsShipped),
      projectsShippedLabel: _asString(data['projectsShippedLabel'], defaults.projectsShippedLabel),
      yearsExperienceLabel: _asString(data['yearsExperienceLabel'], defaults.yearsExperienceLabel),
      availabilityOpenValue: _asString(data['availabilityOpenValue'], defaults.availabilityOpenValue),
      availabilityOpenLabel: _asString(data['availabilityOpenLabel'], defaults.availabilityOpenLabel),
      availabilityFocusedValue: _asString(data['availabilityFocusedValue'], defaults.availabilityFocusedValue),
      availabilityFocusedLabel: _asString(data['availabilityFocusedLabel'], defaults.availabilityFocusedLabel),
      availableForHire: data['availableForHire'] as bool? ?? defaults.availableForHire,
      cvUrl: _asString(data['cvUrl'], defaults.cvUrl),
      profilePhotoUrl: _asString(data['profilePhotoUrl'], defaults.profilePhotoUrl),
      email: _asString(data['email'], defaults.email),
      phone: _asString(data['phone'], defaults.phone),
      location: _asString(data['location'], defaults.location),
      socials: {
        for (final entry in defaults.socials.entries)
          entry.key: rawSocials[entry.key] ?? entry.value,
      },
      showHero: _asBool(data['showHero'], defaults.showHero),
      showTechStack: _asBool(data['showTechStack'], defaults.showTechStack),
      showAbout: _asBool(data['showAbout'], defaults.showAbout),
      showSkills: _asBool(data['showSkills'], defaults.showSkills),
      showCoreStack: _asBool(data['showCoreStack'], defaults.showCoreStack),
      showWorkingStyle: _asBool(data['showWorkingStyle'], defaults.showWorkingStyle),
      showProjects: _asBool(data['showProjects'], defaults.showProjects),
      showFeaturedProjects: _asBool(data['showFeaturedProjects'], defaults.showFeaturedProjects),
      showServices: _asBool(data['showServices'], defaults.showServices),
      showProcess: _asBool(data['showProcess'], defaults.showProcess),
      showContact: _asBool(data['showContact'], defaults.showContact),
      showFooter: _asBool(data['showFooter'], defaults.showFooter),
      techStackAutoScroll: _asBool(data['techStackAutoScroll'], defaults.techStackAutoScroll),
      techStackScrollSeconds: _asInt(data['techStackScrollSeconds'], defaults.techStackScrollSeconds),
      seoTitle: _asString(data['seoTitle'], defaults.seoTitle),
      seoDescription: _asString(data['seoDescription'], defaults.seoDescription),
      seoKeywords: _asString(data['seoKeywords'], defaults.seoKeywords),
    );
  }

  SiteSettings copyWith({
    String? name,
    String? role,
    String? brandPrefix,
    String? heroTitle,
    String? heroSubtitle,
    String? heroPrimaryCta,
    String? heroSecondaryCta,
    String? heroCvLabel,
    String? heroAvailabilityLabel,
    String? heroPillOneLabel,
    String? heroPillOneIconName,
    String? heroPillTwoLabel,
    String? heroPillTwoIconName,
    List<String>? heroTrustItems,
    String? codeStripText,
    String? aboutEyebrow,
    String? aboutTitle,
    String? aboutSubtitle,
    String? about,
    String? skillsTitle,
    List<String>? skills,
    String? coreStackTitle,
    List<String>? coreStack,
    String? workingStyleTitle,
    List<WorkingStyleItem>? workingStyle,
    String? projectsEyebrow,
    String? projectsTitle,
    String? projectsSubtitle,
    String? featuredProjectsLabel,
    String? publishedProjectsNote,
    List<String>? projectFilterCategories,
    String? servicesEyebrow,
    String? servicesTitle,
    String? servicesSubtitle,
    String? processTitle,
    List<ProcessItem>? processItems,
    String? contactEyebrow,
    String? contactTitle,
    String? contactSubtitle,
    String? contactCardTitle,
    String? contactCardBody,
    String? contactFormTitle,
    String? contactNameLabel,
    String? contactEmailLabel,
    String? contactBudgetLabel,
    String? contactBudgetHint,
    String? contactMessageLabel,
    String? contactMessageHint,
    String? contactSubmitLabel,
    String? contactSendingLabel,
    String? contactSuccessMessage,
    String? footerTagline,
    String? footerRightText,
    String? navAboutLabel,
    String? navProjectsLabel,
    String? navServicesLabel,
    String? navCtaLabel,
    int? yearsExperience,
    int? projectsShipped,
    String? projectsShippedLabel,
    String? yearsExperienceLabel,
    String? availabilityOpenValue,
    String? availabilityOpenLabel,
    String? availabilityFocusedValue,
    String? availabilityFocusedLabel,
    bool? availableForHire,
    String? cvUrl,
    String? profilePhotoUrl,
    String? email,
    String? phone,
    String? location,
    Map<String, String>? socials,
    bool? showHero,
    bool? showTechStack,
    bool? showAbout,
    bool? showSkills,
    bool? showCoreStack,
    bool? showWorkingStyle,
    bool? showProjects,
    bool? showFeaturedProjects,
    bool? showServices,
    bool? showProcess,
    bool? showContact,
    bool? showFooter,
    bool? techStackAutoScroll,
    int? techStackScrollSeconds,
    String? seoTitle,
    String? seoDescription,
    String? seoKeywords,
  }) {
    return SiteSettings(
      name: name ?? this.name,
      role: role ?? this.role,
      brandPrefix: brandPrefix ?? this.brandPrefix,
      heroTitle: heroTitle ?? this.heroTitle,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      heroPrimaryCta: heroPrimaryCta ?? this.heroPrimaryCta,
      heroSecondaryCta: heroSecondaryCta ?? this.heroSecondaryCta,
      heroCvLabel: heroCvLabel ?? this.heroCvLabel,
      heroAvailabilityLabel: heroAvailabilityLabel ?? this.heroAvailabilityLabel,
      heroPillOneLabel: heroPillOneLabel ?? this.heroPillOneLabel,
      heroPillOneIconName: heroPillOneIconName ?? this.heroPillOneIconName,
      heroPillTwoLabel: heroPillTwoLabel ?? this.heroPillTwoLabel,
      heroPillTwoIconName: heroPillTwoIconName ?? this.heroPillTwoIconName,
      heroTrustItems: heroTrustItems ?? this.heroTrustItems,
      codeStripText: codeStripText ?? this.codeStripText,
      aboutEyebrow: aboutEyebrow ?? this.aboutEyebrow,
      aboutTitle: aboutTitle ?? this.aboutTitle,
      aboutSubtitle: aboutSubtitle ?? this.aboutSubtitle,
      about: about ?? this.about,
      skillsTitle: skillsTitle ?? this.skillsTitle,
      skills: skills ?? this.skills,
      coreStackTitle: coreStackTitle ?? this.coreStackTitle,
      coreStack: coreStack ?? this.coreStack,
      workingStyleTitle: workingStyleTitle ?? this.workingStyleTitle,
      workingStyle: workingStyle ?? this.workingStyle,
      projectsEyebrow: projectsEyebrow ?? this.projectsEyebrow,
      projectsTitle: projectsTitle ?? this.projectsTitle,
      projectsSubtitle: projectsSubtitle ?? this.projectsSubtitle,
      featuredProjectsLabel: featuredProjectsLabel ?? this.featuredProjectsLabel,
      publishedProjectsNote: publishedProjectsNote ?? this.publishedProjectsNote,
      projectFilterCategories: projectFilterCategories ?? this.projectFilterCategories,
      servicesEyebrow: servicesEyebrow ?? this.servicesEyebrow,
      servicesTitle: servicesTitle ?? this.servicesTitle,
      servicesSubtitle: servicesSubtitle ?? this.servicesSubtitle,
      processTitle: processTitle ?? this.processTitle,
      processItems: processItems ?? this.processItems,
      contactEyebrow: contactEyebrow ?? this.contactEyebrow,
      contactTitle: contactTitle ?? this.contactTitle,
      contactSubtitle: contactSubtitle ?? this.contactSubtitle,
      contactCardTitle: contactCardTitle ?? this.contactCardTitle,
      contactCardBody: contactCardBody ?? this.contactCardBody,
      contactFormTitle: contactFormTitle ?? this.contactFormTitle,
      contactNameLabel: contactNameLabel ?? this.contactNameLabel,
      contactEmailLabel: contactEmailLabel ?? this.contactEmailLabel,
      contactBudgetLabel: contactBudgetLabel ?? this.contactBudgetLabel,
      contactBudgetHint: contactBudgetHint ?? this.contactBudgetHint,
      contactMessageLabel: contactMessageLabel ?? this.contactMessageLabel,
      contactMessageHint: contactMessageHint ?? this.contactMessageHint,
      contactSubmitLabel: contactSubmitLabel ?? this.contactSubmitLabel,
      contactSendingLabel: contactSendingLabel ?? this.contactSendingLabel,
      contactSuccessMessage: contactSuccessMessage ?? this.contactSuccessMessage,
      footerTagline: footerTagline ?? this.footerTagline,
      footerRightText: footerRightText ?? this.footerRightText,
      navAboutLabel: navAboutLabel ?? this.navAboutLabel,
      navProjectsLabel: navProjectsLabel ?? this.navProjectsLabel,
      navServicesLabel: navServicesLabel ?? this.navServicesLabel,
      navCtaLabel: navCtaLabel ?? this.navCtaLabel,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      projectsShipped: projectsShipped ?? this.projectsShipped,
      projectsShippedLabel: projectsShippedLabel ?? this.projectsShippedLabel,
      yearsExperienceLabel: yearsExperienceLabel ?? this.yearsExperienceLabel,
      availabilityOpenValue: availabilityOpenValue ?? this.availabilityOpenValue,
      availabilityOpenLabel: availabilityOpenLabel ?? this.availabilityOpenLabel,
      availabilityFocusedValue: availabilityFocusedValue ?? this.availabilityFocusedValue,
      availabilityFocusedLabel: availabilityFocusedLabel ?? this.availabilityFocusedLabel,
      availableForHire: availableForHire ?? this.availableForHire,
      cvUrl: cvUrl ?? this.cvUrl,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      socials: socials ?? this.socials,
      showHero: showHero ?? this.showHero,
      showTechStack: showTechStack ?? this.showTechStack,
      showAbout: showAbout ?? this.showAbout,
      showSkills: showSkills ?? this.showSkills,
      showCoreStack: showCoreStack ?? this.showCoreStack,
      showWorkingStyle: showWorkingStyle ?? this.showWorkingStyle,
      showProjects: showProjects ?? this.showProjects,
      showFeaturedProjects: showFeaturedProjects ?? this.showFeaturedProjects,
      showServices: showServices ?? this.showServices,
      showProcess: showProcess ?? this.showProcess,
      showContact: showContact ?? this.showContact,
      showFooter: showFooter ?? this.showFooter,
      techStackAutoScroll: techStackAutoScroll ?? this.techStackAutoScroll,
      techStackScrollSeconds: techStackScrollSeconds ?? this.techStackScrollSeconds,
      seoTitle: seoTitle ?? this.seoTitle,
      seoDescription: seoDescription ?? this.seoDescription,
      seoKeywords: seoKeywords ?? this.seoKeywords,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'role': role,
        'brandPrefix': brandPrefix,
        'heroTitle': heroTitle,
        'heroSubtitle': heroSubtitle,
        'heroPrimaryCta': heroPrimaryCta,
        'heroSecondaryCta': heroSecondaryCta,
        'heroCvLabel': heroCvLabel,
        'heroAvailabilityLabel': heroAvailabilityLabel,
        'heroPillOneLabel': heroPillOneLabel,
        'heroPillOneIconName': heroPillOneIconName,
        'heroPillTwoLabel': heroPillTwoLabel,
        'heroPillTwoIconName': heroPillTwoIconName,
        'heroTrustItems': heroTrustItems,
        'codeStripText': codeStripText,
        'aboutEyebrow': aboutEyebrow,
        'aboutTitle': aboutTitle,
        'aboutSubtitle': aboutSubtitle,
        'about': about,
        'skillsTitle': skillsTitle,
        'skills': skills,
        'coreStackTitle': coreStackTitle,
        'coreStack': coreStack,
        'workingStyleTitle': workingStyleTitle,
        'workingStyle': workingStyle.map((item) => item.toMap()).toList(),
        'projectsEyebrow': projectsEyebrow,
        'projectsTitle': projectsTitle,
        'projectsSubtitle': projectsSubtitle,
        'featuredProjectsLabel': featuredProjectsLabel,
        'publishedProjectsNote': publishedProjectsNote,
        'projectFilterCategories': projectFilterCategories,
        'servicesEyebrow': servicesEyebrow,
        'servicesTitle': servicesTitle,
        'servicesSubtitle': servicesSubtitle,
        'processTitle': processTitle,
        'processItems': processItems.map((item) => item.toMap()).toList(),
        'contactEyebrow': contactEyebrow,
        'contactTitle': contactTitle,
        'contactSubtitle': contactSubtitle,
        'contactCardTitle': contactCardTitle,
        'contactCardBody': contactCardBody,
        'contactFormTitle': contactFormTitle,
        'contactNameLabel': contactNameLabel,
        'contactEmailLabel': contactEmailLabel,
        'contactBudgetLabel': contactBudgetLabel,
        'contactBudgetHint': contactBudgetHint,
        'contactMessageLabel': contactMessageLabel,
        'contactMessageHint': contactMessageHint,
        'contactSubmitLabel': contactSubmitLabel,
        'contactSendingLabel': contactSendingLabel,
        'contactSuccessMessage': contactSuccessMessage,
        'footerTagline': footerTagline,
        'footerRightText': footerRightText,
        'navAboutLabel': navAboutLabel,
        'navProjectsLabel': navProjectsLabel,
        'navServicesLabel': navServicesLabel,
        'navCtaLabel': navCtaLabel,
        'yearsExperience': yearsExperience,
        'projectsShipped': projectsShipped,
        'projectsShippedLabel': projectsShippedLabel,
        'yearsExperienceLabel': yearsExperienceLabel,
        'availabilityOpenValue': availabilityOpenValue,
        'availabilityOpenLabel': availabilityOpenLabel,
        'availabilityFocusedValue': availabilityFocusedValue,
        'availabilityFocusedLabel': availabilityFocusedLabel,
        'availableForHire': availableForHire,
        'cvUrl': cvUrl,
        'profilePhotoUrl': profilePhotoUrl,
        'email': email,
        'phone': phone,
        'location': location,
        'socials': socials,
        'showHero': showHero,
        'showTechStack': showTechStack,
        'showAbout': showAbout,
        'showSkills': showSkills,
        'showCoreStack': showCoreStack,
        'showWorkingStyle': showWorkingStyle,
        'showProjects': showProjects,
        'showFeaturedProjects': showFeaturedProjects,
        'showServices': showServices,
        'showProcess': showProcess,
        'showContact': showContact,
        'showFooter': showFooter,
        'techStackAutoScroll': techStackAutoScroll,
        'techStackScrollSeconds': techStackScrollSeconds,
        'seoTitle': seoTitle,
        'seoDescription': seoDescription,
        'seoKeywords': seoKeywords,
      };

  static String _asString(dynamic value, String fallback) {
    return value is String ? value.trim() : fallback;
  }

  static int _asInt(dynamic value, int fallback) {
    return value is num ? value.toInt() : fallback;
  }

  static bool _asBool(dynamic value, bool fallback) {
    return value is bool ? value : fallback;
  }

  static List<String> _asStringList(dynamic value, {required List<String> fallback}) {
    if (value == null || value is! List) {
      return List<String>.from(fallback);
    }
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static Map<String, String> _asStringMap(dynamic value) {
    if (value is! Map) return <String, String>{};
    return <String, String>{
      for (final entry in value.entries)
        if (entry.value is String)
          entry.key.toString(): (entry.value as String).trim(),
    };
  }

  static List<WorkingStyleItem> _asWorkingStyleList(
    dynamic value, {
    required List<WorkingStyleItem> fallback,
  }) {
    if (value == null || value is! List) {
      return List<WorkingStyleItem>.from(fallback);
    }
    return value
        .whereType<Map>()
        .map((item) => WorkingStyleItem.fromMap(Map<String, dynamic>.from(item)))
        .where((item) => item.text.trim().isNotEmpty)
        .toList();
  }

  static List<ProcessItem> _asProcessList(
    dynamic value, {
    required List<ProcessItem> fallback,
  }) {
    if (value == null || value is! List) {
      return List<ProcessItem>.from(fallback);
    }
    return value
        .whereType<Map>()
        .map((item) => ProcessItem.fromMap(Map<String, dynamic>.from(item)))
        .where((item) => item.label.trim().isNotEmpty)
        .toList();
  }
}
