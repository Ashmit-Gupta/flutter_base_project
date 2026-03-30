# Flutter Hooks Usage Guide

A comprehensive guide on when to use and when NOT to use hooks in Flutter, covering both `flutter_hooks` and Riverpod hooks.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Core Hook Rules](#core-hook-rules)
3. [Flutter Hooks (`flutter_hooks` package)](#flutter-hooks-flutter_hooks-package)
4. [Riverpod Hooks](#riverpod-hooks)
5. [Common Mistakes](#common-mistakes)
6. [Decision Tree](#decision-tree)

---

## Introduction

Hooks are a way to manage state and lifecycle in Flutter widgets. They provide a more functional approach compared to traditional StatefulWidgets. However, they come with strict rules that must be followed to avoid bugs and unexpected behavior.

### What are Hooks?

- **Flutter Hooks**: Lifecycle and state management utilities for widgets (from `flutter_hooks` package)
- **Riverpod Hooks**: Integration between flutter_hooks and Riverpod for state management

---

## Core Hook Rules

### ⚠️ CRITICAL RULES - NEVER BREAK THESE

#### Rule 1: Hooks MUST be called in HookWidget or HookConsumerWidget

```dart
// ❌ WRONG - Using hooks in regular StatelessWidget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0); // ERROR! Not in a HookWidget
    return Text('$count');
  }
}

// ✅ CORRECT - Using HookWidget
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0); // OK!
    return Text('${count.value}');
  }
}

// ✅ CORRECT - Using HookConsumerWidget (for Riverpod)
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = useState(0); // OK!
    final data = ref.watch(myProvider); // OK!
    return Text('${count.value} - $data');
  }
}
```

#### Rule 2: Hooks MUST be called at the top level of build()

Hooks cannot be called inside conditionals, loops, or nested functions.

```dart
// ❌ WRONG - Hook inside conditional
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    if (someCondition) {
      final count = useState(0); // ERROR! Conditional hook call
    }
    return Container();
  }
}

// ❌ WRONG - Hook inside loop
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < 5; i++) {
      final value = useState(i); // ERROR! Hook in loop
    }
    return Container();
  }
}

// ❌ WRONG - Hook inside callback
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final count = useState(0); // ERROR! Hook in callback
      },
      child: Text('Press'),
    );
  }
}

// ✅ CORRECT - All hooks at top level
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    final controller = useTextEditingController();
    final animationController = useAnimationController();
    
    // Use the hooks below
    return ElevatedButton(
      onPressed: () => count.value++,
      child: Text('${count.value}'),
    );
  }
}
```

#### Rule 3: Hook call order MUST remain consistent

The number and order of hooks must be the same on every build.

```dart
// ❌ WRONG - Inconsistent hook order
class MyWidget extends HookWidget {
  final bool showExtra;
  
  MyWidget({required this.showExtra});
  
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    if (showExtra) {
      final extra = useState(''); // ERROR! Conditional hook changes order
    }
    
    final name = useState('');
    return Container();
  }
}

// ✅ CORRECT - Consistent hooks, conditional logic elsewhere
class MyWidget extends HookWidget {
  final bool showExtra;
  
  MyWidget({required this.showExtra});
  
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    final extra = useState(''); // Always called
    final name = useState('');
    
    // Use conditional logic in the UI
    return Column(
      children: [
        Text('${count.value}'),
        if (showExtra) Text(extra.value),
        Text(name.value),
      ],
    );
  }
}
```

---

## Flutter Hooks (`flutter_hooks` package)

### When TO Use Flutter Hooks

#### ✅ 1. Managing Local Widget State

Use `useState` for simple local state management.

```dart
class CounterWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    return Column(
      children: [
        Text('Count: ${count.value}'),
        ElevatedButton(
          onPressed: () => count.value++,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

#### ✅ 2. Managing Controllers (TextEditingController, AnimationController, etc.)

Use specialized hooks to avoid manual disposal.

```dart
class TextFieldWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Automatically disposed when widget is removed
    final controller = useTextEditingController(text: 'Initial');
    
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: 'Name'),
    );
  }
}

class AnimatedWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: Duration(seconds: 2),
    );
    
    useEffect(() {
      animationController.repeat();
      return null; // No cleanup needed
    }, []);
    
    return RotationTransition(
      turns: animationController,
      child: Icon(Icons.refresh),
    );
  }
}
```

#### ✅ 3. Listening to Streams or Futures

Use `useStream` and `useFuture` for reactive data.

```dart
class StreamWidget extends HookWidget {
  final Stream<int> counterStream;
  
