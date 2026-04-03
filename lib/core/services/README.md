# Services

Core services that provide platform-specific functionality.

## Services

- `auth_service.dart`: Authentication service
- `file_picker_service.dart`: File picking
- `location_service.dart`: Location services

## Architecture

Services are abstracted interfaces implemented with platform-specific code. They are injected via Riverpod providers.