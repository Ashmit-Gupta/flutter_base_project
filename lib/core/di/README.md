# Dependency Injection

This module handles dependency injection using Riverpod providers.

## Overview

The DI system uses Riverpod's `Provider` family to manage dependencies across the app. All providers are defined in `core_providers.dart` and overridden in `main.dart` for environment-specific configuration.

## Structure

- `core_providers.dart`: Core infrastructure providers (logging, networking, storage)
- `di.dart`: Placeholder for future injectable setup

## Providers

### Core Providers

- `appConfigProvider`: AppConfig from environment
- `appLoggerProvider`: Logger instance
- `dioProvider`: HTTP client
- `sharedPreferencesProvider`: Local storage
- `secureStorageProvider`: Secure storage

### Usage

```dart
final logger = ref.watch(appLoggerProvider);
final api = ref.watch(dioProvider);
```

## Rules

- All dependencies must be abstracted behind providers
- No direct instantiation of services in widgets
- Providers are overridden in main.dart for testability