# Postly

Una app Flutter minimalista para leer posts, construida con **Clean Architecture estricta**, BLoC pattern y un design system tipográfico propio.

---

## Stack

| Capa                   | Tecnología                                      |
| ---------------------- | ----------------------------------------------- |
| State management       | `flutter_bloc` — BLoC pattern                   |
| HTTP client            | `dio`                                           |
| Dependency injection   | `get_it` (registro manual)                      |
| Persistencia local     | `hive` — posts guardados offline                |
| Value equality         | `equatable`                                     |
| Programación funcional | `dartz` — `Either<Failure, T>`                  |
| Charts                 | `fl_chart` — bar chart posts por autor          |
| Tipografía             | `google_fonts` — Calistoga (headings) + Inter   |

---

## Arquitectura

Clean Architecture en 3 capas estrictas. Las dependencias solo apuntan hacia adentro: `presentation → domain ← data`.

```
lib/
├── main.dart
├── app/
│   └── app.dart                            # MaterialApp + ThemeData centralizado
├── core/
│   ├── di/injection_container.dart         # Registro get_it
│   ├── errors/
│   │   ├── failures.dart                   # Failure, ServerFailure, NetworkFailure
│   │   └── exceptions.dart
│   ├── navigation/
│   │   └── app_routes.dart                 # fadeSlideRoute<T>() — transición única
│   ├── network/
│   │   └── dio_client.dart
│   ├── theme/
│   │   └── app_colors.dart                 # Design tokens centralizados
│   └── widgets/
│       └── postly_app_bar.dart             # AppBar compartido entre features
└── features/
    ├── posts/
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── post_entity.dart         # wordCount getter — lógica en el dominio
    │   │   ├── repositories/post_repository.dart
    │   │   └── usecases/
    │   │       ├── get_posts_usecase.dart
    │   │       └── get_post_by_id_usecase.dart
    │   ├── data/
    │   │   ├── models/post_model.dart
    │   │   ├── datasources/post_remote_datasource.dart
    │   │   └── repositories/post_repository_impl.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── posts_bloc.dart
    │       │   ├── posts_event.dart
    │       │   └── posts_state.dart
    │       ├── pages/
    │       │   ├── main_page.dart           # BottomNavigationBar + IndexedStack
    │       │   ├── posts_list_page.dart
    │       │   └── post_detail_page.dart
    │       └── widgets/
    │           ├── post_tile.dart
    │           ├── loading_widget.dart
    │           └── post_error_widget.dart
    ├── saved/
        ├── domain/
        │   ├── repositories/saved_post_repository.dart
        │   └── usecases/
        │       ├── get_saved_posts_usecase.dart
        │       ├── save_post_usecase.dart
        │       ├── remove_post_usecase.dart
        │       └── is_post_saved_usecase.dart
        ├── data/
        │   ├── local/saved_post_model.dart
        │   ├── datasources/saved_post_local_datasource.dart
        │   └── repositories/saved_post_repository_impl.dart
        └── presentation/
            ├── bloc/
            │   ├── saved_bloc.dart
            │   ├── saved_event.dart
            │   └── saved_state.dart
            └── pages/
                └── saved_page.dart
    └── stats/
        ├── domain/
        │   ├── entities/post_stats_entity.dart
        │   └── usecases/get_post_stats_usecase.dart
        └── presentation/
            ├── bloc/
            │   ├── stats_bloc.dart          # autosuficiente — llama GetPostsUseCase
            │   ├── stats_event.dart
            │   └── stats_state.dart
            └── pages/
                └── stats_page.dart
```

### Reglas Estrictas

- Ningún widget importa nada de la capa `data/`.
- Los **usecases** son el único punto de entrada al dominio desde la presentación.
- Cada feature tiene su propio Bloc — ninguna feature lee el estado de otra.

---

## Jerarquía de Dependencias

La regla de oro de Clean Architecture: **las dependencias apuntan hacia adentro**. El dominio no sabe que Flutter existe.

