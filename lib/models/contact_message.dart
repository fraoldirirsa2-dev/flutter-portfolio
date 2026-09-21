import 'package:cloud_firestore/cloud_firestore.dart';

class ContactMessage {
  const ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    required this.budget,
    required this.message,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final String name;
  final String email;
  final String budget;
  final String message;
  final DateTime createdAt;
  final bool read;

  factory ContactMessage.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    return ContactMessage(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      budget: data['budget'] as String? ?? '',
      message: data['message'] as String? ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }
}
