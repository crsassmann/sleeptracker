import 'package:flutter/material.dart';
import '../services/sleep_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final _service = SleepService();
  String? _activeSessionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          _activeSessionId == null ? 'No active session' : 'Session running...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
              onPressed: _activeSessionId == null
                  ? () async {
                      final id = await _service.startSession();
                      setState(() => _activeSessionId = id);
                    }
                  : null,
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              onPressed: _activeSessionId != null
                  ? () async {
                      await _service.stopSession(_activeSessionId!);
                      setState(() => _activeSessionId = null);
                    }
                  : null,
            ),
          ],
        ),
        const Divider(height: 32),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _service.mySessions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No sessions yet'));
              return ListView.separated(
                itemBuilder: (_, i) {
                  final d = docs[i].data();
                  final start = d['startTime']?.toDate();
                  final end = d['endTime']?.toDate();
                  return ListTile(
                    leading: const Icon(Icons.nights_stay),
                    title: Text(start != null ? start.toLocal().toString() : 'Unknown start'),
                    subtitle: Text(end != null ? 'Ended: ${end.toLocal()}' : 'Active'),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: docs.length,
              );
            },
          ),
        ),
      ],
    );
  }
}