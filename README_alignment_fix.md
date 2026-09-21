# Navbar alignment fix

Replaced `lib/widgets/app_navbar.dart` with a strict centered-row layout. Also changed the fallback profile name in `lib/models/site_settings.dart` to `Fraol Dirirsa` while keeping Firestore/admin editing support.

Run locally:

```powershell
flutter clean
flutter pub get
dart format lib
flutter analyze
flutter run -d chrome
```

The navbar uses fixed 44px control boxes for the brand, About, Projects, Services, Let's talk, and theme/menu controls so they share one vertical alignment baseline.
