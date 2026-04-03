# Network

Networking abstractions and HTTP client configuration.

## Components

- `api_client.dart`: Dio-based HTTP client
- `dio_client.dart`: Dio configuration
- `interceptors/`: Request/response interceptors

## Usage

```dart
final dio = ref.watch(dioProvider);
final response = await dio.get('/api/data');
```