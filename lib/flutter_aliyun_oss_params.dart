class UploadParams {
  // 文件所在的绝对路径
  String? path;
  // 文件类型
  // PROTOStsGetTokenRes.token
  String? accessKey;
  String? accessSecret;
  String? securityToken;
  String? endPoint;
  String? bucketName;

  String? objectKey;

  Map<String, Object> toMaps() {
    return <String, Object>{
      'path': path ?? '',
      'accessKey': accessKey ?? '',
      'accessSecret': accessSecret ?? '',
      'securityToken': securityToken ?? '',
      'endPoint': endPoint ?? '',
      'bucketName': bucketName ?? '',
      'objectKey': objectKey ?? '',
    };
  }
}