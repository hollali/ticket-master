# Ticket Master (Flutter + Supabase)

A Ticketmaster-like ticketing app built with Flutter and Supabase (Auth, Postgres, Storage).

## Setup
1. Install Flutter.
2. Create a Supabase project.
3. Run the SQL in `supabase/schema.sql` in the Supabase SQL Editor.
4. Update `lib/main.dart` with your Supabase project URL and anon (publishable) key.
5. Run:
   ```
   flutter pub get
   flutter run
   ```

## Supabase Tables
- `events` (title, description, category, venue_name, venue_city, image_url, start_time, end_time, status)
- `ticket_tiers` (event_id, name, price, quantity, available)
- `users`, `bookings`, `booking_items`, `tickets` (created by app)
