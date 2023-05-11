//
//  UploadService.m
//  flutter_aliyun_oss
//
//  Created by PC on 2023/5/10.
//

#import "UploadService.h"
#import "UresExt.pbobjc.h"
#import "RpcMessageExt.pbobjc.h"
#import "NetworkServiceManager.h"
#import "UIImage+FixOrientation.h"
#import <AliyunOSSiOS/OSSService.h>

static NSString * const DefaultEndPoint = @"https://oss-cn-shenzhen.aliyuncs.com/";

@interface UploadService()

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSNumber *fileType;
@property (nonatomic, strong) NSNumber *uploadType;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, strong) NSString *functionName;

@end

@implementation UploadService

+ (instancetype)initFormMap:(NSDictionary *)arguments {
    if (!arguments) {
        return nil;
    }
    UploadService *model = [UploadService new];
    model.path = [arguments objectForKey:@"filePath"];
    model.fileType = [arguments objectForKey:@"fileType"];
    model.uploadType = [arguments objectForKey:@"uploadType"];
    return model;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.serviceName = @"chikii.ures.UresExtObj";
        self.functionName = @"StsGetToken";
    }
    return self;
}

- (UploadFileType)getFileTypeValue {
    UploadFileType fileType = UploadFileType_Unknow;
    if (self.fileType) {
        return (UploadFileType)self.fileType.intValue;
    }
    return fileType;
}

- (PROTOUploadType)getUploadTypeValue {
    PROTOUploadType uploadType = PROTOUploadType_TypeZero;
    if (self.uploadType) {
        return (PROTOUploadType)self.uploadType.intValue;
    }
    return uploadType;
}

- (void)startWithResult:(void (^)(id resultData))result {
    if (!self.path || (self.path.length <= 0) || !self.fileType || !self.uploadType) {
        result(nil);
    } else {
        
        switch([self getUploadTypeValue]) {
            case PROTOUploadType_HeadIconImg:
            case PROTOUploadType_ClientLog:
                break;
            default: {
                result(nil);
                return;
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @weakify(self)
            [self getUploadTokenWithCompletion:^(OSSClient *client, PROTOStsGetTokenRes *tokenRes, NSError *error) {
                @strongify(self)
                if (error) {
                    result(nil);
                }
                            
                [self uploadWithClient:client WithTokenRes:tokenRes WithCompletion:^(id res, NSError *error) {
                    if (error || (!res || ![res isKindOfClass:[NSString class]])) {
                        result(nil);
                    } else {
                        result(SAFE_STRING(res));
                    }
                }];
            }];
        });
    }
}

- (void)getUploadTokenWithCompletion:(void (^)(OSSClient *client,PROTOStsGetTokenRes *tokenRes, NSError *error))completion {
    PROTOStsGetTokenReq *req = [PROTOStsGetTokenReq message];
    req.uploadType           = [self getUploadTypeValue];
    
    @weakify(self)
    [[NetworkServiceManager sharedInstance] sendRequestWithReq:req
                                                      rspClass:[PROTOStsGetTokenRes class]
                                                   ServiceName:self.serviceName
                                                  functionName:self.functionName
                                                    completion:^(PROTOStsGetTokenRes *rsp, NetworkServiceError *error, ServiceWupStatInfo *info) {
        @strongify(self)
        if ([error hasError] || !rsp.hasToken) {
            if (completion) {
                if (!error.error) {
                    error.error = [NSError errorWithDomain:@"" code:-2 userInfo:nil];
                }
                completion(nil, nil, error.error);
            }
            return;
        }

        PROTOStsGetTokenRes *tokenRes = rsp;
        id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:tokenRes.token.accessKeyId
                                                                                              secretKeyId:tokenRes.token.accessKeySecret
                                                                                            securityToken:tokenRes.token.securityToken];
        
        OSSClientConfiguration *conf = [OSSClientConfiguration new];
        
        if(!tokenRes.token.endpoint || tokenRes.token.endpoint.length <= 0) {
            tokenRes.token.endpoint = DefaultEndPoint;
        }
        
        OSSClient *client = [[OSSClient alloc] initWithEndpoint:tokenRes.token.endpoint credentialProvider:credential clientConfiguration:conf];
        
        if (completion) {
            completion(client, tokenRes, nil);
        }
        
    }];
}

