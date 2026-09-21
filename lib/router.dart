import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_messages_screen.dart';
import 'screens/admin/admin_overview_screen.dart';
import 'screens/admin/admin_projects_screen.dart';
import 'screens/admin/admin_services_screen.dart';
import 'screens/admin/admin_settings_screen.dart';
import 'screens/public/home_screen.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(Stream<User?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter() {
  final authRefresh = AuthRouterRefresh(FirebaseAuth.instance.idTokenChanges());
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final isAdminArea = state.matchedLocation.startsWith('/admin');
      final isLogin = state.matchedLocation == '/admin/login';
      final user = FirebaseAuth.instance.currentUser;

      if (isAdminArea && !isLogin && user == null) {
        return '/admin/login';
      }
      if (isLogin && user != null) {
        return '/admin';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminOverviewScreen(),
      ),
      GoRoute(
        path: '/admin/projects',
        name: 'admin-projects',
        builder: (context, state) => const AdminProjectsScreen(),
      ),
      GoRoute(
        path: '/admin/services',
        name: 'admin-services',
        builder: (context, state) => const AdminServicesScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin-settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/messages',
        name: 'admin-messages',
        builder: (context, state) => const AdminMessagesScreen(),
      ),
    ],
  );
}
