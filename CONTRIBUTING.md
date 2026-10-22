# Contributing to Dosey

Thanks for considering a contribution. Dosey is a small, local-first Flutter medicine reminder and dose log. Contributions should keep its privacy and safety limits clear.

## Before you start

- Check the existing issues and pull requests to avoid duplicate work.
- For a large change, open an issue first to discuss the approach.
- Do not include real names, medicine records, photos, device identifiers, or other personal information in code, tests, screenshots, or sample data. Use clearly fictional examples.
- Do not describe Dosey as a medical device or imply that it recommends or validates treatment.

## Set up the project

Install Flutter with the Dart SDK version supported by `pubspec.yaml`, then run:

```sh
flutter pub get
flutter run
```

## Make and check your change

Keep changes focused and follow the existing Dart style and feature structure. Before opening a pull request, run:

```sh
dart format .
flutter analyze
flutter test
```

For changes to reminder behavior, please describe the platform and device conditions you checked. Notification delivery depends on operating-system permissions, alarm access, and battery policies; a successful test on one device does not guarantee delivery on every device.

## Pull requests

Include a short explanation of the user-visible change, why it is needed, and how you checked it. Add or update tests when behavior changes. Include screenshots only when they help explain a UI change, and make sure they contain no real personal or medicine data.

Dosey is a reminder and logging tool, not medical advice. Always follow the medicine label and a healthcare professional's instructions.
