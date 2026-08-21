---
name: flutter-clean-architecture
description: Guidelines and templates for writing Flutter/Dart code following Clean Architecture with Bloc/Cubit state management, get_it+injectable DI, Dio-based REST networking, and Firebase (Auth, Firestore, Cloud Storage). Use this skill for ANY Flutter or Dart task in this project — building new features/screens, fixing bugs, refactoring, reviewing code, adding an API integration, wiring up Firebase, or writing a Bloc/Cubit — even if the user doesn't explicitly say "clean architecture" or "bloc". Always consult this skill before generating or editing Flutter code so folder structure, state management, error handling, DI, and widget conventions stay consistent with the project's standards. Also use it when asked to review Flutter code for quality, performance, or architecture violations.
---

# Flutter Clean Architecture + Bloc

Conventions and ready-to-copy templates for building this Flutter app. Follow these rules for every Flutter/Dart task — new features, bug fixes, refactors, or reviews — unless the user explicitly asks for something different.

## Step 0: Detect this project's actual conventions

Never assume a blank slate. Before writing or editing any code, check what this specific project already does — conventions below are the fallback for a brand-new project/feature, not a mandate to override what's already there:

1. Read `pubspec.yaml` — confirm `flutter_bloc`, `get_it`, `injectable`, `dio`, `dartz`/`fpdart`, `freezed`, `equatable`, and Firebase packages are actually present, and note their versions. If a package this skill assumes (e.g. `dartz`) is absent but a lookalike is (`fpdart`), use what's installed.
2. Look at `lib/` — is it already feature-first, layer-first, or something else? Open one existing feature end-to-end (entity/model/repository/usecase/cubit/page) and mirror its exact structure, naming, and error-handling style rather than the structure in this SKILL.md if the two disagree.
3. Check how existing states are modeled (freezed vs equatable vs status-enum) and match it — don't introduce a second pattern into a codebase that already picked one.
4. Check for a `CONVENTIONS.md`, `ARCHITECTURE.md`, `.cursorrules`, or similar doc in the repo root and follow it over this skill's defaults where they conflict.
5. If this genuinely is a new/empty project with no existing pattern to mirror, fall back to the defaults and templates below.

If the project's existing conventions conflict with this skill's defaults, say so explicitly and follow the project, don't silently pick one — e.g. "this repo uses Provider, not Bloc, in `features/settings` — matching that instead of introducing Bloc here." Only recommend switching patterns if asked.

## Core stack (defaults for a new project — see Step 0 for existing projects)

- **State management**: `flutter_bloc` — Cubit for simple state, Bloc for complex event-driven flows. States modeled with `freezed` sealed unions (see `templates/state_template.dart`).
- **DI**: `get_it` + `injectable` (code-gen based registration).
- **Networking**: `Dio` for all REST calls, wrapped in a single `ApiClient` with interceptors for auth headers, logging, and error mapping.
- **Firebase**: `firebase_auth`, `cloud_firestore`, `firebase_storage`.
- **Error handling**: `dartz` `Either<Failure, Success>` returned from repositories and use cases — this is the default because it's the most scalable/testable option for a layered architecture. For a genuinely trivial one-off (e.g. a local UI-only toggle with no failure modes), plain try-catch is fine — don't force Either where there's nothing that can meaningfully fail.
- **Widgets**: `StatelessWidget` only. Never `StatefulWidget` for screens/business state — local ephemeral UI state (e.g. an `AnimationController`) is the only acceptable exception, and even then prefer hooks/cubit where reasonable.

## Folder structure (feature-first)

```
lib/
├── core/
│   ├── di/                    # injectable setup, get_it instance
│   ├── error/                 # Failure classes, exception -> failure mapping
│   ├── network/                # ApiClient (Dio), interceptors, network_info
│   ├── firebase/                # shared Firebase service wrappers
│   ├── theme/, constants/, utils/, widgets/  # app-wide shared pieces
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasources/    # remote (Dio/Firebase) + local (cache)
│       │   ├── models/         # DTOs, fromJson/toJson, extend domain entities
│       │   └── repositories/   # implements domain repository interface
│       ├── domain/
│       │   ├── entities/       # pure Dart, no framework deps
│       │   ├── repositories/   # abstract interfaces
│       │   └── usecases/       # single-responsibility, one `call()` method
│       └── presentation/
│           ├── cubit/ (or bloc/)   # <feature>_cubit.dart, <feature>_state.dart
│           ├── pages/
│           └── widgets/
└── main.dart
```

