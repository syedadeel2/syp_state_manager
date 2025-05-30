import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syp_state_manager/syp_state_manager.dart';
import 'package:syp_state_manager/state_manager.dart';
import 'package:syp_state_manager/state_ref.dart';
import 'package:syp_state_manager/consumer_widget.dart';
import 'package:syp_state_manager/consumer_state.dart';

// Sample state model for testing
class TestCounterState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<int> _count;

  TestCounterState() {
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
    _count.setSilent(0);
  }
}

// Test states for each group to prevent cross-contamination
class AppManagerTestState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<int> _value;

  AppManagerTestState() {
    _value = reactive<int>(0, key: 'value');
  }

  int get value => _value.value;
  set value(int newValue) {
    _value.value = newValue;
  }
}

class ConsumerStateTestState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<int> _value;

  ConsumerStateTestState() {
    _value = reactive<int>(0, key: 'value');
  }

  int get value => _value.value;
  set value(int newValue) {
    _value.value = newValue;
  }
}

class ConsumerWidgetTestState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<int> _value;

  ConsumerWidgetTestState() {
    _value = reactive<int>(0, key: 'value');
  }

  int get value => _value.value;
  set value(int newValue) {
    _value.value = newValue;
  }
}

class StateRefTestState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<int> _value;

  StateRefTestState() {
    _value = reactive<int>(0, key: 'value');
  }

  int get value => _value.value;
  set value(int newValue) {
    _value.value = newValue;
  }
}

class ReactivePropertyTestState extends StateModel with ReactiveStateMixin {
  late final ReactiveProperty<int> _value;

  ReactivePropertyTestState() {
    _value = reactive<int>(0, key: 'value');
  }

  int get value => _value.value;
  set value(int newValue) {
    _value.value = newValue;
  }

  void resetValue() {
    _value.setSilent(0);
  }
}

// Sample stateful widget for testing
class TestStatefulWidget extends StatefulWidget {
  final Function(TestCounterState) onBuild;

  const TestStatefulWidget({super.key, required this.onBuild});

  @override
  State<TestStatefulWidget> createState() => _TestStatefulWidgetState();
}

class _TestStatefulWidgetState extends ConsumerState<TestStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final counterState = ref.watch<TestCounterState>(() => TestCounterState());
    widget.onBuild(counterState);

    return Container();
  }

  @override
  void dispose() {
    ref.dispose<TestCounterState>();
    super.dispose();
  }
}

// Test stateful widget that accepts specific state type
class TypedTestStatefulWidget<T extends StateModel> extends StatefulWidget {
  final Function(T) onBuild;
  final T Function() stateFactory;

  const TypedTestStatefulWidget({
    super.key,
    required this.onBuild,
    required this.stateFactory,
  });

  @override
  State<TypedTestStatefulWidget<T>> createState() => _TypedTestStatefulWidgetState<T>();
}

class _TypedTestStatefulWidgetState<T extends StateModel> extends ConsumerState<TypedTestStatefulWidget<T>> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch<T>(widget.stateFactory);
    widget.onBuild(state);

    return Container();
  }

  @override
  void dispose() {
    ref.dispose<T>();
    super.dispose();
  }
}

// Sample consumer widget for testing
class TestConsumerWidget extends ConsumerWidget {
  final Function(TestCounterState) onBuild;

  const TestConsumerWidget({super.key, required this.onBuild});

  @override
  Widget build(BuildContext context, StateRef ref) {
    final counterState = ref.watch<TestCounterState>(() => TestCounterState());
    onBuild(counterState);

    return Container();
  }
}

// Typed consumer widget for testing
class TypedTestConsumerWidget<T extends StateModel> extends ConsumerWidget {
  final Function(T) onBuild;
  final T Function() stateFactory;

  const TypedTestConsumerWidget({
    super.key,
    required this.onBuild,
    required this.stateFactory,
  });

  @override
  Widget build(BuildContext context, StateRef ref) {
    final state = ref.watch<T>(stateFactory);
    onBuild(state);

    return Container();
  }
}

// Mock State for testing
class MockState extends State {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  // Reset the singleton before each test
  setUp(() {
    final manager = AppStateManager();
    manager.reset();
  });

