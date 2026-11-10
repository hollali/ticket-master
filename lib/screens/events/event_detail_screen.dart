import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';
import '../../models/ticket_tier.dart';
import '../booking/checkout_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _service = EventService();
  Event? event;
  final Map<String, int> _qty = {};

  @override
  void initState() {
    super.initState();
    _service.event(widget.eventId).then((e) => setState(() => event = e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event?.title ?? 'Event')),
      body: event == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (event!.imageUrl != null) Image.network(event!.imageUrl!),
                const SizedBox(height: 8),
                Text(event!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('${event!.venueName ?? ''}, ${event!.venueCity ?? ''}'),
                Text(event!.startTime.toLocal().toString()),
                const SizedBox(height: 8),
                Text(event!.description ?? ''),
                const SizedBox(height: 16),
                const Text('Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                StreamBuilder<List<TicketTier>>(
                  stream: _service.tiers(widget.eventId),
                  builder: (context, snap) {
                    final tiers = snap.data ?? [];
                    return Column(
                      children: tiers.map((t) {
                        final q = _qty[t.id] ?? 0;
                        return ListTile(
                          title: Text(t.name),
                          subtitle: Text('\$${t.price.toStringAsFixed(2)} • ${t.available} available'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.remove), onPressed: q > 0 ? () => setState(() => _qty[t.id] = q - 1) : null),
                              Text('$q'),
                              IconButton(icon: const Icon(Icons.add), onPressed: q < t.available ? () => setState(() => _qty[t.id] = q + 1) : null),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final items = _qty.entries.where((e) => e.value > 0).map((e) => {'tierId': e.key, 'quantity': e.value}).toList();
                    if (items.isEmpty) return;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutScreen(eventId: widget.eventId, items: items)));
                  },
                  child: const Text('Proceed to Checkout'),
                ),
              ],
            ),
    );
  }
}
