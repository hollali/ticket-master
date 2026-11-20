import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';
import '../models/ticket.dart';

class BookingService {
  final SupabaseClient _client = Supabase.instance.client;

  DateTime _parse(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.parse(v.toString());
  }

  Future<String> createBooking(String eventId, List<Map<String, dynamic>> items) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final res = await _client.rpc('create_booking', params: {
      'p_event_id': eventId,
      'p_items': items,
    });
    return res.toString();
  }

  Stream<List<Booking>> myBookings() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const Stream.empty();
    return _client.from('bookings').stream(primaryKey: ['id']).map((rows) {
      final list = rows
          .where((r) => r['user_id'] == uid)
          .map((m) => Booking(
                id: m['id'].toString(),
                userId: m['user_id'].toString(),
                eventId: m['event_id'].toString(),
                status: m['status'] ?? 'pending',
                totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
                createdAt: _parse(m['created_at']),
                eventTitle: m['event_title'],
                eventStart: m['event_start'] != null ? _parse(m['event_start']) : null,
              ))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<List<Ticket>> bookingTickets(String bookingId) async {
    final res = await _client.from('tickets').select('*, ticket_tiers(name)').eq('booking_id', bookingId);
    return res
        .map((m) {
          final tier = m['ticket_tiers'];
          return Ticket(
            id: m['id'].toString(),
            bookingId: bookingId,
            tierId: m['tier_id'].toString(),
            code: m['code'] ?? '',
            status: m['status'] ?? 'valid',
            tierName: m['tier_name'] ?? (tier is Map ? tier['name']?.toString() : null),
          );
        })
        .toList();
  }
}
