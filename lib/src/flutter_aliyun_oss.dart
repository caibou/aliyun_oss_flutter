import 'flutter_aliyun_oss_platform_interface.dart';
import 'flutter_aliyun_oss_params.dart';

class FlutterAliyunOss {

  Future<String?> upload(UploadParams params) {
    return FlutterAliyunOssPlatform.instance.upload(params);
  }
}
