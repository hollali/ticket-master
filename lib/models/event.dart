class Event {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String? venueName;
  final String? venueCity;
  final String? imageUrl;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.venueName,
    this.venueCity,
    this.imageUrl,
    required this.startTime,
    this.endTime,
    this.status = 'published',
  });

  static DateTime _parse(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.parse(v.toString());
  }

  factory Event.fromMap(String id, Map<String, dynamic> m) => Event(
        id: id,
        title: m['title'] ?? '',
        description: m['description'],
        category: m['category'],
        venueName: m['venue_name'] ?? m['venueName'],
        venueCity: m['venue_city'] ?? m['venueCity'],
        imageUrl: m['image_url'] ?? m['imageUrl'],
        startTime: _parse(m['start_time'] ?? m['startTime']),
        endTime: (m['end_time'] ?? m['endTime']) != null
            ? _parse(m['end_time'] ?? m['endTime'])
            : null,
        status: m['status'] ?? 'published',
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'venue_name': venueName,
        'venue_city': venueCity,
        'image_url': imageUrl,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'status': status,
      };
}
