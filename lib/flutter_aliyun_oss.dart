import 'flutter_aliyun_oss_platform_interface.dart';

class OssUploadFileType {
  static int nuknow = 0;
  static int acc = 1;
  static int png = 2;
  static int jpg = 3;
  static int zip = 4;
  static int git = 5;
}

class UploadParams {
  // 文件所在的绝对路径
  String? path;
  // 文件类型
  int type = OssUploadFileType.nuknow;

  // PROTOStsGetTokenRes.token
  String? accessKey;
  String? accessSecret;
  String? securityToken;
  String? endPoint;
  String? bucketName;

  // PROTOStsGetTokenRes.file ---> filePath+fileName = objectKey;
  String? objectKey;

  Map<String, Object> toMaps() {
    return <String, Object>{
      'path': path ?? '',
      'type': type,
      'accessKey': accessKey ?? '',
      'accessSecret': accessSecret ?? '',
      'securityToken': securityToken ?? '',
      'endPoint': endPoint ?? '',
      'bucketName': bucketName ?? '',
      'objectKey': objectKey ?? '',
    };
  }
}

class FlutterAliyunOss {
  Future<String?> getPlatformVersion() {
    return FlutterAliyunOssPlatform.instance.getPlatformVersion();
  }

  Future<String?> upload(Map<String, Object> params) {
    return FlutterAliyunOssPlatform.instance.upload(params);
  }
}
