class Booking {
  final String id;
  final String userId;
  final String eventId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String? eventTitle;
  final DateTime? eventStart;

  Booking({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.eventTitle,
    this.eventStart,
  });
}