```
┌─────────────────────────────────────────────────────┐
│                   PRESENTATION                      │
│         Widgets · Pages · BLoC · States             │
│                                                     │
│  PostsBloc          SavedBloc          StatsBloc    │
│      │                  │                  │        │
│      ▼                  ▼                  ▼        │
├─────────────────────────────────────────────────────┤
│                     DOMAIN                          │
│         Entities · Usecases · Repositories          │
│                                                     │
│  GetPostsUseCase    SavePostUseCase    GetPostStats  │
│        │                 │                 │        │
│        ▼                 ▼                 ▼        │
│   PostRepository  SavedPostRepository  (pure fn)    │
│   (abstract)        (abstract)                      │
├─────────────────────────────────────────────────────┤
│                      DATA                           │
│       Models · Datasources · Repository Impls       │
│                                                     │
│  PostRepositoryImpl        SavedPostRepositoryImpl  │
│  PostRemoteDataSource      SavedPostLocalDatasource │
│  PostModel (fromJson)      SavedPostModel (Hive)    │
└─────────────────────────────────────────────────────┘

         presentation → domain ← data
         (nunca al revés)
```

### Flujo completo de una petición

```
UI (PostsListPage)
  │  add(GetPostsEvent)
  ▼
PostsBloc
  │  getPostsUseCase()
  ▼
GetPostsUseCase
  │  repository.getPosts()
  ▼
PostRepository          ← interfaz abstracta en domain
  │  implements
  ▼
PostRepositoryImpl      ← en data; captura excepciones → Failures
  │  remoteDataSource.getPosts()
  ▼
PostRemoteDataSourceImpl
  │  dio.get('/posts')
  ▼
AWS API Gateway → Lambda → jsonplaceholder
```

### Aislamiento de features

Cada feature es un módulo cerrado. Ninguna feature accede al estado interno de otra.

```
features/
├── posts/   ─── GetPostsUseCase (shared via DI)
├── saved/   ─── SavedBloc (propio)
└── stats/   ─── StatsBloc llama GetPostsUseCase, no PostsBloc
```

La navegación entre features pasa por `core/navigation/AppNavigator` — ningún widget importa la página de otra feature directamente.

### Design System

```
AppColors         ← tokens de color (15 constantes)
AppTextStyles     ← tokens de tipografía (postMeta, postCardTitle, postBodyPreview, sectionTitle)
ThemeData         ← MaterialApp theme — ColorScheme + AppBarTheme + TextTheme
PostlyAppBar      ← widget compartido entre las 3 páginas principales
```

---

## Comandos

```bash
# Instalar dependencias
flutter pub get

# Levantar en desarrollo (mobile / desktop)
flutter run

# Levantar en Flutter Web (desarrollo local)
flutter run -d chrome --web-browser-flag "--disable-web-security"

# Análisis estático
flutter analyze

# Tests
flutter test

# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release
```

> No se requiere `build_runner`. El registro de dependencias es manual en `lib/core/di/injection_container.dart`.

---

## Decisiones de Refactoring

Esta sección documenta las siete decisiones técnicas de limpieza aplicadas al codebase, con el principio que las motivó y el cambio concreto realizado.

---

### 1. Color Architecture — AppColors + ThemeData

**Problema:** colores hexadecimales hardcodeados duplicados en 8+ archivos (`Color(0xFF6C63FF)`, `Color(0xFF1A1A2E)`, etc.).

