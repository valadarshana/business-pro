# Business Pro

A Flutter business-management app with Firebase Authentication and a
business-management UI.

## Project structure

- `lib/ui/screens/` contains one file per screen.
- `lib/ui/widgets/` contains shared fields, buttons, navigation, cards, and list
  components.
- `lib/theme/app_theme.dart` centralizes the color palette and shared theme.
- `lib/models/business_models.dart` defines order and expense data models.
- `lib/models/auth_user.dart` represents the authenticated account.
- `lib/services/auth_repository.dart` defines the authentication contract.
- `lib/services/firebase_auth_repository.dart` implements email and Google
  sign-in, sign-out, and creation/update of `users/{uid}` profile documents.
- `lib/services/firebase_initializer.dart` initializes Firebase for native
  platforms and accepts Firebase web configuration through compile-time values.
- `lib/data/firestore/firestore_order_queries.dart` contains the Firestore
  order queries and writes.
- `lib/data/firestore/firestore_expense_queries.dart` contains the Firestore
  expense queries and writes.
- `lib/repositories/order_repository.dart` defines the order data contract;
  `lib/repositories/firebase_order_repository.dart` scopes it to the signed-in
  Firebase user.
- `lib/repositories/expense_repository.dart` and
  `lib/repositories/firebase_expense_repository.dart` provide the same
  signed-in-user-scoped contract for expenses.
- `lib/providers/order_providers.dart` exposes the repository, live order
  stream, filters, and filtered list through Riverpod.
- `lib/providers/expense_providers.dart` exposes the live expense stream,
  category filters, and filtered list through Riverpod.
- `lib/app/business_pro_app.dart` configures the app and Riverpod providers.

Orders are stored in Firestore at `users/{uid}/orders`. The order list and
dashboard subscribe to the same Riverpod stream, so saved orders, filters,
recent orders, completed income, and pending counts update from Firestore.
Orders can be edited or deleted from the Orders list; deletion requires
confirmation. Product names are entered as free text, and order totals are
calculated from quantity and price per item; there is no amount-paid field.
Expenses are stored at `users/{uid}/expenses`; the expense list and dashboard
totals use the live Riverpod stream. Expenses can be added, edited, and deleted
from the Expenses list, with confirmation required before deletion.

## Firebase and Google sign-in setup

1. Add the Android and iOS apps to your Firebase project. Enable **Google** and,
   if using email/password sign-in, **Email/Password** in Firebase Authentication.
2. Android: use application ID `com.example.business_pro`, add the project's
   `google-services.json` under `android/app/`, and configure the Google
   Services Gradle plugin as required by Firebase.
3. iOS: add the project's `GoogleService-Info.plist` to the Runner target and
   register its `REVERSED_CLIENT_ID` as a URL scheme in the iOS app settings.
4. Register your signing certificate fingerprints with Firebase for Android.
   Supply the Google OAuth client ID for native sign-in when required:

   ```sh
   flutter run \
     --dart-define=GOOGLE_CLIENT_ID=<ios-oauth-client-id> \
     --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-oauth-client-id>
   ```

5. For web, provide the Firebase web app values at build/run time:

   ```sh
   flutter run -d chrome \
     --dart-define=FIREBASE_API_KEY=<api-key> \
     --dart-define=FIREBASE_APP_ID=<app-id> \
     --dart-define=FIREBASE_MESSAGING_SENDER_ID=<sender-id> \
     --dart-define=FIREBASE_PROJECT_ID=<project-id> \
     --dart-define=FIREBASE_AUTH_DOMAIN=<auth-domain> \
     --dart-define=FIREBASE_STORAGE_BUCKET=<storage-bucket>
   ```

   Add the development and production domains to Firebase Authentication's
   authorized domains. Firebase web configuration values are application
   identifiers, not service-account credentials; never ship a service-account
   key in the client app.

The app listens to Firebase's auth-state stream, restores an existing session,
supports email/password registration and sign-in as well as Google sign-in,
shows authentication errors, and returns to the splash screen after sign-out.
Registration creates the Firebase Auth account and initializes
`users/{uid}` with the supplied name and business name. The document ID always
comes from the authenticated Firebase UID, not UI input. If Firebase or OAuth
setup is missing, a setup error is shown instead of treating a button tap as a
successful login.

## Run and test

```sh
flutter pub get
flutter run
flutter test test/widget_test.dart
```
