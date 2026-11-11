import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/ticket_tier.dart';

class EventService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Event>> events({String? category, String? search}) {
    return _client.from('events').stream(primaryKey: ['id']).map((rows) {
      var list = rows
          .where((r) => (r['status'] ?? 'published') == 'published')
          .map((r) => Event.fromMap(r['id'].toString(), r))
          .toList();
      if (category != null && category.isNotEmpty) {
        list = list.where((e) => e.category == category).toList();
      }
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        list = list
            .where((e) =>
                e.title.toLowerCase().contains(s) ||
                (e.description ?? '').toLowerCase().contains(s))
            .toList();
      }
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
      return list;
    });
  }

  Future<Event?> event(String id) async {
    final res = await _client.from('events').select().eq('id', id).maybeSingle();
    if (res == null) return null;
    return Event.fromMap(res['id'].toString(), res);
  }

  Stream<List<TicketTier>> tiers(String eventId) {
    return _client.from('ticket_tiers').stream(primaryKey: ['id']).map((rows) {
      final list = rows
          .where((r) => r['event_id'] == eventId)
          .map((r) => TicketTier.fromMap(r['id'].toString(), r))
          .toList();
      list.sort((a, b) => a.price.compareTo(b.price));
      return list;
    });
  }
}