  StreamWidget({required this.counterStream});
  
  @override
  Widget build(BuildContext context) {
    final snapshot = useStream(counterStream);
    
    return Text('Value: ${snapshot.data ?? 'Loading...'}');
  }
}

class FutureWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final future = useMemoized(() => fetchUserData());
    final snapshot = useFuture(future);
    
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    return Text('Data: ${snapshot.data}');
  }
}
```

#### ✅ 4. Side Effects (useEffect)

Use `useEffect` for lifecycle events and cleanup.

```dart
class TimerWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    useEffect(() {
      final timer = Timer.periodic(Duration(seconds: 1), (timer) {
        count.value++;
      });
      
      // Cleanup function - called when widget is disposed
      return () => timer.cancel();
    }, []); // Empty array = run once on mount
    
    return Text('Seconds: ${count.value}');
  }
}

class LoggerWidget extends HookWidget {
  final String userId;
  
  LoggerWidget({required this.userId});
  
  @override
  Widget build(BuildContext context) {
    useEffect(() {
      print('User changed to: $userId');
      
      return () => print('Cleaning up for user: $userId');
    }, [userId]); // Re-run when userId changes
    
    return Text('User: $userId');
  }
}
```

#### ✅ 5. Memoization (useMemoized)

Use `useMemoized` to cache expensive computations.

```dart
class ExpensiveWidget extends HookWidget {
  final List<int> numbers;
  
  ExpensiveWidget({required this.numbers});
  
  @override
  Widget build(BuildContext context) {
    // Only recalculate when numbers list changes
    final sortedNumbers = useMemoized(
      () => List<int>.from(numbers)..sort(),
      [numbers],
    );
    
    return ListView.builder(
      itemCount: sortedNumbers.length,
      itemBuilder: (context, index) => Text('${sortedNumbers[index]}'),
    );
  }
}
```

#### ✅ 6. Callback Memoization (useCallback)

Use `useCallback` to prevent unnecessary rebuilds in child widgets.

```dart
class ParentWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    // Callback is recreated only when count.value changes
    final increment = useCallback(
      () => count.value++,
      [count.value],
    );
    
    return Column(
      children: [
        Text('Count: ${count.value}'),
        ChildButton(onPressed: increment),
      ],
    );
  }
}

class ChildButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const ChildButton({required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    print('ChildButton rebuilt');
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Increment'),
    );
  }
}
```

### When NOT to Use Flutter Hooks

#### ❌ 1. Don't Use for Global State Management

Hooks are for local widget state, not app-wide state.

```dart
// ❌ WRONG - Using hooks for global state
class AppState extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final userAuth = useState<User?>(null); // Bad: Local to this widget
    final settings = useState<Settings>(Settings());
    
    // This state is lost when widget rebuilds or is removed
    return MaterialApp(home: HomeScreen());
  }
}

// ✅ CORRECT - Use Riverpod, Provider, or other state management
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

class AppState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return MaterialApp(home: HomeScreen());
  }
}
```

#### ❌ 2. Don't Use Hooks Outside build() Method

```dart
// ❌ WRONG - Hook outside build
class MyWidget extends HookWidget {
  final controller = useTextEditingController(); // ERROR!
  
  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller);
  }
}

