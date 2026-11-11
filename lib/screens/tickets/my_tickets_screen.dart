import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/booking.dart';
import '../../core/theme.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = BookingService();
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: StreamBuilder<List<Booking>>(
        stream: service.myBookings(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snap.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No bookings yet'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, i) {
              final b = bookings[i];
              return _TicketCard(booking: b, service: service);
            },
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Booking booking;
  final BookingService service;
  const _TicketCard({required this.booking, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.event, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.eventTitle ?? 'Booking', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                      Text(_formatDate(booking.createdAt), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                _StatusChip(status: booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: \$${booking.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text('View codes'),
                  onPressed: () async {
                    final tickets = await service.bookingTickets(booking.id);
                    if (context.mounted) {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Ticket Codes', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 12),
                              ...tickets.map((t) => ListTile(
                                    leading: const Icon(Icons.confirmation_number_outlined),
                                    title: Text(t.code),
                                    subtitle: Text(t.tierName ?? ''),
                                    trailing: Text(t.status),
                                  )),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final l = d.toLocal();
    return '${l.day}/${l.month}/${l.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'confirmed' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color.shade700, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
