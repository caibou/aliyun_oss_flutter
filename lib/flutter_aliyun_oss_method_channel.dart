import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_aliyun_oss_params.dart';
import 'flutter_aliyun_oss_platform_interface.dart';

/// An implementation of [FlutterAliyunOssPlatform] that uses method channels.
class MethodChannelFlutterAliyunOss extends FlutterAliyunOssPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_aliyun_oss');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> upload(UploadParams params) async {
    return await methodChannel.invokeMethod<Map<String,Object>>('file_upload',params.toMaps());
  }
}