**Principio:** DRY (Don't Repeat Yourself) + DIP (Dependency Inversion). Los widgets no deberían depender de valores concretos, sino de abstracciones semánticas.

**Solución:** clase `AppColors` con design tokens nombrados (`primary`, `textDark`, `surfaceLavender`, etc.) y `ThemeData` centralizado en `app.dart`. Los widgets dependen del nombre, no del valor.

```dart
// Antes
color: Color(0xFF6C63FF)

// Después
color: AppColors.primary
```

---

### 2. Navigation Transitions Duplicadas

**Problema:** la función `fadeSlideRoute<T>()` estaba copiada en tres archivos distintos (`post_tile.dart`, `saved_page.dart`, `stats_page.dart`).

**Principio:** DRY. Tres copias de la misma función es una función sin hogar — el código pidiendo ser extraído.

**Solución:** función top-level en `lib/core/navigation/app_routes.dart`. Un solo punto de cambio si el comportamiento de la transición evoluciona.

---

### 3. `_buildFooter` → `_PostsFooter` StatelessWidget

**Problema:** `_buildFooter` era un método privado que retornaba un widget y recibía parámetros — la firma exacta de un StatelessWidget disfrazado de método.

**Principio:** SRP (Single Responsibility Principle). Un método que construye UI tiene una responsabilidad que merece su propia clase.

**Solución:** `_PostsFooter` StatelessWidget con `isLoadingMore`, `hasReachedMax` y `onLoadMore` como parámetros declarativos. El `context.read<PostsBloc>()` quedó en el padre, donde corresponde.

```dart
// Antes
Widget _buildFooter(bool isLoadingMore, bool hasReachedMax) { ... }

// Después
class _PostsFooter extends StatelessWidget {
  const _PostsFooter({
    required this.isLoadingMore,
    required this.hasReachedMax,
    required this.onLoadMore,
  });
  ...
}
```

---

### 4. AppBar Triplicado → `PostlyAppBar`

**Problema:** las tres páginas principales (`PostsListPage`, `SavedPage`, `StatsPage`) construían la misma estructura de `AppBar` — mismo fondo, misma fuente Calistoga 32, mismo divider de 1px — con un único punto de variación: el título.

**Principio:** DRY + Screaming Architecture. Tres estructuras idénticas en tres lugares distintos es una abstracción que el código está pidiendo.

**Solución:** `PostlyAppBar` implementa `PreferredSizeWidget` (requerido por `Scaffold.appBar`) con un parámetro `title`. El `preferredSize` es `kToolbarHeight + 1` para incluir el divider inferior.

```dart
// Antes — en cada página
appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: false,
  titleSpacing: 16,
  title: Text('Postly', style: GoogleFonts.calistoga(fontSize: 32, color: Colors.black)),
  bottom: const PreferredSize(...),
),

// Después
appBar: const PostlyAppBar(title: 'Postly'),
```

---

### 5. `Colors.white` / `Colors.black` Hardcodeados

**Problema:** `Colors.white` y `Colors.black` aparecían en 15+ lugares entre widgets, ThemeData y Scaffolds — muchos de ellos redundantes porque `ThemeData` ya los definía.

**Dos categorías de cambio:**

**Redundantes → eliminados.** Los Scaffolds que declaraban `backgroundColor: Colors.white` y los AppBars con `iconTheme: IconThemeData(color: Colors.black)` donde `AppBarTheme` en `ThemeData` ya los cubre. Redundancia que oculta la fuente de verdad.

**Intencionales → nominados.** Los que sí son necesarios recibieron nombre semántico en `AppColors`:

```dart
static const white     = Color(0xFFFFFFFF); // canvas + on-dark text
static const textBlack = Color(0xFF000000); // hero headings (Calistoga)
```

**Por qué `textBlack` y no `AppColors.textDark`:** `textDark` es `Color(0xFF1A1A2E)` — dark navy, no negro puro. Los headings Calistoga usan negro puro por decisión de diseño. Son conceptos distintos que merecen tokens distintos.

**Caso especial:** el botón de retry en `PostErrorWidget` pasó de `Colors.white` a `theme.colorScheme.onPrimary` — el nombre semántico correcto para "color sobre fondo primary".

---

### 6. `wordCount` Getter en `PostEntity`

**Problema:** `post.body.split(' ').length` estaba en `_LongestPostCard` — lógica de dominio en la capa de presentación.

**Principio:** Tell, Don't Ask. La entidad sabe qué es ella. El widget solo pregunta.

**Problema técnico adicional:** `split(' ')` no maneja múltiples espacios ni saltos de línea. `'hola  mundo'.split(' ').length` devuelve `3`, no `2`.

**Solución:** getter `wordCount` en `PostEntity` usando `RegExp(r'\s+')`:

```dart
int get wordCount => body.trim().split(RegExp(r'\s+')).length;
```

```dart
// Antes — en el widget
'${post.body.split(' ').length} words'

// Después — el widget pregunta
'${post.wordCount} words'
```

---

### 7. `StatsBloc` Autosuficiente — Feature Isolation

**Problema:** `_StatsView` era `StatefulWidget` únicamente para espiar el estado de `PostsBloc` y pasarle los posts a `StatsBloc` como parámetro del evento. La capa de presentación orquestando datos entre features.

**Principio:** Feature Cohesion. En Clean Architecture, cada feature es un módulo cerrado. Nadie busca datos al cuarto del vecino.

```
// Violación
stats feature → PostsBloc (feature ajena) → posts → StatsBloc

// Correcto
stats feature → GetPostsUseCase → PostRepository → StatsBloc
```

**Solución:**

`LoadStats` perdió su parámetro `posts`. `StatsBloc` recibió `GetPostsUseCase` y llama al repositorio directamente:

```dart
// Antes — la UI pasaba los datos
context.read<StatsBloc>().add(LoadStats(postsBloc.allPosts));

// Después — el Bloc es autosuficiente
create: (_) => sl<StatsBloc>()..add(const LoadStats()),
```

```dart
// StatsBloc._onLoadStats
Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
  emit(const StatsLoading());
  final result = await _getPosts();
  result.fold(
    (failure) => emit(StatsError(failure.message)),
    (posts)   => emit(StatsLoaded(_getPostStats(posts))),
  );
}
```

**Consecuencia directa:** `_StatsView` bajó de `StatefulWidget` a `StatelessWidget` — sin `initState`, sin `BlocListener<PostsBloc>`, sin imports de la feature `posts`. La feature `stats` ya no sabe que `posts` existe.

---

### 8. `stats` promovida a feature independiente

**Problema:** una vez que `StatsBloc` dejó de depender de `PostsBloc`, su ubicación en `features/posts/presentation/bloc/stats/` ya no tenía sentido. Era una feature viviendo dentro de otra feature.

**Principio:** Screaming Architecture. La estructura de carpetas debe gritar lo que el sistema hace. `features/posts/`, `features/saved/`, `features/stats/` — tres módulos al mismo nivel, con la misma jerarquía, con las mismas responsabilidades.

**Cambios:**
- `features/posts/presentation/bloc/stats/` → `features/stats/presentation/bloc/`
- `features/posts/presentation/pages/stats_page.dart` → `features/stats/presentation/pages/`
- `features/posts/domain/usecases/get_post_stats_usecase.dart` → `features/stats/domain/usecases/`
- `features/posts/domain/entities/post_stats_entity.dart` → `features/stats/domain/entities/`

---

## Provider vs BLoC — Por qué se eligió BLoC

**Provider** es un wrapper liviano sobre `InheritedWidget`. El estado vive en un `ChangeNotifier` y se muta directamente. Flexible y de bajo nivel.

**BLoC** (Business Logic Component) es un patrón donde el estado es **inmutable** y los cambios se expresan como **eventos** que producen nuevos **estados**. El flujo es unidireccional: `Event → BLoC → State → UI`.

| Criterio             | Provider                                    | BLoC                                                                               |
| -------------------- | ------------------------------------------- | ---------------------------------------------------------------------------------- |
| Separación UI/lógica | Opcional — depende del desarrollador        | Estructural — la arquitectura lo impone                                            |
| Estados explícitos   | No nativo — hay que modelarlos a mano       | `PostsInitial`, `PostsLoading`, `PostsSuccess`, `PostsFailure` son tipos distintos |
| Trazabilidad         | Difícil — mutación directa                  | Cada evento y estado es logueable; compatible con `BlocObserver`                   |
| Testing              | Testeable si se disciplina                  | Determinístico por diseño — dado un evento, siempre el mismo estado                |
| Escalabilidad        | Puede volverse acoplado en features grandes | Cada feature tiene su propio BLoC aislado                                          |

Con Provider, nada impide esto:

```dart
// ❌ lógica de negocio en el widget
onTap: () {
  final posts = await repository.getPosts();
  setState(() => _posts = posts);
}
```

Con BLoC, el contrato es claro desde el día uno:

```dart
// ✅ el widget solo dispara intenciones
onTap: () => context.read<PostsBloc>().add(const GetPostsEvent());
```

---

## Design System

Paleta clara minimalista con tipografía editorial.

| Token          | Valor       | Uso                                    |
| -------------- | ----------- | -------------------------------------- |
| `primary`      | `#6C63FF`   | Acciones, badges, iconos activos       |
| `white`        | `#FFFFFF`   | Canvas, superficies base               |
| `textBlack`    | `#000000`   | Headings Calistoga                     |
| `textDark`     | `#1A1A2E`   | Títulos de posts, contenido principal  |
| `textMid`      | `#6B6B80`   | Body, contenido secundario             |
| `textLight`    | `#9B9BAD`   | Labels, metadata, iconos inactivos     |
| `borderSubtle` | `#E8E8EE`   | Divisores de AppBar                    |
| `surfaceLavender` | `#ECE8FF` | Cards lavanda                         |
| `surfaceBlue`  | `#E8F4FD`   | Cards azul                             |
| `surfaceGreen` | `#D4EDE8`   | Cards verde                            |

**Tipografía:** `Calistoga` para headings grandes (Feed, Saved, Overview, Postly). `Playfair Display` para títulos de posts. `Inter` para todo el resto.

---

## API

- **Base URL**: `https://0ppd7fmnp7.execute-api.us-east-1.amazonaws.com`
- **Endpoint**: `GET /posts`
- **Proxy**: AWS Lambda → `https://jsonplaceholder.typicode.com/posts`
- **Modelo**: `{ id, userId, title, body }`

---

## Infraestructura

La app no consume jsonplaceholder directamente.
El endpoint pasa por un servicio serverless propio desplegado en AWS.

```
Postly App → API Gateway → Lambda → jsonplaceholder
```

| Recurso     | Detalle                                       |
| ----------- | --------------------------------------------- |
| Runtime     | Node.js 22.x                                  |
| Servicio    | AWS Lambda                                    |
| Exposición  | API Gateway HTTP API                          |
| Región      | us-east-1 (Norte de Virginia)                 |
| Endpoint    | `GET /posts`                                  |
| CORS        | Habilitado — `Access-Control-Allow-Origin: *` |

> En producción se agregaría autenticación mediante API Keys
> en API Gateway y restricción de CORS al dominio de la aplicación.

---

## CORS — Flutter Web en desarrollo local

Al correr la app en `flutter run -d chrome`, el browser hace requests desde `http://localhost:PORT` hacia `https://...amazonaws.com`. Esto dispara un preflight `OPTIONS` que API Gateway intercepta antes de llegar a Lambda.

**Comportamiento verificado:**
- `OPTIONS /posts` → `204 No Content` — API Gateway intercepta el preflight pero no inyecta los headers CORS en la respuesta
- `GET /posts` con `Origin` header → `200 OK` con `Access-Control-Allow-Origin: *` — funciona correctamente
- La URL directa en el browser funciona — CORS no aplica a navegación directa, solo a requests hechos por JavaScript desde otro origen

**Por qué falla en localhost y no en producción:**  
En producción la app corre sobre HTTPS en un dominio real. En desarrollo local corre sobre `http://localhost`, que el browser trata como un origen distinto al de la API. El flag `--disable-web-security` desactiva esa validación solo para la instancia de Chrome lanzada por Flutter.

**Workaround para desarrollo:**
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

Este flag es exclusivo del proceso de Chrome lanzado por Flutter — no afecta ningún otro browser ni sesión.
