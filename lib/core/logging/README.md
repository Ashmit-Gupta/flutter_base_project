# Logging

Logging infrastructure.

## Components

- `logger.dart`: Logger implementation
- `bootstrap_logger.dart`: Bootstrap logging

## Usage

```dart
final logger = ref.watch(appLoggerProvider);
logger.info('Message');
```