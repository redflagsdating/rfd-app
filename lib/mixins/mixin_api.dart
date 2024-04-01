// ignore_for_file: use_build_context_synchronously

import 'package:cloud_functions/cloud_functions.dart';

const defaultRegion = "australia-southeast1";

mixin MixinApi {
  Future<HttpsCallableResult<List<Object?>>> addUserNewConnections(
      [String? region]) async {
    return await FirebaseFunctions.instanceFor(
      region: region ?? defaultRegion,
    ).httpsCallable("addUserNewConnections").call<List<Object?>>();
  }
}
