//
//  PHPhotoManager.m
//  PHPhotoTest
//
//  Created by liht on 2017/3/6.
//  Copyright © 2017年 liht. All rights reserved.
//

#import "PHPhotoManager.h"
#import <UIKit/UIKit.h>
#import "ThumbAsset.h"
#import "PhotoDefines.h"
#import "BrowserAlbumModel.h"

CGFloat const kScalePhotoWidth = 1000;

@implementation PHPhotoManager

+ (BOOL)isSourceTypeAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL)isCameraDeviceAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL)isCameraAuthorized {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

+ (BOOL)photoLibraryAuthorized {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

/**等比缩放
 */
+ (UIImage *)scaleImage:(UIImage *)image scaleSize:(CGFloat)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (void)requestAuthorizationForSender:(UIViewController *)controller
                   showCameraCallback:(void(^)(PhotoBrowserViewController *))cameraCallback
                           completion:(void(^)(NSArray <ThumbAsset *>*))completion {
    if (![self photoLibraryAuthorized]) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 switch (status) {
                     case PHAuthorizationStatusAuthorized:
                         [self showBrowser:controller cameraCallback:cameraCallback completion:completion];
                         break;
                     default:
                         NSLog(@"相册未授权");
                         NSString *message = [NSString stringWithFormat:@"请在\"设置-隐私-相机\"选项中，允许%@访问你的相册", [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];
                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                         [alert addAction:action];
                         [controller presentViewController:alert animated:YES completion:nil];
                         break;
                 }
             });
         }];
        return;
    }
    [self showBrowser:controller cameraCallback:cameraCallback completion:completion];
}

+ (void)requestImageForAsset:(PHAsset *)asset
                        size:(CGSize)targetSize
                  resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
               resultHandler:(void (^)(UIImage *__nullable result, NSDictionary *__nullable info))resultHandler {
    static PHImageRequestID requestID = -1;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(kScreenWidth, kAssetImageWidth);
    if (requestID >= 1 && targetSize.width/width==scale) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }

    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc]init];
    requestOptions.resizeMode = resizeMode;
    requestOptions.networkAccessAllowed = YES;
    requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL loadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        if (loadFinished && resultHandler) {
            resultHandler(result, info);
        }
    }];
}

+ (void)showBrowser:(UIViewController *)controller
     cameraCallback:(void(^)(PhotoBrowserViewController *))cameraCallback
         completion:(void(^)(NSArray <ThumbAsset *>*))completion{
    PhotoBrowserViewController *vc = [[PhotoBrowserViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [controller presentViewController:nav animated:YES completion:nil];
    vc.showCameraForBrowserController = ^(PhotoBrowserViewController *browser) {
        if (cameraCallback) {
            cameraCallback(browser);
        }
    };
    vc.browserCompletionBlock = ^(NSArray *assets) {
        if (completion) {
            completion (assets);
        }
    };
}

// MARK: 获取相册列表
+ (void)getPhotoAlbums:(void(^__nullable)(NSMutableArray *__nullable))resultHandle {
    //所有智能相册
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchResult <PHAssetCollection *>*smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        NSMutableArray *datasource =  @[].mutableCopy;
        [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            if(collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos &&
               collection.assetCollectionSubtype < PHAssetCollectionSubtypeSmartAlbumDepthEffect){
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    NSArray <PHAsset *>*assets = [self getAssets:collection];
                    if (!assets || assets.count<=0) {
                        return;
                    }
                    BrowserAlbumModel *albumModel = [[BrowserAlbumModel alloc]init];
                    albumModel.assetCollection = collection;
                    albumModel.title = collection.localizedTitle;
                    albumModel.totalCount = assets.count;
                    albumModel.firstImageAsset = [assets firstObject];
                    [datasource addObject:albumModel];
                } else {
                    NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
                }
            }
        }];
        
        PHFetchResult *customAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        [customAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                NSArray <PHAsset *>*assets = [self getAssets:collection];
                if (!assets || assets.count<=0) {
                    return;
                }
                BrowserAlbumModel *albumModel = [[BrowserAlbumModel alloc]init];
                albumModel.assetCollection = collection;
                albumModel.title = collection.localizedTitle;
                albumModel.totalCount = assets.count;
                albumModel.firstImageAsset = [assets firstObject];
                [datasource addObject:albumModel];
            } else {
                NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultHandle) {
                resultHandle(datasource);
            }
        });
    });
}

#pragma mark - 获取所有图片
+ (NSArray <PHAsset *>*)getAssets:(PHAssetCollection *)collection {
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

#pragma mark - PHAssetCollection中的PHAsset集合
+ (NSArray<PHAsset *> *)getAssetsInCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((ThumbAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

@end