- (void)uploadWithClient:(OSSClient *)client WithTokenRes:(PROTOStsGetTokenRes *)tokenRes WithCompletion:(void (^)(id res, NSError *error))completion {
    
    NSString *fileUrl = [[NSString stringWithFormat:@"%@%@", tokenRes.file.filePath, tokenRes.file.fileName] stringByAppendingPathExtension:[self getFilePathExtensionWithType:[self getFileTypeValue]]];
    
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.bucketName = tokenRes.token.bucketName;
    put.objectKey = fileUrl;
    put.uploadingData = [self getFileData:self.path];
    put.callbackParam = [self getCallbackBody:tokenRes fileUrl:fileUrl];
    
    if (!put.uploadingData || put.uploadingData.length <= 0) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"" code:-3 userInfo:nil]);
        }
    }
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        DYLogInfo(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask * putTask = [client putObject:put];
    [[putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!task.error) {
                OSSTask* taskResult = [client presignPublicURLWithBucketName:tokenRes.token.bucketName withObjectKey:fileUrl];
                if (completion) {
                    completion(taskResult.result, nil);
                }
            }
            else {
                if (completion) {
                    completion(nil, task.error);
                }
            }
        });
        return nil;
    }] waitUntilFinished];
}

- (NSData *)getFileData:(NSString *)path {
    NSData *data = nil;
    switch([self getFileTypeValue]) {
        case UploadFileType_AAC:
        case UploadFileType_ZIP: {
            data = [NSData dataWithContentsOfFile:path];
            break;
        }
        case UploadFileType_PNG:
        case UploadFileType_GIF:
        case UploadFileType_JPG: {
            data = [UIImage imageWithContentsOfFile:path];
            break;
        }
        default:
            break;
    }
    return data;
}

- (NSString *)getFilePathExtensionWithType:(UploadFileType)type {
    NSString * pathExtension;
    switch (type) {
        case UploadFileType_AAC: {
            pathExtension = @"aac";
            break;
        }
        case UploadFileType_PNG: {
            pathExtension = @"png";
            break;
        }
        case UploadFileType_JPG: {
            pathExtension = @"jpeg";
            break;
        }
        case UploadFileType_ZIP: {
            pathExtension = @"zip";
            break;
        }
        case UploadFileType_GIF: {
            pathExtension = @"gif";
            break;
        }
        default:
            break;
    }
    return pathExtension;
}

- (NSString *)jsonStringEncoded:(NSDictionary *)body {
    if ([NSJSONSerialization isValidJSONObject:body]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSDictionary *)getCallbackBody:(PROTOStsGetTokenRes *)tokenRes fileUrl:(NSString *)fileUrl {
    NSMutableDictionary *opt = [NSMutableDictionary dictionary];
    opt[@"file_url"]         = fileUrl;
    opt[@"session_key"]      = tokenRes.token.sessionKey;
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    PROTORPCInput *input = [[PROTORPCInput alloc] init];
    input.obj            = self.serviceName;
    input.func           = self.functionName;
    input.opt            = opt;
    
    PROTOStsGetTokenReq *req = [PROTOStsGetTokenReq message];
    req.uploadType = [self getUploadTypeValue];
    input.req = [((GPBMessage*)req) data];
    
    NSString *base64Str = [[input data] base64EncodedStringWithOptions:0];
    
    [body safeSetObject:base64Str forKey:@"data"];
    [body safeSetObject:self.uploadType forKey:@"upload_type"];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result safeSetObject:[self jsonStringEncoded:body] forKey:@"callbackBody"];
    [result safeSetObject:tokenRes.token.callbackURL forKey:@"callbackUrl"];
    
    return result;
}

@end
