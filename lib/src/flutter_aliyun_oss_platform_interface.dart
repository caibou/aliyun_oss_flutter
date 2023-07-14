import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_aliyun_oss_method_channel.dart';
import 'flutter_aliyun_oss_params.dart';


abstract class FlutterAliyunOssPlatform extends PlatformInterface {
  /// Constructs a FlutterAliyunOssPlatform.
  FlutterAliyunOssPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAliyunOssPlatform _instance = MethodChannelFlutterAliyunOss();

  /// The default instance of [FlutterAliyunOssPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAliyunOss].
  static FlutterAliyunOssPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAliyunOssPlatform] when
  /// they register themselves.
  static set instance(FlutterAliyunOssPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> upload(UploadParams params) {
       throw UnimplementedError('platformVersion() has not been implemented.'); 
  }
}
