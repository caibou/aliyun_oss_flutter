#import "FlutterAliyunOssPlugin.h"
#import "UploadService.h"

static NSString * const FileUpLoadMethodName = @"file_upload";

@implementation FlutterAliyunOssPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_aliyun_oss"
            binaryMessenger:[registrar messenger]];
  FlutterAliyunOssPlugin* instance = [[FlutterAliyunOssPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([call.method isEqualToString:FileUpLoadMethodName]) {
      if ([call.arguments isKindOfClass:[NSDictionary class]]) {
          UploadService *uploadService = [UploadService initWithMap:(NSDictionary *)call.arguments];
          if (uploadService) {
              [uploadService startWithResult:^(id resultData) {
                  dispatch_async(dispatch_get_main_queue(),^{
                      if (resultData && [resultData isKindOfClass:[NSString class]]) {
                          result(resultData);
                      } else {
                          result(nil);
                      }
                  });
              }];
          }
      }
      result(nil);
  } else {
      result(FlutterMethodNotImplemented);
  }
}

@end
