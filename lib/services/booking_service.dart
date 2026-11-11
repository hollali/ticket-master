import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../models/ticket.dart';

class BookingService {
  final SupabaseClient _client = Supabase.instance.client;
  final _uuid = const Uuid();

  DateTime _parse(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.parse(v.toString());
  }

  Future<String> createBooking(String eventId, List<Map<String, dynamic>> items) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final event = await _client.from('events').select().eq('id', eventId).maybeSingle();

    double total = 0;
    for (final it in items) {
      final tier = await _client
          .from('ticket_tiers')
          .select()
          .eq('id', it['tierId'] as String)
          .single();
      final available = tier['available'] as int;
      final qty = it['quantity'] as int;
      if (qty <= 0 || available < qty) throw Exception('Not enough tickets');
      final price = (tier['price'] as num).toDouble();
      total += price * qty;
    }

    for (final it in items) {
      final tier = await _client
          .from('ticket_tiers')
          .select()
          .eq('id', it['tierId'] as String)
          .single();
      final available = tier['available'] as int;
      final qty = it['quantity'] as int;
      await _client
          .from('ticket_tiers')
          .update({'available': available - qty})
          .eq('id', it['tierId'] as String);
    }

    final booking = await _client
        .from('bookings')
        .insert({
          'user_id': user.id,
          'event_id': eventId,
          'status': 'confirmed',
          'total_amount': total,
          'event_title': event?['title'],
          'event_start': event?['start_time'],
        })
        .select()
        .single();

    final bookingId = booking['id'].toString();

    for (final it in items) {
      final qty = it['quantity'] as int;
      final tierId = it['tierId'] as String;
      final tier = await _client
          .from('ticket_tiers')
          .select()
          .eq('id', tierId)
          .single();
      final price = (tier['price'] as num).toDouble();
      await _client.from('booking_items').insert({
        'booking_id': bookingId,
        'tier_id': tierId,
        'quantity': qty,
        'unit_price': price,
      });
      for (int i = 0; i < qty; i++) {
        await _client.from('tickets').insert({
          'booking_id': bookingId,
          'tier_id': tierId,
          'code': _uuid.v4().substring(0, 8).toUpperCase(),
          'status': 'valid',
        });
      }
    }
    return bookingId;
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
    final res = await _client.from('tickets').select().eq('booking_id', bookingId);
    return res
        .map((m) => Ticket(
              id: m['id'].toString(),
              bookingId: bookingId,
              tierId: m['tier_id'].toString(),
              code: m['code'] ?? '',
              status: m['status'] ?? 'valid',
              tierName: m['tier_name'],
            ))
        .toList();
  }
}
