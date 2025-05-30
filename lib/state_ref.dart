import 'package:flutter/material.dart';
import 'package:syp_state_manager/state_manager.dart';
import 'package:syp_state_manager/syp_state_manager.dart';

class StateRef {
  final State _state;
  final AppStateManager _manager = AppStateManager();

  StateRef(this._state); // Watch a state (rebuilds widget when state changes)
  T watch<T extends StateModel>(T Function() create) {
    final state = _manager.watch<T>(_state, create);
    return state;
  }

  // Read a state without watching (doesn't rebuild widget)
  T? read<T extends StateModel>() {
    return _manager.read<T>();
  }

  void dispose<T extends StateModel>() {
    _manager.removeWatcher<T>(_state);
  }
}
