# Layer Dependency Rules

Dependency direction always points inward, toward `domain`:

```
presentation  --->  domain  <---  data
```

- **domain**: Pure Dart. No Flutter, no Dio, no Firebase, no `injectable` annotations on entities. Only entities, repository *interfaces*, and use cases live here. This layer never imports from `data` or `presentation`.
- **data**: Implements the domain repository interfaces. Owns models (DTOs), datasources (Dio/Firebase), and the concrete repository. May import `domain`, never `presentation`.
- **presentation**: Owns Cubits/Blocs, pages, widgets. May import `domain` (entities, usecases) — must NOT import anything from `data` (no models, no datasources, no repository impls). If a Cubit needs data, it calls a usecase, not a repository or datasource directly.

## Common violations to flag on review

- A widget importing a model class from `data/models` instead of the domain entity.
- A Cubit calling a repository implementation directly instead of a usecase.
- A datasource returning `Either<Failure, T>` (datasources should throw; only repositories map to `Either`).
- Business/validation logic living in a widget's `build()` method instead of a usecase or cubit.
- An entity class with a `fromJson`/`toJson` (that belongs on the model, not the entity).
