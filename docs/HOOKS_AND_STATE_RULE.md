# Hooks & State Management Rules

This project uses Riverpod for state management and Flutter Hooks
ONLY for local UI state.

## Allowed Usage of Hooks

Hooks MAY be used for:
- TextEditingController
- FocusNode
- ScrollController
- AnimationController
- TabController
- UI-only toggles

Hooks are allowed ONLY in:
- features/**/presentation/**
- shared/widgets/**

## Forbidden Usage of Hooks

Hooks MUST NOT:
- Call APIs
- Access repositories
- Contain business logic
- Modify ViewModel state directly
- Handle persistence
- Trigger navigation

Hooks MUST NOT be used in:
- ViewModels
- Providers / Notifiers
- Domain layer
- Data layer
- Core services

## useEffect Rules

useEffect MAY:
- Attach listeners
- Sync controllers
- Perform UI wiring

useEffect MUST NOT:
- Call APIs
- Replace ViewModel initialization
- Perform business side effects

## State Management Rules

- Riverpod is the single source of truth
- ViewModels own business logic
- UI dispatches intent only
- Navigation reacts to provider state

## Rule of Thumb

If it belongs in initState → hooks are OK  
If it belongs in a ViewModel → hooks are NOT OK

# Flutter Hooks Usage Guide

This project uses **Flutter Hooks** and **hooks_riverpod**
ONLY to reduce UI boilerplate.

Hooks are a **UI convenience**, not an architecture or state-management tool.

---

## 🎯 Core Principle

> **Hooks replace `StatefulWidget` boilerplate — nothing more.**

If logic belongs in:
- `initState` / `dispose` → Hooks are OK
- ViewModel / Provider / Repository → Hooks are NOT OK

---

## ✅ WHERE Hooks ARE ALLOWED

Hooks may be used **ONLY** in the UI / presentation layer.

Allowed locations:
- `features/**/presentation/**`
- `shared/widgets/**`

Allowed responsibilities:
- `TextEditingController`
- `FocusNode`
- `ScrollController`
- `AnimationController`
- `TabController`
- Simple UI toggles (expand/collapse)
- UI-only listeners and subscriptions

---

## ❌ WHERE Hooks ARE FORBIDDEN

Hooks MUST NOT be used in:
- ViewModels
- Providers / Notifiers
- Domain layer
- Data layer
- Core services
- Repositories
- Use cases

If a file imports:
- `flutter_hooks`
- `hooks_riverpod`

It **must be a UI widget**.

---

## ❌ WHAT Hooks MUST NEVER DO

Hooks MUST NOT:
- Call APIs
- Access repositories
- Contain business logic
- Modify domain state
- Handle persistence or caching
- Trigger navigation decisions
- Replace ViewModel initialization

---

## ✅ GOOD EXAMPLES (Correct Usage)

### ✔ UI Controllers (GOOD)

```dart
class LoginForm extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Column(
      children: [
        TextField(controller: emailController),
        TextField(controller: passwordController),
      ],
    );
  }
}
