//
//  MYPhotoTool.m
//  保存图片到相册
//
//  Created by mayan on 2016/12/26.
//  Copyright © 2016年 mayan. All rights reserved.
//

#import "MYPhotoTool.h"
#import <Photos/Photos.h>


@implementation MYPhotoTool



#pragma mark - 0.请求/检查访问权限

+ (void)setAccessAuthorityWithCompletion:(void(^)())completion
{
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    
    // 如果用户还没有做出选择，会自动弹框，用户对弹框做出选择后，才会调用block
    // 如果之前已经做过选择，会直接执行block
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        // block中是在子线程中进行,如果刷新UI需要回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied) {
                NSLog(@"用户拒绝当前APP访问相册");
                
                // 如果状态不等于没有做决定
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
                    NSLog(@"提醒用户打开开关");
                }
            } else if (status == PHAuthorizationStatusAuthorized) {
                NSLog(@"用户允许当前APP访问相册");
                if (completion) {
                    completion();
                }
            } else if (status == PHAuthorizationStatusRestricted) {
                NSLog(@"无法访问相册");
            }
        });
    }];
}







#pragma mark - 1.保存图片到【相机胶卷】


+ (NSString *)saveWithImage:(UIImage *)image
{
    NSError *error = nil;

    // 图片的ID
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"MYPhotoTool - 保存失败");
        return nil;
    }
    return assetID;
}



+ (void)saveWithImage:(UIImage *)image completion:(void(^)(NSString *))completion
{
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"MYPhotoTool - 保存失败");
        } else {
            if (completion) {
                completion(assetID);
            }
        }
    }];
}



#pragma mark - 2.创建/获取自定义相册


+ (PHAssetCollection *)getCustomCollectionWithName:(NSString *)collectionName
{
    // 获取所有自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 查找当前APP对应的自定义相册
    for (PHAssetCollection *collection in collections) {
        
        // *** 如果存在自定义相册
        if ([collection.localizedTitle isEqualToString:collectionName]) {
            return collection;
        }
    }
    
    // *** 自定义相册没有被创建过
    
    __block NSString *ID = nil;
    
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        
        // 创建一个【自定义相册】
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:collectionName];
        // 获取站位标识
        ID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        NSLog(@"MYPhotoTool - 创建自定义相册失败");
        return nil;
    }
    
    // 根据站位标识获取当前APP对应的自定义相册
    PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[ID] options:nil].firstObject;
    return collection;
}


+ (PHAssetCollection *)getCustomCollection
{
    // 获取软件名字
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];

    return [MYPhotoTool getCustomCollectionWithName:title];
}




#pragma mark - 3.添加图片到自定义相册

+ (BOOL)saveWithImageAssetID:(NSString *)assetID andCollection:(PHAssetCollection *)collection
{
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        id<NSFastEnumeration> assetIDs = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
        [request insertAssets:assetIDs atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    if (error) {
        NSLog(@"MYPhotoTool - 保存失败");
        return NO;
    }
    return YES;
}







#pragma mark - ！！！最简单方法保存图片到相册！！！

+ (void)saveToCollectionWithImage:(UIImage *)image completion:(void(^)(BOOL))completion
{
    // 获取软件名字
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    [MYPhotoTool saveToCollectionWithImage:image andCollectionName:title completion:^(BOOL success) {
        
        if (completion) {
            completion(success);
        }
    }];
}


+ (void)saveToCollectionWithImage:(UIImage *)image andCollectionName:(NSString *)collectionName completion:(void(^)(BOOL))completion
{
    
    [MYPhotoTool setAccessAuthorityWithCompletion:^{
        
        // 保存图片到【相机胶卷】
        NSString *assetID = [MYPhotoTool saveWithImage:image];
        
        // 获得相册
        PHAssetCollection *collection = [MYPhotoTool getCustomCollection];
        
        // 添加刚才保存的图片到【自定义相册】
        BOOL success = [MYPhotoTool saveWithImageAssetID:assetID andCollection:collection];
        
        if (completion) {
            completion(success);
        }
    }];
}

@end
