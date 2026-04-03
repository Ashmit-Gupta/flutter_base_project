# Storage

Local storage abstractions.

## Components

- `storage_service.dart`: SharedPreferences wrapper
- `secure_storage_service.dart`: FlutterSecureStorage wrapper

## Usage

```dart
final storage = ref.watch(storageServiceProvider);
await storage.setString('key', 'value');
```