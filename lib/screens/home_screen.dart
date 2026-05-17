import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ContentFlow', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: firestore.getUserPosts(auth.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No posts yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Tap + to schedule your first post',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          final posts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) => PostCard(
              post: posts[index],
              onDelete: () => firestore.deletePost(posts[index].id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Post', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}