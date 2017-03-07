//
//  PhotomPreviewController.h
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;
@class ThumbAsset;


@interface PhotomPreviewController : UIViewController

/**所有图片集合
 */
@property (nonatomic, strong) NSArray <ThumbAsset *>*assets;

/**选中图片集合
 */
@property (nonatomic, strong) NSMutableArray <ThumbAsset *>*selectedAssets;

/**当前选中图片下标
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**最大张数限制
 */
@property (nonatomic, assign) NSInteger maxSelectedCount;

@property (nonatomic, copy) void(^selectPhotoCallback)(NSArray *selectedAssets);

@property (nonatomic, copy) void(^selectCompletionBlock)(NSArray *);

/**判断是否需要现实原图按钮(暂时没做)
 */
@property (nonatomic, assign, getter=isShowOriginalPhoto) BOOL showOriginalPhoto;

@end
