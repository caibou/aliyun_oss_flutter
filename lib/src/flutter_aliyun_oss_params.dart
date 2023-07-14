class UploadParams {
  // 文件所在的绝对路径
  String? path;
  String? accessKey;
  String? accessSecret;
  String? securityToken;
  String? endPoint;
  String? bucketName;

  String? objectKey;


  UploadParams({this.path, this.accessKey, this.accessSecret, this.securityToken,
      this.endPoint, this.bucketName, this.objectKey});

  Map<String, dynamic> toMaps() {
    return <String, dynamic>{
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