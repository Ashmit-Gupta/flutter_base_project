# Architecture Flow Diagrams (Flutter Starter)

This doc is a **single reference** for the architectural flow used in this repo: startup wiring, app shell orchestration, adaptive layout + typography, theming/design system, Riverpod state flow, navigation, DI/network, and error mapping.

---

## 1) End-to-end runtime flow

```mermaid
flowchart TB
  A[main.dart] --> B[dotenv.load(envFile)]
  B --> C[AppConfigFactory.fromDotEnv()]
  C --> D[ProviderScope overrides core providers]
  D --> E[runApp(ProviderScope(child: App()))]

  E --> F[App widget]
  F -->|watches| G[themeProvider (ThemeState)]
  F -->|watches| H[materialThemeModeProvider]
  F --> I[GoRouter routerConfig]

  I -->|matches route| R[Screen Widget]
  R -->|layout| L[AdaptiveLayoutBuilder]
  L --> S[ScreenTypeScope (screenType + textScaleFactor)]
  S --> T[context.text.*() -> AppTypography]

  R -->|colors| Cx[context.theme.colors -> AppColors]
  R -->|components| W[core widgets (AppButton/AppTextField/etc)]
```

---

## 2) Theme system flow (colors + theme extensions)

```mermaid
flowchart LR
  A[Riverpod ThemeNotifier] --> B[themeProvider -> ThemeState(mode,fontFamily)]
  B --> C[App widget]
  C --> D[buildLightTheme(fontFamily)]
  C --> E[buildDarkTheme(fontFamily)]
  D --> F[ThemeData + inputDecorationTheme + Theme extensions]
  E --> F

  F --> G[ThemeExtension<AppTheme> stores AppColors + fontFamily]
  F --> H[ThemeExtension<AppButtonTheme> stores ButtonStyle variants]
  F --> I[ThemeExtension<AppSnackbarTheme> stores snackbar colors]

  G -->|context.theme| J[app_theme_extension.dart: context.theme]
  H -->|Theme.of(context).extension| K[AppButton uses AppButtonTheme styles]
  I -->|Theme.of(context).extension| M[AppSnackbar uses AppSnackbarTheme + ThemeData.textTheme]
```

Key files:
- `lib/app/theme/theme_provider.dart` (Riverpod provider)
- `lib/app/theme/theme_notifier.dart` (Theme state mutations)
- `lib/app/theme/light_theme_builder.dart`, `lib/app/theme/dark_theme_builder.dart`
- `lib/app/theme/app_theme_extension.dart`
- `lib/app/theme/app_button_theme.dart`, `lib/app/theme/app_snackbar_theme.dart`

---

## 3) Typography system flow (tokens -> adaptive text styles)

```mermaid
flowchart TB
  A[AdaptiveLayoutBuilder] --> B[LayoutBuilder constraints.maxWidth]
  B --> C[Breakpoints.resolve(width) -> ScreenType]
  A --> D[MediaQuery.textScaleFactorOf(context)]
  D --> E[ScreenTypeScope(screenType, textScaleFactor)]

  E --> F[context.text.*()]
  F --> G[typographyForScreen(screenType, color, fontFamily, textScaleFactor)]
  G --> H[AppTypography]
  H --> I[AppTextTokens base sizes]
  H --> J[TypographyScale factor + maxFontSize clamp]

  I --> K[TextStyle for: display/headline/title/body/label/caption]
```

Key files:
- `lib/core/layout/adaptive_layout_builder.dart`
- `lib/core/layout/screen_type_scope.dart`
- `lib/core/layout/breakpoints.dart`
- `lib/core/design/app_text_tokens.dart`
- `lib/core/design/typography_scale.dart`
- `lib/core/design/app_typography.dart`
- `lib/app/theme/app_theme_extension.dart` (binds `context.text`)

---

## 4) Adaptive layout flow (mobile/tablet/desktop wrappers)

