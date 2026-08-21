# mint_talk

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

## Building

Environment config (backend URL, socket URL, Agora App ID, Razorpay key) is
compiled in at build time via `--dart-define-from-file` — it is **not**
bundled as an asset, so a given build only ever contains the one active
environment's values, never all three at once.

1. Copy `env/example.json` to `env/dev.json` (or `env/staging.json` /
   `env/prod.json`) and fill in real values. These files are git-ignored —
   never commit them.
2. Run/build with the matching file and `ENV` define:
   ```
   flutter run --dart-define=ENV=dev --dart-define-from-file=env/dev.json
   flutter build appbundle --release --dart-define=ENV=prod --dart-define-from-file=env/prod.json
   ```

Release builds also require `android/key.properties` (see
`android/key.properties.example`) — the Gradle build fails fast if it's
missing, instead of falling back to a debug-signed release.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
