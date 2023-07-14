//
//  UploadService.m
//  flutter_aliyun_oss
//
//  Created by PC on 2023/5/10.
//

#import "UploadService.h"
#import "NetworkServiceManager.h"
#import <AliyunOSSiOS/OSSService.h>

#define CHECK_STR(x) (!(x) || ([x length]) <= 0)

@interface UploadService()

@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *accessSecret;
@property (nonatomic, copy) NSString *securityToken;
@property (nonatomic, copy) NSString *endPoint;
@property (nonatomic, copy) NSString *bucketName;
@property (nonatomic, copy) NSString *objectKey;

@end

@implementation UploadService

+ (instancetype)initFormMap:(NSDictionary *)arguments {
    if (!arguments) {
        return nil;
    }
    
    UploadService *model = [UploadService new];
    model.path = [arguments objectForKey:@"path"];
    model.accessKey = [arguments objectForKey:@"accessKey"];
    model.accessSecret = [arguments objectForKey:@"accessSecret"];
    model.securityToken = [arguments objectForKey:@"securityToken"];
    model.endPoint = [arguments objectForKey:@"endPoint"];
    model.bucketName = [arguments objectForKey:@"bucketName"];
    model.objectKey = [arguments objectForKey:@"objectKey"];
    
    return model;
}

- (BOOL)checkParam {
    bool base = CHECK_STR(self.path);
    bool token = CHECK_STR(self.accessKey) || CHECK_STR(self.accessSecret) || CHECK_STR(self.securityToken);
    bool config = CHECK_STR(self.endPoint) || CHECK_STR(self.bucketName) || CHECK_STR(self.objectKey);
    
    return base || token || config;
}

- (void)startWithResult:(void (^)(id resultData))result {
    if ([self checkParam]) {
        result(nil);
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf uploadWithCompletion:^(id res, NSError *error) {
            if (error || (CHECK_STR(res) || ![res isKindOfClass:[NSString class]])) {
                result(nil);
            } else {
                result(res);
            }
        } withUploadProgress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            
        }];
    });
    
}

- (OSSClient *)createOSSClient {
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:self.accessKey
                                                                                          secretKeyId:self.accessSecret
                                                                                        securityToken:self.securityToken];
    return [[OSSClient alloc] initWithEndpoint:self.endPoint credentialProvider:credential clientConfiguration:[OSSClientConfiguration new]];
}

- (void)uploadWithCompletion:(void (^)(id res, NSError *error))completion withUploadProgress:(OSSNetworkingUploadProgressBlock)uploadProgress {
    
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.bucketName = self.bucketName;
    put.objectKey = self.objectKey;
    put.uploadingData = [self getFileData:self.path];
    
    if (!put.uploadingData || put.uploadingData.length <= 0) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"" code:-3 userInfo:nil]);
        }
    }
    
    put.uploadProgress = uploadProgress;
    
    OSSClient *client = [self createOSSClient];
    
    OSSTask *putTask = [client putObject:put];
    
    __weak __typeof__(self) weakSelf = self;
    [[putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!task.error) {
            OSSTask* taskResult = [client presignPublicURLWithBucketName:strongSelf.bucketName withObjectKey:self.objectKey];
            if (completion) {
                completion(taskResult.result, nil);
            }
        } else {
            if (completion) {
                completion(nil, task.error);
            }
        }
        
        return nil;
    }] waitUntilFinished];
}

- (NSData *)getFileData:(NSString *)path {
    return [NSData dataWithContentsOfFile:path];
}

@end