Read `references/layer_rules.md` for the full dependency-direction rules (domain depends on nothing; data depends on domain; presentation depends on domain, never on data directly).

## Workflow for a new feature

1. Define the domain `entity` (plain Dart, immutable, `Equatable`).
2. Define the abstract `repository` interface in `domain/repositories/`.
3. Write `usecases` — one class per action, single `call()` method, returns `Either<Failure, T>`.
4. Implement `data/models/` (extends/maps to the entity) and `data/datasources/` (Dio or Firebase calls, throw exceptions on failure — never return Either from a datasource).
5. Implement `data/repositories/` — catches datasource exceptions, maps to `Failure`, returns `Either`.
6. Register everything with `injectable` (`@injectable`, `@LazySingleton`, `@factoryMethod` as appropriate) — see `templates/injectable_module_template.dart`.
7. Write the `Cubit`/`Bloc` + `freezed` `State` — see `templates/cubit_template.dart` and `templates/state_template.dart`.
8. Build the `presentation/pages` and `presentation/widgets` as `StatelessWidget`s wired up with `BlocProvider`/`BlocBuilder`/`BlocListener`/`BlocConsumer` — see `templates/page_template.dart`.

Use the templates in `templates/` as the starting point rather than writing each piece from scratch — copy, rename, and adapt rather than freehanding a different structure.

## Networking (Dio / REST)

- One shared `ApiClient` wrapping a single `Dio` instance (base URL, timeouts, interceptors) — see `templates/api_client_template.dart`.
- Datasources call `ApiClient` methods and throw a typed `ServerException`/`NetworkException` on failure; they never catch-and-swallow.
- Repositories are the only layer that converts exceptions into `Failure` objects.
- Never call `Dio` directly from a widget, cubit, or use case.

## Firebase

- Wrap `FirebaseAuth`, `FirebaseFirestore`, and `FirebaseStorage` calls behind datasource classes in `data/datasources/`, same as REST — nothing above the data layer should import `package:firebase_*` directly.
- Firestore reads that need to be reused across the app go through a repository method, not ad hoc queries scattered in widgets.
- Stream-based Firestore listeners are exposed from the repository as `Stream<Either<Failure, T>>` or, if simplicity matters more here, a plain `Stream<T>` with errors handled by the Cubit's `emit`/`addError`.

## Code quality checklist (apply on every task, including reviews)

- `const` constructors everywhere possible; flag missing `const` in review.
- No business logic in widgets — widgets read state and dispatch cubit/bloc calls only.
- `ListView.builder`/`SliverList` for long lists, never `ListView(children: [...])` with unbounded data.
- Extract widgets instead of deeply nested build methods; keep `build()` methods short.
- Use `BlocSelector`/`context.select` over `BlocBuilder` when a widget only needs part of the state, to avoid unnecessary rebuilds.
- Dispose controllers, subscriptions, and streams in `close()` (Cubit/Bloc) or `dispose()`.
- No `print()` — use a logger.
- Meaningful names (`fetchUserProfile`, not `getData`); no unused imports/variables.
- When reviewing existing code, call out any of the above violations explicitly and suggest the fix, don't just silently rewrite.

## Templates

All in `templates/`, ready to copy and adapt:

- `entity_template.dart`, `model_template.dart`
- `repository_interface_template.dart`, `repository_impl_template.dart`
- `usecase_template.dart`
- `datasource_remote_template.dart` (Dio-based), `datasource_firebase_template.dart`
- `cubit_template.dart`, `state_template.dart` (freezed)
- `injectable_module_template.dart`
- `api_client_template.dart`
- `page_template.dart` (StatelessWidget + BlocProvider/BlocConsumer)

Read `references/layer_rules.md` for dependency-direction details and `references/error_handling.md` for the full Failure/Either pattern.
