/**
 * Seeds realistic starter content.
 *
 * Before running, set GOOGLE_APPLICATION_CREDENTIALS to a Firebase service
 * account JSON file, then run:
 *   node scripts/seed.js
 */

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

const settings = {
  name: 'Fraol Dirirsa',
  role: 'Junior Flutter Developer',
  brandPrefix: 'Flutter',
  heroTitle: 'I build clean, useful Flutter apps for mobile and web.',
  heroSubtitle:
    'Junior Flutter Developer focused on building responsive interfaces, Firebase-powered applications, and practical digital experiences. I enjoy turning ideas into polished products while continuously improving my engineering skills.',
  heroPrimaryCta: 'Let’s work together',
  heroSecondaryCta: 'View my work',
  heroCvLabel: 'CV',
  heroAvailabilityLabel: 'Available for freelance',
  heroPillOneLabel: 'Flutter',
  heroPillTwoLabel: 'Firebase',
  heroPillOneIconName: 'flutter_dash_rounded',
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
    { iconName: 'visibility_outlined', text: 'Clear scope before code' },
    { iconName: 'devices_outlined', text: 'Responsive from the start' },
    { iconName: 'speed_outlined', text: 'Small, shippable iterations' },
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
    { number: '01', iconName: 'search_rounded', label: 'Discovery' },
    { number: '02', iconName: 'auto_awesome_rounded', label: 'Design' },
    { number: '03', iconName: 'code_rounded', label: 'Development' },
    { number: '04', iconName: 'check_circle_outline_rounded', label: 'Testing' },
    { number: '05', iconName: 'rocket_launch_rounded', label: 'Launch' },
    { number: '06', iconName: 'support_agent_rounded', label: 'Support' },
  ],

  contactEyebrow: 'Contact',
  contactTitle: 'Let’s build something.',
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
  qualityStatValue: '100%',
  qualityStatLabel: 'Responsive UI focus',
  availableForHire: true,
  cvUrl: 'assets/cv/junior_flutter_cv.pdf',
  profilePhotoUrl: 'assets/images/profile.webp',
  email: 'hello@example.com',
  phone: '+251 900 000 000',
  location: 'Addis Ababa, Ethiopia',
  contractPreference: 'Freelance / contract',
  socials: {
    github: 'https://github.com/',
    linkedin: 'https://www.linkedin.com/',
    twitter: 'https://x.com/',
    stackoverflow: 'https://stackoverflow.com/',
    medium: 'https://medium.com/',
  },
};

const projects = [
  {
    id: 'starter_habit_tracker',
    title: 'HabitFlow',
    description: 'A simple habit tracker focused on fast daily check-ins, streak visibility, and a distraction-free mobile flow.',
    category: 'Mobile Apps',
    techStack: ['Flutter', 'Dart', 'SQLite', 'Riverpod'],
    imageUrl: '',
    githubUrl: 'https://github.com/',
    liveUrl: '',
    featured: true,
    published: true,
    order: 0,
  },
  {
    id: 'schoolos_dashboard',
    title: 'SchoolOS Dashboard',
    description: 'A responsive school-management dashboard concept for students, teachers, attendance, classes, and reporting.',
    category: 'Web Apps',
    techStack: ['Flutter Web', 'Firebase', 'Firestore', 'Responsive UI'],
    imageUrl: '',
    githubUrl: 'https://github.com/',
    liveUrl: '',
    featured: true,
    published: true,
    order: 1,
  },
  {
    id: 'portfolio_ui_kit',
    title: 'Portfolio UI Kit',
    description: 'Reusable Flutter UI patterns for portfolio pages, project cards, contact forms, and accessible responsive layouts.',
    category: 'UI/UX',
    techStack: ['Flutter', 'Material 3', 'Figma'],
    imageUrl: '',
    githubUrl: 'https://github.com/',
    liveUrl: '',
    featured: false,
    published: true,
    order: 2,
  },
  {
    id: 'firebase_helpers',
    title: 'Firebase Helpers',
    description: 'Small utilities for typed Firestore mapping, Firestore helpers, and consistent Firebase error handling in Flutter apps.',
    category: 'Packages',
    techStack: ['Dart', 'Firebase', 'Flutter'],
    imageUrl: '',
    githubUrl: 'https://github.com/',
    liveUrl: '',
    featured: false,
    published: true,
    order: 3,
  },
];

const services = [
  {
    id: 'flutter_mobile',
    title: 'Flutter Mobile Apps',
    description: 'Cross-platform mobile interfaces with clear navigation, state management, Firebase integration, and responsive layouts.',
    iconName: 'phone_android',
    order: 0,
  },
  {
    id: 'flutter_web',
    title: 'Flutter Web',
    description: 'Responsive Flutter Web pages for portfolios, dashboards, internal tools, and product prototypes.',
    iconName: 'web',
    order: 1,
  },
  {
    id: 'firebase_backend',
    title: 'Firebase Integration',
    description: 'Authentication, Firestore data models, Firestore data models, security rules, and practical Firebase-backed application flows.',
    iconName: 'cloud',
    order: 2,
  },
  {
    id: 'responsive_ui',
    title: 'Responsive UI',
    description: 'Material 3 UI that adapts cleanly between phone, tablet, and desktop breakpoints with accessibility in mind.',
    iconName: 'design_services',
    order: 3,
  },
];

async function seed() {
  const batch = db.batch();
  batch.set(db.collection('siteSettings').doc('public'), settings, { merge: true });

  for (const project of projects) {
    const ref = db.collection('projects').doc(project.id);
    batch.set(ref, { ...project, createdAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  }

  for (const service of services) {
    const ref = db.collection('services').doc(service.id);
    batch.set(ref, service, { merge: true });
  }

  await batch.commit();
  console.log('Seed complete: settings, projects, and services created.');
}

seed().catch((error) => {
  console.error(error);
  process.exit(1);
});
