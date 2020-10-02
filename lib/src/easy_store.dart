import 'package:flutter/scheduler.dart';
import 'package:get_instance/get_instance.dart';

abstract class EasyStore extends GetLifeCycle {
  bool _initialized = false;

  /// Checks whether the controller has already been initialized.
  bool get initialized => _initialized;

  EasyStore() {
    onStart.callback = _onStart;
  }

  // Internal callback that starts the cycle of this controller.
  void _onStart() {
    onInit();
    _initialized = true;
    SchedulerBinding.instance?.addPostFrameCallback((_) => onReady());
  }
}

class Easy {
  static void lazyPut<S>(InstanceBuilderCallback builder, {String tag}) {
    return GetInstance().lazyPut<S>(builder, tag: tag);
  }

  static Future<S> putAsync<S>(AsyncInstanceBuilderCallback<S> builder,
          {String tag, bool permanent = false}) async =>
      GetInstance().putAsync<S>(builder, tag: tag, permanent: permanent);

  static S find<S>({String tag, InstanceBuilderCallback<S> instance}) =>
      GetInstance().find<S>(tag: tag);

  static S put<S>(S dependency,
          {String tag,
          bool permanent = false,
          bool overrideAbstract = false,
          InstanceBuilderCallback<S> builder}) =>
      GetInstance()
          .put<S>(dependency, tag: tag, permanent: permanent, builder: builder);

  static bool reset(
          {bool clearFactory = true, bool clearRouteBindings = true}) =>
      GetInstance().reset(
          clearFactory: clearFactory, clearRouteBindings: clearRouteBindings);

  static Future<bool> delete<S>({String tag, String key}) async =>
      GetInstance().delete<S>(tag: tag, key: key);

  static bool isRegistered<S>({String tag}) =>
      GetInstance().isRegistered<S>(tag: tag);

  static S putOrFind<S>(S Function() dep, {String tag}) {
    if (GetInstance().isRegistered<S>(tag: tag) ||
        GetInstance().isPrepared<S>(tag: tag)) {
      return find<S>(tag: tag);
    } else {
      return put(dep(), tag: tag);
    }
  }
}
