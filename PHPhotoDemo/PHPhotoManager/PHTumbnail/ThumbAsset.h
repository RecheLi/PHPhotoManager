//
//  ThumbAsset.h
//  PHPhotoTest
//
//  Created by liht on 17/2/22.
//  Copyright © 2017年 liht. All rights reserved.
//

#import <Photos/Photos.h>

@interface ThumbAsset : PHAsset

@property (nonatomic, assign, getter=isSelectedAsset) BOOL selectedAsset;

@end
