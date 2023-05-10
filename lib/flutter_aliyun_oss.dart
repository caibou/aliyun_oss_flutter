import 'flutter_aliyun_oss_platform_interface.dart';

class OssUploadFileType {
  static int nuknow = 0;
  static int acc = 1;
  static int png = 2;
  static int jpg = 3;
  static int zip = 4;
  static int git = 5;
}

/* 定义来自 UresExt -> PROTOUploadType  */
class OssUploadType {
  static int nuknow = 0;
  static int headIconImg = 2;
  static int clientLog = 4;
}

class FlutterAliyunOss {
  Future<String?> getPlatformVersion() {
    return FlutterAliyunOssPlatform.instance.getPlatformVersion();
  }

  Future<String?> upload(String filePath, int fileType, int uploadType) {
    return FlutterAliyunOssPlatform.instance
        .upload(filePath, fileType, uploadType);
  }
}
