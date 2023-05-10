import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_aliyun_oss/flutter_aliyun_oss.dart';
import 'package:flutter_aliyun_oss/flutter_aliyun_oss_platform_interface.dart';
import 'package:flutter_aliyun_oss/flutter_aliyun_oss_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAliyunOssPlatform
    with MockPlatformInterfaceMixin
    implements FlutterAliyunOssPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterAliyunOssPlatform initialPlatform = FlutterAliyunOssPlatform.instance;

  test('$MethodChannelFlutterAliyunOss is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterAliyunOss>());
  });

  test('getPlatformVersion', () async {
    FlutterAliyunOss flutterAliyunOssPlugin = FlutterAliyunOss();
    MockFlutterAliyunOssPlatform fakePlatform = MockFlutterAliyunOssPlatform();
    FlutterAliyunOssPlatform.instance = fakePlatform;

    expect(await flutterAliyunOssPlugin.getPlatformVersion(), '42');
  });
}
