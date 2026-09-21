import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;

import 'models/contact_message.dart';
import 'models/project.dart';
import 'models/service_model.dart';
import 'models/site_settings.dart';
import 'services/firebase_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final siteSettingsProvider = StreamProvider<SiteSettings>((ref) {
  return ref.watch(firebaseServiceProvider).watchSettings();
});

final publishedProjectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(firebaseServiceProvider).watchPublishedProjects();
});

final allProjectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(firebaseServiceProvider).watchAllProjects();
});

final servicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  return ref.watch(firebaseServiceProvider).watchServices();
});

final messagesProvider = StreamProvider<List<ContactMessage>>((ref) {
  return ref.watch(firebaseServiceProvider).watchMessages();
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
