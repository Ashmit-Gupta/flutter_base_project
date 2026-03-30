# Core Layer

The `core/` folder contains **shared infrastructure and abstractions**
used across multiple features.

This layer is:
- Feature-agnostic
- UI-agnostic
- Highly reusable
- Highly testable

---

## Responsibilities

- Networking abstractions
- Error modeling
- Base classes
- Storage interfaces
- Logging
- Platform services
- Shared utilities

---

## What belongs here ✅

- Code reused by 2+ features
- Abstract interfaces
- Infrastructure helpers
- Cross-cutting concerns

---

## What must NOT go here ❌

- Feature logic
- Feature ViewModels
- Widgets or UI code
- API endpoints
- Business rules

---

## Dependency Rules

- `core/` can NOT import from:
    - `features/`
    - `app/`

- `features/` MAY import from:
    - `core/`

This is a one-way dependency.

---

## Design Principles

- Prefer abstractions over implementations
- No direct dependency injection here
- No global state
- Easy to mock in tests

If a file feels feature-specific, it does NOT belong here.
