import 'package:flutter/material.dart';
import 'package:syp_state_manager/consumer_state.dart';
import 'package:syp_state_manager/state_ref.dart';

abstract class ConsumerWidget extends StatefulWidget {
  const ConsumerWidget({super.key});

  Widget build(BuildContext context, StateRef ref);

  @override
  ConsumerState createState() => _ConsumerWidgetState();
}

class _ConsumerWidgetState extends ConsumerState<ConsumerWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.build(context, ref);
  }
}
