//
//  PhotoThumbViewController.h
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;

@class PhotoBrowserViewController;

typedef void(^ThumbCompletionBlock)(NSArray *assets);

@interface PhotoThumbViewController : UIViewController

@property (nonatomic, copy) NSString *photoTitle;

@property (nonatomic, weak) PhotoBrowserViewController *browserVC;

@property (nonatomic, strong) PHAssetCollection *assetCollection;

@property (nonatomic, copy) ThumbCompletionBlock thumbCompletionBlock;

/**最大张数限制
 */
@property (nonatomic, assign) NSInteger maxSelectedCount;

@end
