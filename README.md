# SYP (Simple Yet Powerful) State Manager

A lightweight, efficient state management solution for Flutter applications. SYP State Manager provides a simple way to manage application state with minimal boilerplate code, making it easy to share and update state across your widgets.

## Features

- **Simple API**: Easy-to-use interface with minimal learning curve
- **Efficient Updates**: Only rebuilds widgets that are watching a particular state
- **Global State Access**: Access state from anywhere in your application
- **Type-Safe**: Fully typed state management for better developer experience
- **No Context Required**: Read states without BuildContext
- **Performance Optimized**: Minimizes unnecessary rebuilds

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  syp_state_manager: ^1.0.0
```

Then run:

```bash
flutter pub get
```

Import the package in your Dart code:

```dart
import 'package:syp_state_manager/syp_state_manager.dart';
```

## Usage

### 1. Create a State Model

First, create a state model by extending `StateModel` and using `ReactiveStateMixin`:

```dart
import 'package:syp_state_manager/state_manager.dart';

class CounterState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<int> _count;
  
  CounterState() {
    _count = reactive<int>(0, key: 'count');
  }
  
  int get count => _count.value;
  
  set count(int value) {
    _count.value = value;
  }
  
  void increment() {
    count = count + 1;
  }
  
  void reset() {
    _count.setSilent(0); // Update without notification
  }
}
```

### 2. Using with StatefulWidget

Use the `ConsumerState` class to manage state in stateful widgets:

```dart
import 'package:flutter/material.dart';
import 'package:syp_state_manager/consumer_state.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends ConsumerState<CounterPage> {
  @override
  Widget build(BuildContext context) {
    // Watch the counter state - this will rebuild when state changes
    final counterState = ref.watch<CounterState>(() => CounterState());
    
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Center(
        child: Text(
          'Count: ${counterState.count}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counterState.increment();  // Update state
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  @override
  void dispose() {
    ref.dispose<CounterState>();  // Clean up state references
    super.dispose();
  }
}
```

### 3. Using with ConsumerWidget (Stateless approach)

For a more streamlined approach, use the `ConsumerWidget` class:

```dart
import 'package:flutter/material.dart';
import 'package:syp_state_manager/consumer_widget.dart';
import 'package:syp_state_manager/state_ref.dart';

class CounterView extends ConsumerWidget {
  const CounterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, StateRef ref) {
    // Watch the counter state
    final counterState = ref.watch<CounterState>(() => CounterState());
    
    return Scaffold(
      appBar: AppBar(title: const Text('Consumer Widget Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Count: ${counterState.count}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                counterState.increment();
              },
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Reading State Without Watching

You can also read state without subscribing to updates:

```dart
import 'package:flutter/material.dart';
import 'package:syp_state_manager/consumer_widget.dart';
import 'package:syp_state_manager/state_ref.dart';

class ReadOnlyCounterButton extends ConsumerWidget {
  const ReadOnlyCounterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, StateRef ref) {
    // This widget won't rebuild when CounterState changes
    return ElevatedButton(
      onPressed: () {
        // Read state without watching
        final counterState = ref.read<CounterState>();
        if (counterState != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Current count: ${counterState.count}')),
          );
        }
      },
      child: const Text('Show Current Count'),
    );
  }
}
```

## Advanced Usage

### Multiple Reactive Properties

You can define multiple reactive properties in a single state model:

```dart
import 'package:syp_state_manager/state_manager.dart';

class BottomNavigationState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<int> _notificationUnreadCount;
  late final ReactiveProperty<int> _pendingDataRequestCount;

  BottomNavigationState() {
    _notificationUnreadCount = reactive<int>(0, key: 'notificationUnreadCount');
    _pendingDataRequestCount = reactive<int>(0, key: 'pendingDataRequestCount');
  }

  int get notificationUnreadCount => _notificationUnreadCount.value;
  set notificationUnreadCount(int count) {
    _notificationUnreadCount.value = count;
  }

  int get pendingDataRequestCount => _pendingDataRequestCount.value;
  set pendingDataRequestCount(int count) {
    _pendingDataRequestCount.value = count;
  }

  void reset() {
    _notificationUnreadCount.setSilent(0);
    _pendingDataRequestCount.setSilent(0);
  }
}
```

Usage example:

```dart
import 'package:flutter/material.dart';
import 'package:syp_state_manager/consumer_widget.dart';
import 'package:syp_state_manager/state_ref.dart';

class NavigationBar extends ConsumerWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, StateRef ref) {
    final navState = ref.watch<BottomNavigationState>(() => BottomNavigationState());
    
    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('${navState.notificationUnreadCount}'),
            isLabelVisible: navState.notificationUnreadCount > 0,
            child: const Icon(Icons.notifications),
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('${navState.pendingDataRequestCount}'),
            isLabelVisible: navState.pendingDataRequestCount > 0,
            child: const Icon(Icons.sync),
          ),
          label: 'Sync',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          // Reset notification count when navigating to notifications
          navState.notificationUnreadCount = 0;
        } else if (index == 2) {
          // Reset pending requests when navigating to sync
          navState.pendingDataRequestCount = 0;
        }
      },
    );
  }
}
```

### Creating a Provider Widget

You can create a provider widget to initialize state at the app level:

```dart
import 'package:flutter/material.dart';
import 'package:syp_state_manager/consumer_widget.dart';
import 'package:syp_state_manager/state_ref.dart';

class AppStateProvider extends ConsumerWidget {
  final Widget child;

  const AppStateProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, StateRef ref) {
    // Initialize your global states
    ref.watch<CounterState>(() => CounterState());
    // Initialize other states as needed
    
    return child;
  }
}

// Use it in your app
void main() {
  runApp(
    AppStateProvider(
      child: MyApp(),
    ),
  );
}
```

### Combining Multiple States

Working with multiple states is straightforward:

```dart
import 'package:flutter/material.dart';
import 'package:syp_state_manager/consumer_widget.dart';
import 'package:syp_state_manager/state_ref.dart';
import 'package:syp_state_manager/state_manager.dart';

class ThemeState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<bool> _isDarkMode;
  
  ThemeState() {
    _isDarkMode = reactive<bool>(false, key: 'isDarkMode');
  }
  
  bool get isDarkMode => _isDarkMode.value;
  
  set isDarkMode(bool value) {
    _isDarkMode.value = value;
  }
  
  void toggleTheme() {
    isDarkMode = !isDarkMode;
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, StateRef ref) {
    final counterState = ref.watch<CounterState>(() => CounterState());
    final themeState = ref.watch<ThemeState>(() => ThemeState());
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeState.isDarkMode,
            onChanged: (_) => themeState.toggleTheme(),
          ),
          ListTile(
            title: Text('Counter Value: ${counterState.count}'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => counterState.increment(),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Additional information

### When to use

SYP State Manager is ideal for:

- Small to medium-sized applications
- Applications where you need simple state management without complex architecture
- Projects where you want to avoid the boilerplate of larger state management solutions

### Contribution

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License - see the LICENSE file for details.
