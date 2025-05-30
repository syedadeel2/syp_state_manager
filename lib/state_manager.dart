// Base class for all state models with auto-notification
import 'package:flutter/foundation.dart';

abstract class StateModel extends ChangeNotifier {
  bool _disposed = false;
  bool get disposed => _disposed;
  // Auto-notify when any property changes
  void _notify() {
    if (!_disposed) {
      print('StateModel notifying listeners for ${runtimeType}');
      notifyListeners();
    } else {
      print('StateModel is disposed, skipping notification for ${runtimeType}');
    }
  }

  // Protected setter that automatically notifies listeners
  void setState<T>(T Function() updater) {
    updater();
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

// Reactive property wrapper
class ReactiveProperty<T> {
  T _value;
  final VoidCallback _onChanged;

  ReactiveProperty(this._value, this._onChanged);

  T get value => _value;

  set value(T newValue) {
    if (_value != newValue) {
      print('ReactiveProperty value changed from $_value to $newValue');
      _value = newValue;
      _onChanged();
    } else {
      print('ReactiveProperty value unchanged: $newValue');
    }
  }

  // Allow updating without triggering notification (for initialization)
  void setSilent(T newValue) {
    print('ReactiveProperty setSilent: $newValue');
    _value = newValue;
  }
}

// Mixin to make properties reactive automatically
mixin ReactiveStateMixin on StateModel {
  final Map<String, ReactiveProperty> _properties = {};
  int _propertyCounter = 0;
  // Create a reactive property
  ReactiveProperty<T> reactive<T>(T initialValue, {String? key}) {
    final propertyKey = key ?? '${T}_${_propertyCounter++}';

    if (!_properties.containsKey(propertyKey)) {
      print('Creating reactive property with key: $propertyKey, initial value: $initialValue');
      _properties[propertyKey] = ReactiveProperty<T>(initialValue, _notify);
    } else {
      print('Reusing existing reactive property with key: $propertyKey');
    }

    return _properties[propertyKey] as ReactiveProperty<T>;
  }

  // Batch multiple updates without triggering multiple notifications
  void batch(VoidCallback updates) {
    // Temporarily disable notifications
    final wasDisposed = _disposed;
    _disposed = true;

    updates();

    // Re-enable and notify once
    _disposed = wasDisposed;
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _properties.clear();
    super.dispose();
  }
}
