import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.techStack,
    required this.imageUrl,
    required this.githubUrl,
    required this.liveUrl,
    required this.featured,
    required this.published,
    required this.order,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> techStack;
  final String imageUrl;
  final String githubUrl;
  final String liveUrl;
  final bool featured;
  final bool published;
  final int order;
  final DateTime createdAt;

  factory Project.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Project(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Mobile Apps',
      techStack: List<String>.from(data['techStack'] ?? const <String>[]),
      imageUrl: data['imageUrl'] as String? ?? '',
      githubUrl: data['githubUrl'] as String? ?? '',
      liveUrl: data['liveUrl'] as String? ?? '',
      featured: data['featured'] as bool? ?? false,
      published: data['published'] as bool? ?? false,
      order: (data['order'] as num?)?.toInt() ?? 0,
      createdAt: _readDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'title': title,
        'description': description,
        'category': category,
        'techStack': techStack,
        'imageUrl': imageUrl,
        'githubUrl': githubUrl,
        'liveUrl': liveUrl,
        'featured': featured,
        'published': published,
        'order': order,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
