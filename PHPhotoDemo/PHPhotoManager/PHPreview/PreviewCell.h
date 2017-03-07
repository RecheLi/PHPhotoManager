//
//  PreviewCell.h
//  PHPhotoTest
//
//  Created by liht on 17/2/22.
//  Copyright © 2017年 liht. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbAsset;

@interface PreviewCell : UICollectionViewCell

@property (strong, nonatomic) ThumbAsset *thumAsset;

@property (copy, nonatomic) void(^tapImageViewAction)();

@end


@interface PhotoAssetView : UIScrollView

@property (nonatomic, strong) UIImageView *assetImageView;

@property (nonatomic, weak) PreviewCell *cell;

- (void)resizeImageView;

@end
