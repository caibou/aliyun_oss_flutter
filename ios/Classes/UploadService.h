//
//  UploadModel.h
//  flutter_aliyun_oss
//
//  Created by PC on 2023/5/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int32_t, UploadFileType) {
    UploadFileType_Unknow = 0,
    /** 音频格式 - AAC */
    UploadFileType_AAC = 1,
    /** 图片格式 - PNG */
    UploadFileType_PNG = 2,
    /** 图片格式 - JPG */
    UploadFileType_JPG = 3,
    UploadFileType_ZIP = 4,
    UploadFileType_GIF = 5,
};


@interface UploadService : NSObject

+ (instancetype)initWithMap:(NSDictionary *)arguments;

- (void)startWithResult:(void (^)(id resultData))result;

@end

NS_ASSUME_NONNULL_END
