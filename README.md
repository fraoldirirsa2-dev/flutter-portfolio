# Junior Flutter Developer Portfolio — Free Firebase Spark Architecture

A responsive Flutter Web portfolio with a Firebase-backed CMS that intentionally avoids Cloud Storage so the project can stay on a Firebase Spark/free-plan setup.

## What this version uses

- Flutter Web + Material 3
- Firebase Authentication for the protected admin login
- Cloud Firestore for projects, services, settings, and contact messages
- Firebase Hosting for the web app and static assets
- Riverpod 3
- go_router
- Liquid Glass + glassmorphism + restrained neumorphism
- Responsive mobile/tablet/desktop UI
- Dark/light mode
- Scroll reveal, floating motion, press feedback, horizontal rails
- Continuous Tech Stack auto-scroll with touch/mouse/trackpad interaction
- Public contact form with Firestore create-only rules

## What was removed to stay free

This version does **not** depend on Firebase Storage or `file_picker`.

The following media is served as Flutter Web assets or public HTTPS URLs:

- Profile photo
- Project images
- CV PDF

The Admin dashboard edits the **path/URL** stored in Firestore. It does not upload bytes to Firebase Storage.

### Media flow

```text
Flutter project assets / public HTTPS URL
                 ↓
             Firebase Hosting
                 ↓
          Public portfolio
                 ↑
      Firestore stores the path/URL
                 ↑
          Admin edits the URL
```

This means you can stay on the Spark plan for this portfolio. You still need to follow Firebase's applicable free quotas and product terms.

## Project structure

```text
lib/
  main.dart
  router.dart
  theme.dart
  providers.dart
  firebase_options.dart        # generated locally by FlutterFire
  models/
  services/
    firebase_service.dart
  screens/
    public/
      home_screen.dart
    admin/
      admin_login_screen.dart
      admin_overview_screen.dart
      admin_projects_screen.dart
      admin_services_screen.dart
      admin_settings_screen.dart
      admin_messages_screen.dart
  widgets/
    admin_scaffold.dart
    app_navbar.dart
    footer.dart
    liquid_glass_foundation.dart
    motion_foundation.dart
    portfolio_media.dart
    project_card.dart
    responsive.dart
    section_title.dart
    service_card.dart
assets/
  images/
  cv/
web/
  index.html
  manifest.json
  robots.txt
firestore.rules
firebase.json
firestore.indexes.json
scripts/
  seed.js
  set_admin_claim.js
  package.json
```

## 1. Configure Firebase

From the Flutter project root:

```powershell
flutterfire configure --project=website-portfolio-65d8a --platforms=web
```

This generates:

```text
lib/firebase_options.dart
```

Do not commit private service-account credentials.

## 2. Enable Firebase services

In Firebase Console for `website-portfolio-65d8a`:

1. Authentication → enable Email/Password.
2. Firestore Database → create the default database.
3. Hosting → use Firebase Hosting for production deployment.

**Do not enable Cloud Storage for this free version.**

## 3. Deploy Firestore rules

From the project root:

```powershell
firebase use website-portfolio-65d8a
firebase deploy --only firestore:rules
```

The rules allow:

- Public read of `siteSettings/public`.
- Public read of published projects only.
- Public read of services.
- Public creation of validated contact messages.
- Admin-only project/service/settings/message writes.

## 4. Create the admin user

Firebase Console → Authentication → Users → Add user.

Create the email/password account you will use for the dashboard.

Then set the `admin: true` custom claim from your trusted local Node environment:

```powershell
cd scripts
npm install
cd ..

$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\portfolio-admin.json"
node scripts/set_admin_claim.js YOUR_FIREBASE_AUTH_UID
```

The service-account JSON must be private and must not be committed to Git.

## 5. Seed starter data

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\portfolio-admin.json"
node scripts/seed.js
```

The sample values are intentionally modest and should be replaced with your real information.

## 6. Add your own media without Firebase Storage

### Profile photo

Place the image inside:

```text
assets/images/profile.webp
```

Then in:

```text
Admin → Settings
```

set:

```text
Profile photo path or HTTPS URL
assets/images/profile.webp
```

### Project image

Place images such as:

```text
assets/images/project_01.webp
assets/images/project_02.webp
```

Then in:

```text
Admin → Projects → Edit
```

set the image path:

```text
assets/images/project_01.webp
```

### CV

Place your PDF in:

```text
assets/cv/junior_flutter_cv.pdf
```

Then in:

```text
Admin → Settings
```

set:

```text
CV path or HTTPS URL
assets/cv/junior_flutter_cv.pdf
```

The public CV button resolves relative hosted paths automatically.

## 7. Run locally

```powershell
flutter clean
flutter pub get
dart format lib
flutter analyze
flutter run -d chrome
```

The target local URL will look like:

```text
http://localhost:xxxxx/
```

Admin:

```text
http://localhost:xxxxx/admin/login
```

## 8. Test the CMS

### Settings

Change:

- Name
- Role
- Hero title/subtitle
- About
- Years experience
- Projects shipped
- Available for hire
- Email
- Phone
- Location
- Social links
- Profile photo path/URL
- CV path/URL

Save and verify the `siteSettings/public` document in Firestore.

The public site uses a realtime Firestore stream, so updated values appear without rebuilding the app.

### Projects

Admin supports:

- Create
- Edit
- Delete
- Publish/unpublish
- Feature/unfeature
- Reorder
- Image path/URL

### Services

Admin supports:

- Create
- Edit
- Delete
- Reorder

### Messages

Visitors can submit contact forms publicly. Admin users can:

- View messages
- Mark read/unread
- Delete messages

## 9. Firebase Hosting deployment

Build:

```powershell
flutter build web --release
```

Then deploy:

```powershell
firebase deploy --only hosting
```

Because the Flutter build includes the files under `assets/`, your profile image, project images, and CV are hosted with the website without Firebase Storage.

## Important limitation of the free setup

The Admin dashboard can edit media **paths/URLs**, but it cannot upload binary files to Firebase because Cloud Storage has intentionally been removed from this version.

When you replace an asset locally, run a new Flutter Web build before deploying Hosting.

## Default junior profile

```text
Role: Junior Flutter Developer
yearsExperience: 1
projectsShipped: 4
availableForHire: true
```

These remain editable in Admin → Settings.


## 100% Admin Content Control

The public site reads its marketing/content configuration from `siteSettings/public`. The protected Admin → Settings & Content screen controls:

- Identity: name, role, brand prefix, navbar labels, CTA label.
- Hero: title, subtitle, primary/secondary CTA, CV label, availability label, floating pill labels/icons, trust items, code strip.
- Stats: years experience, projects shipped, all stat labels, availability values/labels, available-for-hire switch.
- About: eyebrow, title, subtitle, body, skills title/list, core stack title/list, working-style title/items.
- Projects section: eyebrow, title, subtitle, featured label, published note, filter categories, and section visibility.
- Services/process: eyebrow, title, subtitle, `How I work` title, six-step process labels/icons/numbers, and section visibility.
- Contact: eyebrow, title, subtitle, contact card copy, every form label/hint/button/success string, contact details, social links.
- Media paths: profile image and CV asset/URL paths (Spark/free setup; no Firebase Storage).
- Motion: enable/disable the automatic tech-stack marquee and change its loop duration.
- Visibility: independently show/hide hero, tech stack, About, Skills, Core stack, Working style, Projects, Featured projects, Services, How I work, Contact, and Footer.
- SEO: SEO title, description, and keywords.

Save uses the authenticated admin account, writes to Firestore, reads the document back, and verifies the complete serialized settings payload before reporting success.
