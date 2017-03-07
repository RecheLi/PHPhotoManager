//
//  PHPhotoManager.h
//  PHPhotoTest
//
//  Created by liht on 2017/3/6.
//  Copyright © 2017年 liht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "PhotoBrowserViewController.h"

@interface PHPhotoManager : NSObject

+ (BOOL)isSourceTypeAvailable;

+ (BOOL)isCameraDeviceAvailable;

+ (BOOL)photoLibraryAuthorized;

+ (BOOL)isCameraAuthorized;

+ (void)requestAuthorizationForSender:(UIViewController *__nonnull)controller
                   showCameraCallback:(void(^__nullable)(PhotoBrowserViewController *__nonnull sender))cameraCallback
                           completion:(void(^__nullable)(NSArray <ThumbAsset *>*__nullable assets))completion;

+ (void)requestImageForAsset:(PHAsset *__nonnull)asset
                        size:(CGSize)targetSize
                  resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
               resultHandler:(void (^__nullable)(UIImage *__nullable result, NSDictionary *__nullable info))resultHandler;

+ (void)getPhotoAlbums:(void(^__nullable)(NSMutableArray *__nullable))resultHandle;

+ (UIImage *__nonnull)scaleImage:(UIImage *__nonnull)image scaleSize:(CGFloat)scaleSize;

+ (NSArray<PHAsset *> *__nullable)getAssetsInCollection:(PHAssetCollection *__nullable)assetCollection ascending:(BOOL)ascending;
@end
