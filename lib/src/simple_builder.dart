import 'dart:collection';
import 'package:flutter/material.dart';

typedef GetStateUpdate = void Function();

class SimpleBuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;

  const SimpleBuilder({Key key, @required this.builder})
      : assert(builder != null),
        super(key: key);

  @override
  _SimpleBuilderState createState() => _SimpleBuilderState();
}

mixin GetStateUpdaterMixin<T extends StatefulWidget> on State<T> {
  /// Experimental method to replace setState((){});
  /// Used with GetStateUpdate.
  void getUpdate() {
    if (mounted) setState(() {});
  }
}

class _SimpleBuilderState extends State<SimpleBuilder>
    with GetStateUpdaterMixin {
  final HashSet<VoidCallback> disposers = HashSet<VoidCallback>();

  @override
  void dispose() {
    super.dispose();
    for (final disposer in disposers) {
      disposer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TaskManager.instance.exchange(
      disposers,
      getUpdate,
      widget.builder,
      context,
    );
  }
}

class TaskManager {
  TaskManager._();

  static TaskManager _instance;

  static TaskManager get instance => _instance ??= TaskManager._();

  GetStateUpdate _setter;

  HashSet<VoidCallback> _remove;

  void notify(HashSet<GetStateUpdate> _updaters) {
    if (_setter != null) {
      if (!_updaters.contains(_setter)) {
        _updaters.add(_setter);
        _remove.add(() => _updaters.remove(_setter));
      }
    }
  }

  Widget exchange(
    HashSet<VoidCallback> disposers,
    GetStateUpdate setState,
    Widget Function(BuildContext) builder,
    BuildContext context,
  ) {
    _remove = disposers;
    _setter = setState;
    final result = builder(context);
    _remove = null;
    _setter = null;
    return result;
  }
}
