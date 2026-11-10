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

  factory Event.fromMap(String id, Map<String, dynamic> m) => Event(
        id: id,
        title: m['title'] ?? '',
        description: m['description'],
        category: m['category'],
        venueName: m['venueName'],
        venueCity: m['venueCity'],
        imageUrl: m['imageUrl'],
        startTime: (m['startTime'] as dynamic)?.toDate() ?? DateTime.now(),
        endTime: (m['endTime'] as dynamic)?.toDate(),
        status: m['status'] ?? 'published',
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'venueName': venueName,
        'venueCity': venueCity,
        'imageUrl': imageUrl,
        'startTime': startTime,
        'endTime': endTime,
        'status': status,
      };
}
