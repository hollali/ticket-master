import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../models/ticket.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  Future<String> createBooking(String eventId, List<Map<String, dynamic>> items) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final bookingRef = _db.collection('bookings').doc();
    await _db.runTransaction((tx) async {
      double total = 0;
      final tierUpdates = <String, int>{};
      for (final it in items) {
        final tierRef = _db.collection('events').doc(eventId).collection('tiers').doc(it['tierId'] as String);
        final snap = await tx.get(tierRef);
        if (!snap.exists) throw Exception('Tier not found');
        final data = snap.data()!;
        final available = data['available'] as int;
        final qty = it['quantity'] as int;
        if (qty <= 0 || available < qty) throw Exception('Not enough tickets');
        final price = (data['price'] as num).toDouble();
        total += price * qty;
        tierUpdates[tierRef.id] = available - qty;
      }
      // apply tier updates
      for (final it in items) {
        final tierRef = _db.collection('events').doc(eventId).collection('tiers').doc(it['tierId'] as String);
        final snap = await tx.get(tierRef);
        final available = snap.data()!['available'] as int;
        final qty = it['quantity'] as int;
        tx.update(tierRef, {'available': available - qty});
      }
      tx.set(bookingRef, {
        'userId': user.uid,
        'eventId': eventId,
        'status': 'confirmed',
        'totalAmount': total,
        'createdAt': FieldValue.serverTimestamp(),
      });
      for (final it in items) {
        final qty = it['quantity'] as int;
        final tierId = it['tierId'] as String;
        final tierSnap = await _db.collection('events').doc(eventId).collection('tiers').doc(tierId).get();
        final price = (tierSnap.data()!['price'] as num).toDouble();
        final itemRef = bookingRef.collection('items').doc();
        tx.set(itemRef, {
          'tierId': tierId,
          'quantity': qty,
          'unitPrice': price,
        });
        for (int i = 0; i < qty; i++) {
          final ticketRef = bookingRef.collection('tickets').doc();
          tx.set(ticketRef, {
            'tierId': tierId,
            'code': _uuid.v4().substring(0, 8).toUpperCase(),
            'status': 'valid',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
    return bookingRef.id;
  }

  Stream<List<Booking>> myBookings() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('bookings').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true)
        .snapshots().map((s) => s.docs.map((d) {
      final m = d.data();
      return Booking(
        id: d.id,
        userId: m['userId'],
        eventId: m['eventId'],
        status: m['status'] ?? 'pending',
        totalAmount: (m['totalAmount'] as num?)?.toDouble() ?? 0,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        eventTitle: m['eventTitle'],
        eventStart: (m['eventStart'] as Timestamp?)?.toDate(),
      );
    }).toList());
  }

  Future<List<Ticket>> bookingTickets(String bookingId) async {
    final snap = await _db.collection('bookings').doc(bookingId).collection('tickets').get();
    return snap.docs.map((d) {
      final m = d.data();
      return Ticket(
        id: d.id,
        bookingId: bookingId,
        tierId: m['tierId'],
        code: m['code'],
        status: m['status'] ?? 'valid',
        tierName: m['tierName'],
      );
    }).toList();
  }
}