  group('AppStateManager Tests', () {
    test('AppStateManager is a singleton', () {
      final instance1 = AppStateManager();
      final instance2 = AppStateManager();

      expect(identical(instance1, instance2), true);
    });

    group('State creation and reading', () {
      test('AppStateManager can create and store states', () {
        final manager = AppStateManager();

        // Read a non-existent state
        final nullState = manager.read<AppManagerTestState>();
        expect(nullState, null);

        // Create a mock state reference
        final mockState = MockState();

        // Watch creates a new state
        final testState = manager.watch<AppManagerTestState>(mockState, () => AppManagerTestState());

        expect(testState, isA<AppManagerTestState>());
        expect(testState.value, 0);

        // Read now returns the state
        final readState = manager.read<AppManagerTestState>();
        expect(readState, isNotNull);
        expect(identical(readState, testState), true);
      });
    });

    group('ConsumerState widget integration tests', () {
      testWidgets('ConsumerState properly watches state changes', (WidgetTester tester) async {
        ConsumerStateTestState? capturedState;
        int buildCount = 0;

        await tester.pumpWidget(MaterialApp(
          home: TypedTestStatefulWidget<ConsumerStateTestState>(
            stateFactory: () => ConsumerStateTestState(),
            onBuild: (state) {
              capturedState = state;
              buildCount++;
            },
          ),
        ));

        expect(capturedState, isNotNull);
        expect(capturedState!.value, 0);
        expect(buildCount, 1);

        // Trigger state change
        capturedState!.value = 1;
        await tester.pump();

        expect(capturedState!.value, 1);
        expect(buildCount, 2); // Should rebuild
      });
    });

    group('ConsumerWidget integration tests', () {
      testWidgets('ConsumerWidget properly watches state changes', (WidgetTester tester) async {
        ConsumerWidgetTestState? capturedState;
        int buildCount = 0;

        await tester.pumpWidget(MaterialApp(
          home: TypedTestConsumerWidget<ConsumerWidgetTestState>(
            stateFactory: () => ConsumerWidgetTestState(),
            onBuild: (state) {
              capturedState = state;
              buildCount++;
            },
          ),
        ));

        expect(capturedState, isNotNull);
        expect(capturedState!.value, 0);
        expect(buildCount, 1);

        // Trigger state change
        capturedState!.value = 1;
        await tester.pump();

        expect(capturedState!.value, 1);
        expect(buildCount, 2); // Should rebuild
      });
    });

    group('Reading without watching', () {
      testWidgets('StateRef.read does not trigger rebuilds', (WidgetTester tester) async {
        StateRefTestState? watchedState;
        int buildCount = 0;

        // Create a widget that reads (doesn't watch) the state
        final testWidget = StatefulBuilder(builder: (context, setState) {
          return MaterialApp(
            home: Builder(builder: (context) {
              return TextButton(
                onPressed: () {
                  setState(() {
                    // Force rebuild to test if read triggers notification
                    buildCount++;
                  });
                },
                child: const Text('Rebuild'),
              );
            }),
          );
        });

        await tester.pumpWidget(testWidget);

        // Create and initialize state
        final stateManager = AppStateManager();
        final mockState = MockState();
        watchedState = stateManager.watch<StateRefTestState>(mockState, () => StateRefTestState());

        // Initial state
        expect(watchedState.value, 0);

        // Change state
        watchedState.value = 1;
        await tester.pump();

        // Verify state was updated
        expect(watchedState.value, 1);

        // Before triggering a rebuild, buildCount should be 0
        expect(buildCount, 0);

        // Trigger rebuild by tapping the button
        await tester.tap(find.byType(TextButton));
        await tester.pump();

        // Read should get updated value
        final readState = stateManager.read<StateRefTestState>();
        expect(readState, isNotNull);
        expect(readState!.value, 1);

        // After manually triggering, buildCount should be 1
        expect(buildCount, 1);
      });
    });

    group('ReactiveProperty tests', () {
      test('ReactiveProperty correctly updates values', () {
        final state = ReactivePropertyTestState();
        expect(state.value, 0);

        // Normal update with notification
        state.value = 5;
        expect(state.value, 5);

        // Reset using setSilent (no notification)
        state.resetValue();
        expect(state.value, 0);
      });
    });

    group('Multiple ReactiveProperties tests', () {
      test('Multiple ReactiveProperties in one state', () {
        final navState = BottomNavigationState();

        expect(navState.notificationUnreadCount, 0);
        expect(navState.pendingDataRequestCount, 0);

        navState.notificationUnreadCount = 5;
        navState.pendingDataRequestCount = 3;

        expect(navState.notificationUnreadCount, 5);
        expect(navState.pendingDataRequestCount, 3);

        navState.reset();

        expect(navState.notificationUnreadCount, 0);
        expect(navState.pendingDataRequestCount, 0);
      });
    });
  });
}

// Sample state with multiple reactive properties for testing
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
