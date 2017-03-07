//
//  ThumbCell.h
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbAsset;

@interface ThumbCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (strong, nonatomic) ThumbAsset *thumbAsset;

@property (copy, nonatomic) NSIndexPath *indexPath;

@property (copy, nonatomic) void (^selectPhotoCompleted)(NSIndexPath *indexPath,  BOOL isSelectedPhoto);

+ (CGSize)size;

@end
