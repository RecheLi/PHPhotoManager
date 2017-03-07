//
//  PhotoThumbLayout.m
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import "PhotoThumbLayout.h"
#import "PhotoDefines.h"

@implementation PhotoThumbLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumInteritemSpacing = 2;
        self.minimumLineSpacing = 2;
        self.itemSize = CGSizeMake((kScreenWidth-10)/4, (kScreenWidth-10)/4);
        self.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    }
    return self;
}

@end
