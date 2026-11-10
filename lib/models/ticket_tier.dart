class TicketTier {
  final String id;
  final String eventId;
  final String name;
  final double price;
  final int quantity;
  final int available;

  TicketTier({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.available,
  });

  factory TicketTier.fromMap(String id, Map<String, dynamic> m) => TicketTier(
        id: id,
        eventId: m['eventId'] ?? '',
        name: m['name'] ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0,
        quantity: m['quantity'] ?? 0,
        available: m['available'] ?? 0,
      );
}
