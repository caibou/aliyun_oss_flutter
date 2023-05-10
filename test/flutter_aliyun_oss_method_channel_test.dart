import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_aliyun_oss/flutter_aliyun_oss_method_channel.dart';

void main() {
  MethodChannelFlutterAliyunOss platform = MethodChannelFlutterAliyunOss();
  const MethodChannel channel = MethodChannel('flutter_aliyun_oss');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
