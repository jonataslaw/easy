import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'easy_store.dart';

abstract class GetState<T> extends DisposableInterface {
  GetState(T initialValue) {
    _state = initialValue;
  }

  T _state;

  final Set<StateSetter> _updaters = <StateSetter>{};

  void addListener(StateSetter value) {
    _updaters.add(value);
  }

  void removeListener(StateSetter value) {
    _updaters.add(value);
  }

  T get state => _state;

  void _getUpdate() {
    _updaters.forEach((rs) => rs(() {}));
  }

  @protected
  void update(T newState) {
    if (newState != _state) {
      _state = newState;
      _getUpdate();
    }
  }
}

class Store<T extends GetState> extends StatefulWidget {
  final Widget Function(dynamic) builder;
  final bool global;
  final String tag;
  final bool autoRemove;
  final bool assignId;
  final void Function(State state) initState, dispose, didChangeDependencies;
  final void Function(Store oldWidget, State state) didUpdateWidget;
  final T Function() state;

  const Store({
    Key key,
    this.state,
    this.global = true,
    @required this.builder,
    this.autoRemove = true,
    this.assignId = false,
    this.initState,
    this.tag,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
  })  : assert(builder != null),
        super(key: key);

  @override
  _StoreState<T> createState() => _StoreState<T>();
}

class _StoreState<T extends GetState> extends State<Store<T>> {
  T controller;

  bool isCreator = true;

  @override
  void initState() {
    super.initState();
    if (widget.initState != null) widget.initState(this);
    if (widget.global) {
      if (GetInstance().isRegistered<T>(tag: widget.tag)) {
        isCreator = false;
      }

      if (isCreator) controller?.onStart();

      controller = Easy.putOrFind(widget.state, tag: widget.tag);
      controller._updaters.add(setState);
    } else {
      controller = widget.state();
      controller._updaters.add(setState);
      controller?.onStart();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.dispose != null) widget.dispose(this);
    if (isCreator || widget.assignId) {
      if (widget.autoRemove && GetInstance().isRegistered<T>(tag: widget.tag)) {
        controller._updaters.remove(setState);
        GetInstance().delete<T>(tag: widget.tag);
      }
    } else {
      controller._updaters.remove(setState);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null) {
      widget.didChangeDependencies(this);
    }
  }

  @override
  void didUpdateWidget(Store oldWidget) {
    super.didUpdateWidget(oldWidget as Store<T>);
    if (widget.didUpdateWidget != null) {
      widget?.didUpdateWidget(oldWidget, this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(controller.state);
  }
}