// ✅ CORRECT - Hook inside build
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return TextField(controller: controller);
  }
}
```

#### ❌ 3. Don't Use When StatefulWidget is More Appropriate

Sometimes traditional StatefulWidget is clearer and more maintainable.

```dart
// ❌ WRONG - Overly complex hook usage
class ComplexForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final name = useTextEditingController();
    final email = useTextEditingController();
    final phone = useTextEditingController();
    final address = useTextEditingController();
    final city = useTextEditingController();
    final zip = useTextEditingController();
    final isValidated = useState(false);
    final errors = useState<Map<String, String>>({});
    
    // 50+ lines of validation logic...
    
    return Form(/* ... */);
  }
}

// ✅ CORRECT - StatefulWidget for complex forms
class ComplexForm extends StatefulWidget {
  @override
  _ComplexFormState createState() => _ComplexFormState();
}

class _ComplexFormState extends State<ComplexForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  // ... other controllers
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    // ... initialize other controllers
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // ... dispose other controllers
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(key: _formKey, /* ... */);
  }
}
```

#### ❌ 4. Don't Mix Hooks and StatefulWidget

Never try to use hooks in a StatefulWidget - it won't work.

```dart
// ❌ WRONG - Can't use hooks in StatefulWidget
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final count = useState(0); // ERROR! Not a HookWidget
    return Text('$count');
  }
}

// ✅ CORRECT - Use HookWidget or stick with StatefulWidget
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    return Text('${count.value}');
  }
}
```

---

## Riverpod Hooks

### When TO Use Riverpod Hooks

#### ✅ 1. Combining Local State with Provider State

Use `HookConsumerWidget` when you need both local hooks and provider access.

```dart
final userProvider = Provider<User>((ref) => User(name: 'John'));

class UserProfile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider state
    final user = ref.watch(userProvider);
    
    // Local state with hooks
    final isEditing = useState(false);
    final controller = useTextEditingController(text: user.name);
    
    return Column(
      children: [
        if (isEditing.value)
          TextField(controller: controller)
        else
          Text(user.name),
        ElevatedButton(
          onPressed: () => isEditing.value = !isEditing.value,
          child: Text(isEditing.value ? 'Save' : 'Edit'),
        ),
      ],
    );
  }
}
```

#### ✅ 2. Listening to Providers with Hooks Lifecycle

Combine provider watching with hook lifecycle management.

```dart
final counterProvider = StateProvider<int>((ref) => 0);
final timerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(Duration(seconds: 1), (count) => count);
});

