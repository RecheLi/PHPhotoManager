//
//  PhotoBrowserViewController.h
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbAsset;

@interface PhotoBrowserViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, copy) void(^browserCompletionBlock)(NSArray <ThumbAsset *>*);

@property (nonatomic, copy) void(^showCameraForBrowserController)(PhotoBrowserViewController *browser);

/**最大张数限制
 */
@property (nonatomic, assign) NSInteger maxSelectedCount;

@end
