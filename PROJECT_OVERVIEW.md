# Project Overview — basic_project_setup

This document describes the **purpose**, **architecture**, **tech stack**, and **how everything fits together** in this Flutter starter project.

---

## 1. Purpose

**basic_project_setup** is a **Flutter starter/boilerplate** for new apps. It is not a finished product; it provides:

- A **consistent project structure** (feature-based, with clear app/core/features layers).
- **Pre-wired tooling**: Riverpod, GoRouter, Dio, GetIt, theming, env-based config.
- **Conventions and rules** (documented in `.md` files) for state management, hooks, and architecture.

You use this repo as the base for a new project and then add features on top.

---

## 2. High-Level Architecture

The codebase follows **Clean Architecture**-style layering and **feature-based organization**:

| Layer      | Path        | Role |
|-----------|-------------|------|
| **App**   | `lib/app/`  | Composition root: bootstrap, routing, theme, env. No business logic. |
| **Core**  | `lib/core/` | Shared infra: DI, logging, constants. Feature-agnostic. |
| **Features** | `lib/features/` | Feature-specific UI and logic (e.g. `home_page.dart`). |

**Dependency rule:** Features and app may depend on core. Core must **not** depend on app or features.

Documentation that defines this:

- **App layer:** `lib/app/README.md` — app as “orchestration” (routing, theme, config), no business logic or data access.
- **Core layer:** `lib/core/README.md` — shared abstractions, networking, logging, no feature logic.

---

## 3. Tech Stack & How It’s Used

### 3.1 State Management — Riverpod

- **Packages:** `flutter_riverpod`, `hooks_riverpod`
- **Usage:**
  - **Theme:** `ThemeNotifier` (StateNotifier) holds `ThemeState` (mode, fontFamily). Exposed via `themeProvider` and `materialThemeModeProvider` in `lib/app/theme/`.
  - **App widget:** Root `App` is a `ConsumerStatefulWidget` and uses `ref.watch(themeProvider)` and `ref.watch(materialThemeModeProvider)` to drive `MaterialApp.router` theme and dark theme.
- **Rule:** Riverpod is the single source of truth for app/feature state. ViewModels own business logic; UI only dispatches intent.

**Note:** The app uses Riverpod but `main.dart` does not wrap the app in `ProviderScope`. For Riverpod to work, the root should be `ProviderScope(child: App())` (or equivalent). Adding that in `main.dart` is recommended.

### 3.2 Navigation — GoRouter

- **Package:** `go_router`
- **Usage:**
  - Routes are defined in `lib/app/app_routes.dart` (which uses route constants from `lib/app/routes.dart`).
  - `AppRouter.createRouter()` builds a `GoRouter` with:
    - `initialLocation: AppRoutes.home` (`/home`)
    - Routes: splash (commented out), login → `HomePage`, home (no builder yet).
  - `App` passes this router to `MaterialApp.router(routerConfig: router)`.
- **Route constants** (`lib/app/routes.dart`): `splash = '/'`, `login = '/login'`, `home = '/home'`.

**Gap:** The `/home` route has no `builder`, so navigating to `/home` will not show a screen. `/login` currently shows `HomePage`.

### 3.3 Dependency Injection — GetIt

- **Package:** `get_it`
- **Usage:** `lib/core/di/di.dart` defines a global `GetIt getIt` and `setupDI(AppConfig config)` which:
  - Registers `AppConfig` as singleton.
  - Creates and registers `Dio` with base URL and timeouts from config; optionally adds logging interceptor.
  - Registers `AppLogger` singleton.
  - Leaves placeholders for API/repositories.
- **Current gap:** `main.dart` does **not** call `setupDI(appConfig)` (it’s commented out). So at runtime, `getIt` is never populated. Any code that uses `getIt<AppLogger>()` or `getIt<Dio>()` (e.g. `AppLifecycleObserver`, `AppRouteObserver`, `registerGlobalErrorObserver`) will throw when used until `setupDI` is invoked in `main()` (and ideally before `runApp`).

