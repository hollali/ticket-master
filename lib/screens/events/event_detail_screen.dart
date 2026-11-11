import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';
import '../../models/ticket_tier.dart';
import '../../core/theme.dart';
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
  List<TicketTier> _tiers = [];

  @override
  void initState() {
    super.initState();
    _service.event(widget.eventId).then((e) => setState(() => event = e));
  }

  double get _total {
    double t = 0;
    for (final tier in _tiers) {
      t += tier.price * (_qty[tier.id] ?? 0);
    }
    return t;
  }

  int get _totalQty => _qty.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event!.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              background: event!.imageUrl != null
                  ? Image.network(event!.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder())
                  : _placeholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event!.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.location_on_outlined, text: '${event!.venueName ?? ''}, ${event!.venueCity ?? ''}'),
                  _InfoRow(icon: Icons.calendar_today_outlined, text: _formatDate(event!.startTime)),
                  if (event!.description != null && event!.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(event!.description!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 20),
                  Text('Select Tickets', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  StreamBuilder<List<TicketTier>>(
                    stream: _service.tiers(widget.eventId),
                    builder: (context, snap) {
                      final tiers = snap.data ?? [];
                      _tiers = tiers;
                      if (tiers.isEmpty) return const Text('No tickets available');
                      return Column(
                        children: tiers.map((t) => _TierCard(
                          tier: t,
                          qty: _qty[t.id] ?? 0,
                          onAdd: () => setState(() => _qty[t.id] = (_qty[t.id] ?? 0) + 1),
                          onRemove: () => setState(() {
                            final q = _qty[t.id] ?? 0;
                            if (q > 0) _qty[t.id] = q - 1;
                          }),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _totalQty == 0
                ? null
                : () {
                    final items = _qty.entries.where((e) => e.value > 0).map((e) => {'tierId': e.key, 'quantity': e.value}).toList();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutScreen(eventId: widget.eventId, items: items)));
                  },
            child: Text(_totalQty == 0 ? 'Select tickets' : 'Checkout • \$${_total.toStringAsFixed(2)}'),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(color: Colors.grey.shade300, child: const Center(child: Icon(Icons.event, size: 64, color: Colors.white)));

  String _formatDate(DateTime d) {
    final l = d.toLocal();
    return '${l.day}/${l.month}/${l.year}  ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final TicketTier tier;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _TierCard({required this.tier, required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tier.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('\$${tier.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  Text('${tier.available} available', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Row(
              children: [
                IconButton.filledTonal(onPressed: qty > 0 ? onRemove : null, icon: const Icon(Icons.remove)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton.filledTonal(onPressed: qty < tier.available ? onAdd : null, icon: const Icon(Icons.add)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
