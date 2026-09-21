import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.order,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final int order;

  factory ServiceModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ServiceModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'code',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}