### 3.4 Networking — Dio

- **Package:** `dio`
- **Usage:** Configured inside `setupDI()` in `lib/core/di/di.dart` (base URL, timeouts, optional logging). Not used elsewhere yet; intended as the HTTP client for future API/repositories.

### 3.5 Environment & Config — flutter_dotenv

- **Package:** `flutter_dotenv`
- **Usage:**
  - `main.dart` reads `ENV_FILE` from `String.fromEnvironment` (default `env/dev.env`), loads that file with `dotenv.load(fileName: envFile)`, and forbids dev env in release.
  - `AppConfigFactory.fromDotEnv()` in `lib/app/app_config.dart` builds an `AppConfig` from required keys: `ENV`, `API_BASE_URL`, `CONNECT_TIMEOUT`, `RECEIVE_TIMEOUT`, `ENABLE_LOGS`, `ENABLE_CRASHLYTICS`.
- **Env files:** `env/dev.env`, `env/prod.env`, plus `*_sample.env`. Actual env files should define the keys listed above (see `AppConfigFactory._requireKeys`).

### 3.6 Theming

- **Location:** `lib/app/theme/`
- **Concepts:**
  - **ThemeState / ThemeNotifier:** Mode (system/light/dark) and font family; state held in Riverpod.
  - **Light/dark themes:** `buildLightTheme()` and `buildDarkTheme()` use `LightColors` and `DarkColors` (implementing `AppColors`) and `AppTextStyles`; both inject an `AppTheme` extension into `ThemeData`.
  - **AppTheme extension:** `AppTheme` (colors + text) is accessible via `context.theme` (see `app_theme_extension.dart`). Widgets are expected to use this instead of hard-coding colors.
- **Design:** Material 3, centralized colors and typography, ready for backend-driven or remote theming later.

### 3.7 Hooks — Flutter Hooks + hooks_riverpod

- **Packages:** `flutter_hooks`, `hooks_riverpod`, `flutter_hooks_lint` (dev)
- **Usage:** No hooks are used in the current UI yet (e.g. `HomePage` is a plain `StatelessWidget`). The project **allows** hooks only for UI convenience (controllers, local UI state) in presentation layer.
- **Rules (see `docs/HOOKS_AND_STATE_RULE.md` and `docs/FLUTTER_HOOKS_USAGE_GUIDE.md`):**
  - Hooks **only** in: `features/**/presentation/**`, `shared/widgets/**` (when you add them).
  - Hooks **only for:** TextEditingController, FocusNode, ScrollController, AnimationController, TabController, UI toggles.
  - Hooks **must not:** call APIs, touch repositories, hold business logic, or drive navigation. ViewModels and providers own that.

### 3.8 Other Dependencies (Ready for Use)

- **shared_preferences** — local key-value persistence.
- **equatable** — value equality for state/models.
- **logger** — logging (project also has a custom `AppLogger` in core).
- **flutter_animate** — animations.
- **connectivity_plus** — network connectivity.
- **intl** — i18n/formatting.
- **flutter_svg** — SVG assets.
- **file_picker** — file selection.
- **firebase_core** — Firebase (not initialized in code yet).
- **skeletonizer** — loading skeletons.

---

## 4. Entry Point & Startup Flow

**File:** `lib/main.dart`

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. Resolve env file from `ENV_FILE` (default `env/dev.env`); assert not empty; in release, forbid dev env.
3. `await dotenv.load(fileName: envFile)`.
4. `AppConfig config = AppConfigFactory.fromDotEnv()`.
5. **Commented out:** `await bootstrap(appConfig);` and `runApp(App(config: appConfig));`.
6. **Current:** `runApp(App())` — so `AppConfig` is loaded but not passed into `App` and DI is not run.

**Suggested next steps:** Call `await setupDI(appConfig);` and wrap app in `ProviderScope`: e.g. `runApp(ProviderScope(child: App()));`. Optionally pass `config` into `App` if you need it in the widget tree.

---

