//
//  ThumbCell.m
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import "ThumbCell.h"
#import "ThumbAsset.h"
#import "PhotoDefines.h"

@implementation ThumbCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)selectPhoto:(UIButton *)sender {
    if (_selectPhotoCompleted) {
        _selectPhotoCompleted(_indexPath,sender.selected);
    }
}

+ (CGSize)size {
    return CGSizeMake((kScreenWidth-10)/4, (kScreenWidth-10)/4);
}

- (void)setThumbAsset:(ThumbAsset *)thumbAsset {
    _thumbAsset = thumbAsset;
    CGSize size = CGSizeMake([ThumbCell size].width*2.2, [ThumbCell size].height*2.2);
    [PHPhotoManager requestImageForAsset:_thumbAsset size:size resizeMode:PHImageRequestOptionsResizeModeExact resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.thumbImageView.image = result;
    }];
}

@end
