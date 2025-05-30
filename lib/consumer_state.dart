import 'package:flutter/material.dart';
import 'package:syp_state_manager/state_ref.dart';

abstract class ConsumerState<T extends StatefulWidget> extends State<T> {
  late StateRef ref;

  @override
  void initState() {
    super.initState();
    ref = StateRef(this);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
