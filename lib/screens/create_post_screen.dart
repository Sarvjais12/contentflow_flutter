import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/post.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _hashtagController = TextEditingController();
  final List<String> _selectedPlatforms = [];
  final List<String> _hashtags = [];
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  bool _loading = false;

  final List<String> _platforms = ['Instagram', 'LinkedIn', 'Twitter'];
  final _platformLimits = {'Instagram': 2200, 'LinkedIn': 3000, 'Twitter': 280};

  int get _charLimit {
    if (_selectedPlatforms.isEmpty) return 9999;
    return _selectedPlatforms
        .map((p) => _platformLimits[p]!)
        .reduce((a, b) => a < b ? a : b);
  }

  void _addHashtag() {
    final tag = _hashtagController.text.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_hashtags.contains(tag)) {
      setState(() => _hashtags.add(tag));
      _hashtagController.clear();
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_captionController.text.trim().isEmpty) return;
    if (_selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one platform')));
      return;
    }
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final post = Post(
      id: const Uuid().v4(),
      userId: auth.user!.uid,
      caption: _captionController.text.trim(),
      hashtags: _hashtags,
      platforms: _selectedPlatforms,
      scheduledAt: _scheduledAt,
      status: 'scheduled',
    );
    await FirestoreService().addPost(post);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final captionLength = _captionController.text.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Post'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('POST', style: TextStyle(color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platforms', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _platforms.map((p) {
                final selected = _selectedPlatforms.contains(p);
                return FilterChip(
                  label: Text(p),
                  selected: selected,
                  onSelected: (val) => setState(() {
                    val ? _selectedPlatforms.add(p) : _selectedPlatforms.remove(p);
                  }),
                  selectedColor: const Color(0xFF6C63FF).withOpacity(0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Caption', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              maxLines: 6,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Write your caption...',
                border: const OutlineInputBorder(),
                counterText: '$captionLength / $_charLimit',
                errorText: captionLength > _charLimit ? 'Exceeds platform limit' : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Hashtags', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hashtagController,
                    decoration: const InputDecoration(
                      hintText: 'Add hashtag',
                      border: OutlineInputBorder(),
                      prefixText: '# ',
                    ),
                    onSubmitted: (_) => _addHashtag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addHashtag,
                  icon: const Icon(Icons.add_circle, color: Color(0xFF6C63FF), size: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: _hashtags.map((h) => Chip(
                label: Text('#$h'),
                onDeleted: () => setState(() => _hashtags.remove(h)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Schedule Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[700]!)),
              leading: const Icon(Icons.schedule, color: Color(0xFF6C63FF)),
              title: Text('${_scheduledAt.day}/${_scheduledAt.month}/${_scheduledAt.year}'
                  ' at ${_scheduledAt.hour}:${_scheduledAt.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.edit),
              onTap: _pickDateTime,
            ),
          ],
        ),
      ),
    );
  }
}