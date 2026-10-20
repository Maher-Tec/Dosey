# Dosey

Dosey is a Flutter app for keeping a local list of medicines, their user-entered dose labels and intervals, and a record of doses marked as given. It schedules one local reminder for each medicine's next due time and offers French interface text with optional Tunisian Derja wording.

> **Reminder only, not medical advice. Always follow the label and your doctor.**

## Contents

- [Features](#features)
- [Screens and use flow](#screens-and-use-flow)
- [Architecture and state management](#architecture-and-state-management)
- [Dose timing and validation](#dose-timing-and-validation)
- [Reminders and platform behavior](#reminders-and-platform-behavior)
- [Privacy and data storage](#privacy-and-data-storage)
- [Localization](#localization)
- [Demo data for recordings](#demo-data-for-recordings)
- [Project structure](#project-structure)
- [Dependencies](#dependencies)
- [Run, analyze, and test](#run-analyze-and-test)
- [Known limitations](#known-limitations)
- [License](#license)

## Features

- Add medicines with a name, free-text dose label, interval in hours, emoji and color.
- Edit medicine details and delete a medicine after confirmation.
- Record a dose and show the next due time for that medicine.
- See upcoming/overdue status for each medicine independently.
- Review a dose history. History rows keep snapshots of the medicine name and dose label as they were when recorded.
- Edit a child profile label and choose whether reminder text uses Tunisian Derja.
- Schedule local notifications on Android and iOS.

This app stores user-entered information. It does not provide a medicine catalog, calculate a prescribed dose, or confirm that a treatment schedule is medically appropriate.

## Screens and use flow

The app has three main sections:

- **Home:** medicine cards, each with its own dose label, interval, next-dose time/countdown, and actions.
- **History:** recorded dose events, newest first.
- **Settings:** editable child label, Derja reminder wording toggle, notification permission controls, and the safety disclaimer.

### Add a medicine

The add sheet collects a medicine name, free-text dose label, interval (1–24 hours), icon and color. The user can optionally mark it as already given. If so, the app sets that time as the medicine's last-given time and adds an initial history row. Otherwise, no next-dose time exists until the first dose is recorded.

### Record a dose

On the medicine card/detail flow, the user records the dose as given now. The app rejects a timestamp in the future and rejects a dose before that medicine's calculated due time. On success, it updates that medicine's last-given time, prepends a history entry, saves both lists, and schedules that medicine's next reminder. If the save fails, in-memory state is rolled back and the operation reports an error.

### Calculate the next dose

For a medicine with a recorded last dose, the calculation is:

`nextDoseAt = lastGivenAt + intervalHours`

The next reminder is based on the actual time the dose is logged, not an independent fixed wall-clock schedule. If a dose is logged late, subsequent times move forward from that later time. Each medicine has its own calculation and notification ID.

Editing a medicine reconciles its existing notification and schedules the new next time if it remains in the future. Deleting a medicine removes its dose history and attempts to cancel its notification.

## Architecture and state management

The app uses a small feature-oriented structure and Flutter's built-in `ChangeNotifier` state model. It does not use Provider, Riverpod, BLoC, Redux, or another state-management package.

- `DoseReminderController` is the application state holder. It loads medicines, dose history, child label, Derja preference and notification state. It exposes read-only list views and commands for mutations.
- Screens subscribe with Flutter's `ListenableBuilder`. The controller calls `notifyListeners()` after state changes so the relevant UI rebuilds.
- The controller depends on `MedicineStorage` and `MedicineNotifications` interfaces. This keeps persistence and platform notification operations outside the screen widgets and allows controller logic to be tested with fakes.
- `Medicine` and `Dose` are domain models with JSON conversion. A `Dose` stores snapshots of display fields so later medicine edits do not rewrite existing history.
- `LocalStorageService` implements persistence with SharedPreferences. `NotificationService` wraps the local notification plugin and timezone setup.

State changes are generally optimistic: the controller updates its in-memory collections, attempts to persist, and restores the prior state when persistence fails. Notification scheduling follows a successful save; a reminder scheduling failure is reported separately because the dose record can still be saved.

## Dose timing and validation

- The interval input is bounded by the add/edit UI to 1–24 hours.
- The controller rejects future dose timestamps and rejects an entry earlier than the current calculated due time.
- This is a basic logging guard, not a complete duplicate-dose or treatment safety system. The app does not know prescription instructions and cannot determine whether a dose should be taken.
- A late dose shifts the next due time because the next interval begins at the logged time.
- Deleting a medicine also deletes its associated history from the app.

## Reminders and platform behavior

The app uses `flutter_local_notifications` with `timezone` and `flutter_timezone`. Reminders are local notifications; there is no push-notification server.

- The app schedules one next-dose reminder per medicine. A newly logged dose replaces that medicine's previous scheduled reminder.
- On Android, the scheduler uses `exactAllowWhileIdle` when Android reports exact-alarm scheduling is available; otherwise it falls back to `inexactAllowWhileIdle`. Inexact alarms can arrive late.
- Notification permission is requested from the app's Settings flow. If notifications are disabled, the app cannot deliver reminders.
- On app startup, stored medicines are loaded, old notification IDs are cancelled, and future reminders are scheduled again.
- The app refreshes its timezone and reconciles reminders when it detects a system time/timezone change and when the app resumes.
- Android manifest receivers support reboot and package-replacement restoration through the notification plugin. Actual delivery still depends on OS permission and device power-management behavior.
- Battery optimization, background restrictions, Do Not Disturb, vendor-specific Android behavior, and permission state can delay or suppress delivery. The app cannot guarantee an exact delivery time.

The implementation has been exercised in a demo on a Samsung Galaxy S22, but exact-alarm availability and delivery across reboot/timezone changes have not been exhaustively verified. iOS delivery has not been verified on a physical iPhone.

## Privacy and data storage

- **Storage:** SharedPreferences on the device, as JSON strings under `medicines_v1` and `doses_v1`; preferences use `derja_enabled` and `child_name`.
- **Encryption:** these records are **stored unencrypted**. Do not use this app as a secure medical record.
- **Network:** the application has no account, backend, analytics or sync feature, and its app logic does not send medicine records to a server. Platform services may still manage notifications and device backups according to OS settings.
- **Notifications:** notification content can include medicine and dose text and is handled by the local operating system notification service.
- **Backup:** Android app-data backup is disabled in the app manifest. iOS backup behavior is controlled by the operating system and device/user settings.
- **Removal:** uninstalling the app normally removes its local app data, subject to platform behavior and backups.

## Localization

Most interface copy is in French. A Settings toggle controls optional Tunisian Derja wording in reminder notifications. The child label is editable; its neutral default is `votre enfant`. The toggle affects generated reminder title/body text, not all interface labels.

## Project structure

```text
lib/
├── app.dart
├── main.dart
├── core/
│   └── theme/app_theme.dart
└── features/medicines/
    ├── application/
    │   └── dose_reminder_controller.dart
    ├── data/
    │   ├── local_storage_service.dart
    │   ├── notification_messages.dart
    │   └── notification_service.dart
    ├── domain/
    │   ├── dose.dart
    │   └── medicine.dart
    └── presentation/
        ├── screens/
        │   ├── app_shell.dart
        │   ├── history_screen.dart
        │   ├── home_screen.dart
        │   └── settings_screen.dart
        └── widgets/
            ├── add_medicine_sheet.dart
            ├── dose_recorded_dialog.dart
            ├── doudou_mascot.dart
            ├── edit_child_profile_dialog.dart
            ├── edit_medicine_sheet.dart
            ├── medicine_card.dart
            └── medicine_detail_sheet.dart

test/
├── controller_logic_test.dart
├── medicine_serialization_test.dart
├── notification_messages_test.dart
└── widget_test.dart
```

## Dependencies

Versions are declared in `pubspec.yaml`.

| Package | Purpose |
| --- | --- |
| `shared_preferences` | Local preference and JSON-string persistence |
| `flutter_local_notifications` | Scheduled local notifications and permission checks |
| `timezone` | Timezone-aware notification schedule values |
| `flutter_timezone` | Read the device's current timezone |
| `cupertino_icons` | Cupertino icon font |
| `flutter_test` | Flutter unit and widget tests |
| `flutter_lints` | Dart/Flutter lint rules |
| `flutter_launcher_icons` | Generate launcher icons |

The package requires a Flutter SDK whose Dart SDK satisfies `^3.10.8`.

## Run, analyze, and test

Install dependencies and run the app:

```sh
flutter pub get
flutter run
```

Run static analysis and the test suite:

```sh
flutter analyze
flutter test
```

Build an Android debug APK:

```sh
flutter build apk --debug
```

## Known limitations

- Notifications are best-effort OS schedules and can be delayed or blocked; exact Android alarm access may be unavailable.
- The app schedules only the next reminder per medicine and computes the following one after a dose is recorded.
- No cloud sync, multi-device sharing, medicine interaction checks, dose calculator, adherence export, or secure medical-data storage is implemented.
- State is stored in SharedPreferences rather than a database; large histories may eventually need a database and migration strategy.
- Notification restoration and timing depend on Android/iOS platform behavior. Test on each target OS and device before relying on reminders.
- Before a public release, review the platform application identifiers and store metadata for the intended project owner and package name.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for the full license text.

Copyright (c) 2026 Maher Ahmed.
