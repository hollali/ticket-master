class Ticket {
  final String id;
  final String bookingId;
  final String tierId;
  final String code;
  final String status;
  final String? tierName;

  Ticket({
    required this.id,
    required this.bookingId,
    required this.tierId,
    required this.code,
    required this.status,
    this.tierName,
  });
}
