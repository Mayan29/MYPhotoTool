//
//  MYPhotoTool.h
//  保存图片到相册
//
//  Created by mayan on 2016/12/26.
//  Copyright © 2016年 mayan. All rights reserved.
//
//
//  调用此类之前在 info.plist 中添加以下字段
//  Privacy - Photo Library Usage Description
//  Privacy - Camera Usage Description

#import <UIKit/UIKit.h>

@interface MYPhotoTool : NSObject



// 保存图片到自定义相册
+ (void)saveToCollectionWithImage:(UIImage *)image completion:(void(^)(BOOL success))completion;
+ (void)saveToCollectionWithImage:(UIImage *)image andCollectionName:(NSString *)collectionName completion:(void(^)(BOOL success))completion;


// 同步/异步保存图片到【相机胶卷】
+ (NSString *)saveWithImage:(UIImage *)image;
+ (void)saveWithImage:(UIImage *)image completion:(void(^)(NSString *))completion;




@end
