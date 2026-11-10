import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/ticket_tier.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Event>> events({String? category, String? search}) {
    Query q = _db.collection('events').where('status', isEqualTo: 'published').orderBy('startTime');
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    return q.snapshots().map((snap) {
      var list = snap.docs.map((d) => Event.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        list = list.where((e) => e.title.toLowerCase().contains(s) || (e.description ?? '').toLowerCase().contains(s)).toList();
      }
      return list;
    });
  }

  Future<Event?> event(String id) async {
    final doc = await _db.collection('events').doc(id).get();
    if (!doc.exists) return null;
    return Event.fromMap(doc.id, doc.data()!);
  }

  Stream<List<TicketTier>> tiers(String eventId) {
    return _db.collection('events').doc(eventId).collection('tiers').orderBy('price')
        .snapshots().map((s) => s.docs.map((d) => TicketTier.fromMap(d.id, {...d.data(), 'eventId': eventId})).toList());
  }
}
