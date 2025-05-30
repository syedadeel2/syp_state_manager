import 'package:flutter/material.dart';
import 'package:syp_state_manager/state_manager.dart';

class AppStateManager {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  final Map<Type, StateModel> _states = {};
  final Map<Type, Set<State>> _watchers = {};
  final Map<Type, bool> _listenersInitialized = {};
  // Get or create a state
  T watch<T extends StateModel>(State state, T Function() create) {
    final type = T;

    // Create state if it doesn't exist
    if (!_states.containsKey(type)) {
      _states[type] = create();
    }

    // Add this widget as a watcher
    _watchers[type] ??= <State>{};
    _watchers[type]!.add(state);

    // Add listener immediately if not already added
    addListener<T>(state);

    return _states[type] as T;
  }

  // Add listener for state changes
  void addListener<T extends StateModel>(State state) {
    final type = T;
    final stateModel = _states[type];

    if (stateModel != null && (_listenersInitialized[type] != true)) {
      debugPrint('Adding listener for state type: $type');

      stateModel.addListener(() {
        debugPrint('State changed for type: $type, notifying ${_watchers[type]?.length ?? 0} watchers');

        notifyWatchers<T>();
      });
      _listenersInitialized[type] = true;
    }
  }

  // Remove watcher when widget disposes
  void removeWatcher<T extends StateModel>(State state) {
    final type = T;
    _watchers[type]?.remove(state);

    // Don't auto-dispose state - keep it alive for app lifetime
    // States will be manually disposed when the app closes
  } // Notify all watchers of a specific state type

  void notifyWatchers<T extends StateModel>() {
    final type = T;
    final watchers = _watchers[type];
    debugPrint('Notifying watchers for type: $type, watchers count: ${watchers?.length ?? 0}');

    if (watchers != null) {
      // Create a copy to avoid concurrent modification
      final watchersCopy = watchers.toList();

      for (final watcher in watchersCopy) {
        if (watcher.mounted) {
          debugPrint('Triggering rebuild for watcher: ${watcher.runtimeType}');
          // Force immediate rebuild
          try {
            (watcher as dynamic).setState(() {});
          } catch (e) {
            debugPrint('Failed to call setState directly, using post frame callback: $e');
            // If setState fails, try post frame callback
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (watcher.mounted) {
                try {
                  (watcher as dynamic).setState(() {});
                } catch (e) {
                  debugPrint('Failed to call setState in post frame callback: $e');
                  // Remove problematic watcher
                  _watchers[type]?.remove(watcher);
                }
              }
            });
          }
        } else {
          debugPrint('Removing unmounted watcher: ${watcher.runtimeType}');
          // Remove unmounted watchers
          _watchers[type]?.remove(watcher);
        }
      }
    }
  }

  // Get existing state without watching
  T? read<T extends StateModel>() {
    return _states[T] as T?;
  }

  void dispose() {
    for (var state in _states.values) {
      state.dispose();
    }
    _states.clear();
    _watchers.clear();
  }

  // Reset clears all state
  void reset() {
    dispose();
    _listenersInitialized.clear();
  }
}
