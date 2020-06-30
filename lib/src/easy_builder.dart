import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'easy_runner.dart';

typedef Widget EasyBuild(T Function<T>(ValueListenable<T> value) _);

class EasyBuilder extends StatefulWidget {
  EasyBuilder(this.builder, {Key key}) : super(key: key);

  final EasyBuild builder;

  @override
  _EasyBuilderState createState() => _EasyBuilderState();
}

class _EasyBuilderState extends State<EasyBuilder> {
  Widget _dirt;
  EasyRunner<Widget> _runner;

  @override
  void initState() {
    super.initState();
    _runner = EasyRunner((_, run) => widget.builder(_),
        onChange: () => setState(() => _dirt = null));
  }

  @override
  void dispose() {
    _runner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _dirt ??= _runner.run();
  }
}
