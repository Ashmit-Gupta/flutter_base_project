# Layout

Adaptive layout system.

## Components

- `adaptive_layout_builder.dart`: Responsive layout builder
- `screen_type_scope.dart`: Screen type provider
- `breakpoints.dart`: Screen breakpoints

## Usage

```dart
AdaptiveLayoutBuilder(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)
```