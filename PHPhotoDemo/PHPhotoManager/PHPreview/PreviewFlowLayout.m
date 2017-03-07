//
//  PreviewFlowLayout.m
//  PHPhotoTest
//
//  Created by liht on 17/2/23.
//  Copyright © 2017年 liht. All rights reserved.
//

#import "PreviewFlowLayout.h"
#import "PhotoDefines.h"

@implementation PreviewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat width = 10.0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = width;
        self.minimumInteritemSpacing = width*2;
        self.sectionInset = UIEdgeInsetsMake(width/2, width/2, width/2, width/2);
        self.itemSize = CGSizeMake(kScreenWidth-width, kScreenHeight-width);
    }
    return self;
}

@end
