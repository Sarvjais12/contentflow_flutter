import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onDelete;

  const PostCard({super.key, required this.post, required this.onDelete});

  Color _statusColor() {
    switch (post.status) {
      case 'scheduled': return Colors.orange;
      case 'posted': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _platformIcon(String platform) {
    switch (platform) {
      case 'Instagram': return Icons.camera_alt;
      case 'LinkedIn': return Icons.work;
      case 'Twitter': return Icons.alternate_email;
      default: return Icons.share;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(post.status.toUpperCase(),
                      style: TextStyle(color: _statusColor(), fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.caption, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: post.hashtags
                  .map((h) => Chip(
                        label: Text('#$h', style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...post.platforms.map((p) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(_platformIcon(p), size: 18, color: Colors.grey),
                    )),
                const Spacer(),
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(post.scheduledAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}