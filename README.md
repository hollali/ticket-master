# Ticket Master (Flutter + Firebase)

A Ticketmaster-like ticketing app built with Flutter and Firebase (Auth, Firestore, Storage).

## Setup
1. Install Flutter and Firebase CLI.
2. Create a Firebase project, enable Authentication (Email/Password) and Firestore.
3. In project root, run:
   ```
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`. Replace the placeholder file.
4. Create Firestore collections:
   - `events` (fields: title, description, category, venueName, venueCity, imageUrl, startTime, endTime, status)
   - `events/{id}/tiers` (fields: name, price, quantity, available, eventId)
   - `users`, `bookings` (created by app)
5. Run:
   ```
   flutter run
   ```

## Firestore Rules (example)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /events/{e} { allow read: if true; }
    match /events/{e}/tiers/{t} { allow read: if true; allow write: if request.auth != null; }
    match /users/{u} { allow read, write: if request.auth.uid == u; }
    match /bookings/{b} { allow read, write: if request.auth.uid == resource.data.userId; }
  }
}
```
