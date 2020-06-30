import 'package:get/get.dart';

abstract class EasyStore extends DisposableInterface {}

class Easy {
  static void lazyPut<S>(FcBuilderFunc builder, {String tag}) {
    return GetInstance().lazyPut<S>(builder, tag: tag);
  }

  static Future<S> putAsync<S>(FcBuilderFuncAsync<S> builder,
          {String tag, bool permanent = false}) async =>
      GetInstance().putAsync<S>(builder, tag: tag, permanent: permanent);

  static S find<S>({String tag, FcBuilderFunc<S> instance}) =>
      GetInstance().find<S>(tag: tag, instance: instance);

  static S put<S>(S dependency,
          {String tag,
          bool permanent = false,
          bool overrideAbstract = false,
          FcBuilderFunc<S> builder}) =>
      GetInstance().put<S>(dependency,
          tag: tag,
          permanent: permanent,
          overrideAbstract: overrideAbstract,
          builder: builder);

  static bool reset(
          {bool clearFactory = true, bool clearRouteBindings = true}) =>
      GetInstance().reset(
          clearFactory: clearFactory, clearRouteBindings: clearRouteBindings);

  static Future<bool> delete<S>({String tag, String key}) async =>
      GetInstance().delete<S>(tag: tag, key: key);

  static bool isRegistred<S>({String tag}) =>
      GetInstance().isRegistred<S>(tag: tag);
}