```mermaid
flowchart TD
  A[AdaptiveLayoutBuilder] --> B[LayoutBuilder]
  B --> C[Breakpoints.resolve(constraints.maxWidth)]
  C -->|mobile| D[mobile widget]
  C -->|tablet| E[tablet widget or fallback to mobile]
  C -->|desktop| F[desktop widget or fallback to tablet or mobile]
  D --> G[ScreenTypeScope wraps subtree]
  E --> G
  F --> G
```

Key files:
- `lib/core/layout/adaptive_layout_builder.dart`
- `lib/core/layout/layout_constants.dart` (content max widths)

---

## 5) Riverpod state flow (Theme + Auth view models)

### Theme state

```mermaid
flowchart LR
  A[ThemeNotifier] --> B[ThemeState(mode,fontFamily)]
  B --> C[themeProvider (NotifierProvider)]
  C --> D[App watches themeProvider]
  D --> E[MaterialApp switches theme]
```

### Auth form state

```mermaid
flowchart TB
  A[LoginScreen (HookConsumerWidget)] -->|ref.watch| B[LoginFormState]
  A -->|ref.read notifier| C[LoginViewModel]

  U[User taps Submit] --> C.onSubmitPressed()
  C --> V[validateName/validatePassword]
  V -->|valid| W[state = submitting]
  W --> X[async placeholder _performSubmit()]
  X -->|success| Y[state = success]
  X -->|failure| Z[state = failure,errorMessage]

  A -->|ref.listen| AA[show snackbar]
  AA --> AB[onSuccessHandled/onFailureHandled -> reset to idle]
```

Key files:
- `lib/app/theme/theme_provider.dart`, `lib/app/theme/theme_notifier.dart`
- `lib/features/auth/presentation/providers/auth_providers.dart`
- `lib/features/auth/presentation/view_models/login_view_model.dart`
- `lib/features/auth/presentation/view_models/signup_view_model.dart`

---

## 6) Navigation flow (GoRouter)

```mermaid
flowchart TB
  A[AppRouter.createRouter()] --> B[GoRouter(routes + observers)]
  B -->|navigates| C[GoRoute builder -> Screen Widget]
  B --> D[AppRouteObserver (NavigatorObserver)]
  D --> E[AppLogger logging]
```

Key files:
- `lib/app/app_routes.dart` (creates `GoRouter`)
- `lib/app/routes.dart` (route path constants)
- `lib/app/observers/route_observer.dart`

---

## 7) DI + Networking flow (Riverpod + Dio + interceptors)

```mermaid
flowchart TB
  A[main.dart _bootstrap()] --> B[ProviderScope overrides appConfig/sharedPrefs]
  B --> C[Riverpod provides AppConfig]
  B --> D[Riverpod provides AppLogger]
  B --> E[DioClient creates Dio(BaseOptions)]
  E --> F[DioClient adds DioAppInterceptor]
  F --> G[Riverpod provides Dio]

  H[Future repos/APIs] --> I[ref.read(dioProvider)]
  I --> J[DioAppInterceptor.onRequest/onResponse/onError]
  J --> K[Map DioException -> AppException]
```

Key files:
- `lib/core/di/core_providers.dart`
- `lib/core/network/dio_client.dart`
- `lib/core/network/dio_interceptor.dart`

---

## 8) Error modeling flow (AppException -> Failure)

```mermaid
flowchart TB
  A[Dio error] --> B[mapDioError -> AppException]
  B --> C[Failure map: error_mapper.dart]
  C --> D[Failure types (app_failure.dart)]
  D --> E[Repo/ViewModel returns Result/AsyncResult]
  E --> F[UI listens to ViewModel state]
  F --> G[AppSnackbar shows message]
```

Key files:
- `lib/core/error/app_exceptions.dart`
- `lib/core/error/error_mapper.dart`
- `lib/core/error/app_failure.dart`
- `lib/core/results/result.dart`
- `lib/core/feedback/app_snackbar.dart`

---

## Notes / current gaps (important for understanding “why”)
- The **networking layer is wired** (DI + Dio + interceptor + error mapping), but **auth view models currently use placeholders** and do not call any repository yet.
- The app shell and theme/typography wiring are already connected for rendering and adaptive UI.

