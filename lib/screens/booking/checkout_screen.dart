import 'package:flutter/material.dart';
import '../../services/booking_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String eventId;
  final List<Map<String, dynamic>> items;
  const CheckoutScreen({super.key, required this.eventId, required this.items});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final BookingService _service = BookingService();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Confirm your booking'),
            const SizedBox(height: 16),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: loading ? null : () async {
                setState(() { loading = true; error = null; });
                try {
                  final id = await _service.createBooking(widget.eventId, widget.items);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking confirmed: $id')));
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                } catch (e) {
                  setState(() => error = e.toString());
                } finally {
                  setState(() => loading = false);
                }
              },
              child: loading ? const CircularProgressIndicator() : const Text('Confirm & Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