class TimerCounter extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final timer = ref.watch(timerProvider);
    
    // Use hooks for side effects
    useEffect(() {
      print('Counter changed to: $counter');
      return null;
    }, [counter]);
    
    return Column(
      children: [
        Text('Counter: $counter'),
        Text('Timer: ${timer.value ?? 0}'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

#### ✅ 3. Using ref with Hook Effects

Access providers within useEffect for side effects.

```dart
final userIdProvider = StateProvider<String>((ref) => '');
final analyticsProvider = Provider<Analytics>((ref) => Analytics());

class AnalyticsTracker extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    
    useEffect(() {
      if (userId.isNotEmpty) {
        ref.read(analyticsProvider).logUser(userId);
      }
      
      return () {
        ref.read(analyticsProvider).clearUser();
      };
    }, [userId]);
    
    return Text('Tracking user: $userId');
  }
}
```

#### ✅ 4. Combining Multiple Providers with Local Hooks

```dart
final authProvider = Provider<AuthService>((ref) => AuthService());
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class SettingsScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);
    
    // Local state for UI interactions
    final isExpanded = useState(false);
    final scrollController = useScrollController();
    
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        controller: scrollController,
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: theme == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).state = 
                value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          ExpansionTile(
            title: Text('Advanced'),
            initiallyExpanded: isExpanded.value,
            onExpansionChanged: (expanded) => isExpanded.value = expanded,
            children: [
              ListTile(title: Text('Option 1')),
              ListTile(title: Text('Option 2')),
            ],
          ),
        ],
      ),
    );
  }
}
```

### When NOT to Use Riverpod Hooks

#### ❌ 1. Don't Use HookConsumerWidget When You Only Need Providers

If you don't need hooks, use `ConsumerWidget` instead.

```dart
// ❌ WRONG - Unnecessary HookConsumerWidget
class UserDisplay extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    // No hooks used - HookConsumerWidget is overkill
    return Text(user.name);
  }
}

// ✅ CORRECT - Use ConsumerWidget
class UserDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Text(user.name);
  }
}
```

#### ❌ 2. Don't Use Hooks to Replace Provider State

Providers should handle shared state, not hooks.

```dart
// ❌ WRONG - Using hooks for shared state
class ParentWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedCount = useState(0); // Bad: Can't share with siblings
    
    return Column(
      children: [
        ChildA(count: sharedCount.value),
        ChildB(count: sharedCount.value),
      ],
    );
  }
}

// ✅ CORRECT - Use provider for shared state
final sharedCountProvider = StateProvider<int>((ref) => 0);

class ParentWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ChildA(),
        ChildB(),
      ],
    );
  }
}

class ChildA extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(sharedCountProvider);
    return Text('Child A: $count');
  }
}
```

#### ❌ 3. Don't Use ref.watch() Inside useEffect

This can cause infinite rebuild loops.

```dart
// ❌ WRONG - Watching provider inside useEffect
class BadWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      final value = ref.watch(someProvider); // ERROR! Causes rebuild loop
      print(value);
      return null;
    }, []);
    
    return Container();
  }
}

// ✅ CORRECT - Watch outside, react inside useEffect
class GoodWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(someProvider);
    
    useEffect(() {
      print('Value changed to: $value');
      return null;
    }, [value]);
    
    return Container();
  }
}

// ✅ ALSO CORRECT - Use ref.read() or ref.listen() inside useEffect
class AlsoGoodWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      final value = ref.read(someProvider); // OK: read doesn't rebuild
      print(value);
      return null;
    }, []);
    
    return Container();
  }
}
```

---

## Common Mistakes

### Mistake 1: Using Hook Values Directly in Callbacks Without Dependencies

```dart
// ❌ WRONG - Stale closure
class CounterWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    final increment = useMemoized(() {
      return () {
        print('Count is: ${count.value}'); // Always prints initial value!
        count.value++;
      };
    }, []); // Empty deps - callback created once
    
    return ElevatedButton(
      onPressed: increment,
      child: Text('${count.value}'),
    );
  }
}

// ✅ CORRECT - Include dependencies
class CounterWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    final increment = useCallback(() {
      print('Count is: ${count.value}'); // Always current value
      count.value++;
    }, [count.value]); // Recreated when count changes
    
    return ElevatedButton(
      onPressed: increment,
      child: Text('${count.value}'),
    );
  }
}
```

### Mistake 2: Creating Controllers Inside Callbacks

```dart
// ❌ WRONG - Controller created on every press
class BadWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final controller = useTextEditingController(); // ERROR!
      },
      child: Text('Press'),
    );
  }
}

// ✅ CORRECT - Controller created at top level
class GoodWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    
    return TextField(controller: controller);
  }
}
```

### Mistake 3: Not Cleaning Up Side Effects

```dart
// ❌ WRONG - Timer never cancelled
class BadTimer extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    useEffect(() {
      Timer.periodic(Duration(seconds: 1), (timer) {
        count.value++;
      });
      return null; // No cleanup!
    }, []);
    
    return Text('${count.value}');
  }
}

// ✅ CORRECT - Timer properly disposed
class GoodTimer extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    
    useEffect(() {
      final timer = Timer.periodic(Duration(seconds: 1), (timer) {
        count.value++;
      });
      
      return () => timer.cancel(); // Cleanup!
    }, []);
    
    return Text('${count.value}');
  }
}
```

### Mistake 4: Conditional Hook Calls Based on Widget Properties

```dart
// ❌ WRONG - Conditional hooks based on props
class UserWidget extends HookWidget {
  final bool isAdmin;
  
  UserWidget({required this.isAdmin});
  
  @override
  Widget build(BuildContext context) {
    final name = useState('User');
    
    if (isAdmin) {
      final adminLevel = useState(1); // ERROR! Conditional hook
    }
    
    return Text(name.value);
  }
}

// ✅ CORRECT - All hooks always called
class UserWidget extends HookWidget {
  final bool isAdmin;
  
  UserWidget({required this.isAdmin});
  
  @override
  Widget build(BuildContext context) {
    final name = useState('User');
    final adminLevel = useState(1); // Always called
    
    return Column(
      children: [
        Text(name.value),
        if (isAdmin) Text('Level: ${adminLevel.value}'),
      ],
    );
  }
}
```

---

## Decision Tree

### Should I use hooks in this widget?

```
START
├─ Do I need local state or lifecycle management?
│  ├─ NO → Use StatelessWidget or ConsumerWidget
│  └─ YES → Continue
│
├─ Do I also need to watch Riverpod providers?
│  ├─ YES → Use HookConsumerWidget
│  └─ NO → Use HookWidget
│
├─ Is this state shared across multiple widgets?
│  ├─ YES → Use Riverpod Provider instead
│  └─ NO → Continue
│
├─ Is this a complex form with many fields?
│  ├─ YES → Consider StatefulWidget instead
│  └─ NO → Hooks are appropriate
│
└─ Will hooks make the code clearer?
   ├─ YES → Use hooks
   └─ NO → Use StatefulWidget
```

### Which hook should I use?

```
What do I need?
├─ Simple state value → useState
├─ Derived/computed value → useMemoized
├─ Callback that won't recreate → useCallback
├─ TextEditingController → useTextEditingController
├─ AnimationController → useAnimationController
├─ ScrollController → useScrollController
├─ TabController → useTabController
├─ FocusNode → useFocusNode
├─ PageController → usePageController
├─ Stream listening → useStream
├─ Future handling → useFuture
├─ Side effects / lifecycle → useEffect
└─ Previous value → usePrevious
```

---

## Summary: Key Takeaways

### DO:
- ✅ Use HookWidget for local state and lifecycle
- ✅ Use HookConsumerWidget when combining hooks with Riverpod
- ✅ Call hooks at the top level of build()
- ✅ Keep hook call order consistent
- ✅ Return cleanup functions from useEffect
- ✅ Include all dependencies in useEffect, useMemoized, useCallback
- ✅ Use hooks for controllers (TextEditingController, AnimationController)
- ✅ Use hooks for simple local state management

### DON'T:
- ❌ Don't use hooks in StatelessWidget or StatefulWidget
- ❌ Don't call hooks conditionally or in loops
- ❌ Don't call hooks in callbacks or nested functions
- ❌ Don't use hooks for global/shared state
- ❌ Don't use ref.watch() inside useEffect
- ❌ Don't forget cleanup in useEffect
- ❌ Don't use HookConsumerWidget when ConsumerWidget is sufficient
- ❌ Don't skip dependencies in hook dependency arrays

---

## Additional Resources

- **flutter_hooks**: https://pub.dev/packages/flutter_hooks
- **hooks_riverpod**: https://pub.dev/packages/hooks_riverpod
- **Riverpod Documentation**: https://riverpod.dev
- **React Hooks Rules** (similar concepts): https://react.dev/reference/rules/rules-of-hooks

---

## Version Information

This guide is based on:
- flutter_hooks: ^0.20.0
- hooks_riverpod: ^2.4.0
- Flutter: 3.x

Always check the latest package documentation for updates and changes.