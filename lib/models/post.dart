import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String caption;
  final List<String> hashtags;
  final List<String> platforms;
  final DateTime scheduledAt;
  final String status;

  Post({
    required this.id,
    required this.userId,
    required this.caption,
    required this.hashtags,
    required this.platforms,
    required this.scheduledAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'caption': caption,
      'hashtags': hashtags,
      'platforms': platforms,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status,
    };
  }

  factory Post.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'],
      caption: data['caption'],
      hashtags: List<String>.from(data['hashtags']),
      platforms: List<String>.from(data['platforms']),
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      status: data['status'],
    );
  }
}