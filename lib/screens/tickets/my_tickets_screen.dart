import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/booking.dart';

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
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final bookings = snap.data ?? [];
          if (bookings.isEmpty) return const Center(child: Text('No bookings'));
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, i) {
              final b = bookings[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(b.eventTitle ?? 'Booking ${b.id.substring(0, 8)}'),
                  subtitle: Text('Status: ${b.status} • Total: \$${b.totalAmount.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () async {
                      final tickets = await service.bookingTickets(b.id);
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Tickets'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: tickets.map((t) => Text('${t.tierName ?? ''} - ${t.code}')).toList(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
