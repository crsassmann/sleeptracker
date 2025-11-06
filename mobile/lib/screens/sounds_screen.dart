import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/sound_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final _service = SoundService();
  final _player = AudioPlayer();
  String? _playingId;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String id, String storagePath) async {
    final url = await _service.getDownloadUrl(storagePath);
    await _player.setUrl(url);
    await _player.play();
    setState(() => _playingId = id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.sounds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No sounds available'));
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data();
            final name = data['name'] as String? ?? doc.id;
            final storagePath = data['storagePath'] as String? ?? '';
            final isPlaying = _playingId == doc.id;
            return ListTile(
              leading: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
              title: Text(name),
              subtitle: Text(storagePath),
              onTap: storagePath.isEmpty
                  ? null
                  : () async {
                      if (isPlaying) {
                        await _player.pause();
                        setState(() => _playingId = null);
                      } else {
                        await _play(doc.id, storagePath);
                      }
                    },
            );
          },
        );
      },
    );
  }
}