## 5. App Layer (Orchestration)

**Root widget:** `lib/app/app.dart`

- **App** is a `ConsumerStatefulWidget` that:
  - Registers an `AppLifecycleObserver` in `initState` and unregisters in `dispose`.
  - Builds `GoRouter` via `AppRouter.createRouter()` (no config passed currently).
  - Watches `themeProvider` and `materialThemeModeProvider` and passes light/dark theme and theme mode to `MaterialApp.router`.
- **Responsibility:** Only wiring — router, theme, lifecycle. No business logic, no data access.

**Other app pieces:**

- **app_config.dart** — `AppConfig` and `AppConfigFactory.fromDotEnv()` (env-based config).
- **routes.dart** — Route path constants.
- **app_routes.dart** — GoRouter setup and route definitions.
- **theme/** — ThemeState, ThemeNotifier, providers, light/dark builders, colors, text styles, `AppTheme` extension.
- **observers/** — `AppLifecycleObserver` (logs lifecycle), `AppRouteObserver` (logs route push/pop/replace), `error_observer` (FlutterError hook; uses GetIt for logger).

---

## 6. Core Layer

- **core/di/di.dart** — GetIt setup (`setupDI`); registers AppConfig, Dio, AppLogger.
- **core/logging/app_logger.dart** — `AppLogger` with levels (debug, info, warning, error); respects `enableLogging` from config.
- **core/constants/app_constants.dart** — Placeholder (empty); for shared constants.

Core must stay feature-agnostic and not depend on app or features.

---

## 7. Features

- **features/home_page.dart** — Single demo screen: “Welcome” and a theme preview card using `Theme.of(context)` and color scheme. Used as the screen for the `/login` route in the current router.

---

## 8. Assets & Configuration

- **pubspec.yaml:** Declares asset folders: `assets/images/`, `assets/icons/`, `assets/animations/`.
- **analysis_options.yaml:** Uses `flutter_lints`; no extra lint rules enabled.
- **.metadata:** Flutter project metadata.

---

## 9. Documentation Files (Summary)

| File | Content |
|------|--------|
| **README.md** | Short project intro and Flutter getting-started links. |
| **docs/project_setup.md** | Short note: “feature based mvvm”, “getx for di” (actual DI in project is GetIt). |
| **docs/FLUTTER_HOOKS_USAGE_GUIDE.md** | When/how to use Flutter Hooks and Riverpod hooks; rules (e.g. only in HookWidget/HookConsumerWidget, top-level only); decision tree and examples. |
| **docs/HOOKS_AND_STATE_RULE.md** | Project rules: hooks only in presentation/shared widgets; only for UI (controllers, toggles); never for API/repo/ViewModel; Riverpod for state. |
| **lib/app/README.md** | App layer as composition root; orchestration only; no business logic or data; dependency flow (app knows features, not vice versa). |
| **lib/core/README.md** | Core = shared infra, abstractions; dependency rule (core does not import app/features). |
| **lib/app/theme/THEME.md** | Empty. |

---

## 10. Gaps & Inconsistencies to Fix

1. **ProviderScope:** Wrap root in `ProviderScope(child: App())` so Riverpod works.
2. **DI not run:** Uncomment and call `setupDI(appConfig)` in `main.dart` so observers and any future code using `getIt` work.
3. **Home route:** `/home` has no `builder`; either add a home screen or point `initialLocation` to a route that has a builder (e.g. `/login` which shows `HomePage`).
4. **App and config:** Consider passing `AppConfig` into `App` (or a provider) if the UI or theme needs env/config.
5. **docs/project_setup.md** mentions GetX for DI; the project actually uses GetIt. Updating the doc avoids confusion.

---

## 11. One-Sentence Summary

**basic_project_setup** is a Flutter starter with feature-based structure, Riverpod + GoRouter + GetIt + env-based config and theming, and strict rules for app/core/features and for hooks; it is intended to be copied and extended with real features, after wiring up ProviderScope and DI in `main.dart` and completing the home route.
