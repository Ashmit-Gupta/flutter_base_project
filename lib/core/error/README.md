# Error Handling

Error modeling and handling.

## Components

- `app_failure.dart`: Failure types
- `error_handler.dart`: Error handling logic
- `config_exception.dart`: Configuration errors

## Usage

```dart
final result = await repository.getData();
result.fold(
  (failure) => handleError(failure),
  (data) => useData(data),
);
```