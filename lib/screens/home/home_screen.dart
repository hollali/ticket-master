import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';
import '../events/event_detail_screen.dart';
import '../tickets/my_tickets_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _service = EventService();
  String? category;
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Master'),
        actions: [
          IconButton(icon: const Icon(Icons.confirmation_number), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyTicketsScreen()))),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()))),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search events'),
              onChanged: (v) => setState(() => search = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [null, 'concert', 'sports', 'conference'].map((c) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(c ?? 'All'),
                    selected: category == c,
                    onSelected: (_) => setState(() => category = c),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _service.events(category: category, search: search),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final events = snap.data ?? [];
                if (events.isEmpty) return const Center(child: Text('No events'));
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, i) {
                    final e = events[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: e.imageUrl != null ? Image.network(e.imageUrl!, width: 60, fit: BoxFit.cover) : null,
                        title: Text(e.title),
                        subtitle: Text('${e.venueName ?? ''} • ${e.startTime.toLocal()}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: e.id))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
