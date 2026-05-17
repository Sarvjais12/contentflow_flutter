import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Post>> getUserPosts(String userId) {
    return _db
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromDoc(doc)).toList());
  }

  Future<void> addPost(Post post) async {
    try {
      await _db.collection('posts').add(post.toMap());
      print('Post added successfully');
    } catch (e) {
      print('Firestore error: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  Future<void> updateStatus(String postId, String status) async {
    await _db.collection('posts').doc(postId).update({'status': status});
  }
}
