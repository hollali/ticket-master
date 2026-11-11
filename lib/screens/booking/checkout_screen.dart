import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../core/theme.dart';

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

  int get _totalQty => widget.items.fold(0, (a, b) => a + (b['quantity'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.primary),
                    const SizedBox(height: 12),
                    Text('Confirm your booking', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('$_totalQty ticket(s) selected', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text(error!, style: TextStyle(color: Colors.red.shade700)),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
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
              child: loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm & Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
