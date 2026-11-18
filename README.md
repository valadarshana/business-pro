# Business Pro

A Flutter business-management UI prototype for orders, expenses, and dashboard
summaries.

## Project structure

- `lib/ui/screens/` contains one file per screen.
- `lib/ui/widgets/` contains shared fields, buttons, navigation, cards, and list
  components.
- `lib/theme/app_theme.dart` centralizes the color palette and shared theme.
- `lib/models/business_models.dart` defines order and expense data models.
- `lib/state/business_state.dart` owns in-memory business data, filters, and
  derived dashboard values using Flutter's `ChangeNotifier`.
- `lib/app/business_pro_app.dart` initializes and provides the shared state.

Orders and expenses can be added from their list screens. The lists, category
and status filters, and dashboard totals update from shared app state. Data is
currently held in memory and resets when the app restarts.

## Run and test

```sh
flutter pub get
flutter run
flutter test
```
