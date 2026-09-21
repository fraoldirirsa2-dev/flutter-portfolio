import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/contact_message.dart';
import '../models/project.dart';
import '../models/service_model.dart';
import '../models/site_settings.dart';

/// Firestore + Auth access for the portfolio.
///
/// This free/Spark version deliberately does not use Cloud Storage. Media is
/// served by Flutter Web/Firebase Hosting from the local assets folder or by
/// an external HTTPS URL, while editable content remains in Firestore.
class FirebaseService {
  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection('projects');

  CollectionReference<Map<String, dynamic>> get _services =>
      _firestore.collection('services');

  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection('contactMessages');

  DocumentReference<Map<String, dynamic>> get _settings =>
      _firestore.collection('siteSettings').doc('public');

  Stream<SiteSettings> watchSettings() => _settings.snapshots().map(
        (snapshot) => snapshot.exists
            ? SiteSettings.fromDocument(snapshot)
            : SiteSettings.defaults,
      );

  Future<SiteSettings> getSettings() async {
    final snapshot = await _settings.get();
    return snapshot.exists
        ? SiteSettings.fromDocument(snapshot)
        : SiteSettings.defaults;
  }

  Stream<List<Project>> watchPublishedProjects() => _projects
      .where('published', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final projects = snapshot.docs.map(Project.fromDocument).toList();
    projects.sort((a, b) => a.order.compareTo(b.order));
    return projects;
  });

  Stream<List<Project>> watchAllProjects() =>
      _projects.orderBy('order').snapshots().map(
            (snapshot) => snapshot.docs.map(Project.fromDocument).toList(),
          );

  Stream<List<ServiceModel>> watchServices() =>
      _services.orderBy('order').snapshots().map(
            (snapshot) =>
                snapshot.docs.map(ServiceModel.fromDocument).toList(),
          );

  Stream<List<ContactMessage>> watchMessages() =>
      _messages.orderBy('createdAt', descending: true).snapshots().map(
            (snapshot) => snapshot.docs
                .map(ContactMessage.fromDocument)
                .toList(),
          );

  Future<void> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'auth-failed',
          message: 'Firebase did not return a signed-in user.',
        );
      }

      final token = await user.getIdTokenResult(true);
      final isAdmin = token.claims?['admin'] == true;

      if (!isAdmin) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'not-admin',
          message:
              'Login succeeded, but this account is not authorized as an admin.',
        );
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      throw FirebaseAuthException(
        code: 'admin-login-failed',
        message: 'Admin login failed: $error',
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> createContactMessage({
    required String name,
    required String email,
    required String budget,
    required String message,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanBudget = budget.trim();
    final cleanMessage = message.trim();

    if (cleanName.length < 2) {
      throw ArgumentError('Please enter your name.');
    }
    if (cleanEmail.length < 5) {
      throw ArgumentError('Please enter a valid email address.');
    }
    if (cleanMessage.length < 5) {
      throw ArgumentError('Please enter a little more about your project.');
    }

    await _messages.add({
      'name': cleanName,
      'email': cleanEmail,
      'budget': cleanBudget,
      'message': cleanMessage,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Future<void> saveSettings(SiteSettings settings) async {
    await _requireAdmin();

    await _settings.set(
      settings.toMap(),
      SetOptions(merge: true),
    );

    final snapshot = await _settings.get();
    if (!snapshot.exists) {
      throw StateError('The settings document was not created.');
    }

    final saved = SiteSettings.fromDocument(snapshot);
    final matches =
        jsonEncode(saved.toMap()) == jsonEncode(settings.toMap());

    if (!matches) {
      throw StateError(
        'Firestore verification failed. One or more public content fields did not match the saved values.',
      );
    }
  }

  String get firebaseProjectId => Firebase.app().options.projectId;

  Future<DocumentReference<Map<String, dynamic>>> createProject(
    Map<String, dynamic> data,
  ) async {
    await _requireAdmin();
    return _projects.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProject(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _requireAdmin();
    await _projects.doc(id).update(data);
  }

  Future<void> deleteProject(Project project) async {
    await _requireAdmin();
    await _projects.doc(project.id).delete();
  }

  Future<void> createService(Map<String, dynamic> data) async {
    await _requireAdmin();
    await _services.add(data);
  }

  Future<void> updateService(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _requireAdmin();
    await _services.doc(id).update(data);
  }

  Future<void> deleteService(String id) async {
    await _requireAdmin();
    await _services.doc(id).delete();
  }

  Future<void> setProjectOrder(List<Project> projects) async {
    await _requireAdmin();
    final batch = _firestore.batch();
    for (var index = 0; index < projects.length; index++) {
      batch.update(
        _projects.doc(projects[index].id),
        {'order': index},
      );
    }
    await batch.commit();
  }

  Future<void> setServiceOrder(
    List<ServiceModel> services,
  ) async {
    await _requireAdmin();
    final batch = _firestore.batch();
    for (var index = 0; index < services.length; index++) {
      batch.update(
        _services.doc(services[index].id),
        {'order': index},
      );
    }
    await batch.commit();
  }

  Future<void> updateMessageRead(
    String id,
    bool read,
  ) async {
    await _requireAdmin();
    await _messages.doc(id).update({'read': read});
  }

  Future<void> deleteMessage(String id) async {
    await _requireAdmin();
    await _messages.doc(id).delete();
  }

  Future<void> _requireAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'You must be signed in as an administrator.',
      );
    }

    final token = await user.getIdTokenResult(true);
    if (token.claims?['admin'] != true) {
      throw FirebaseAuthException(
        code: 'not-admin',
        message: 'Your account is not authorized as an administrator.',
      );
    }
  }
}
