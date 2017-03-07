//
//  BrowserAlbumModel.h
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Photos;

@interface BrowserAlbumModel : NSObject

/**相册名
 */
@property (nullable, nonatomic, copy) NSString *title;

/**该相册内相片数量
 */
@property (nonatomic, assign) NSInteger totalCount;

/**相册第一张图片缩略图
 */
@property (nullable, nonatomic, strong) PHAsset *firstImageAsset;

/**相册集，通过该属性获取该相册集下所有照片
 */
@property (nullable, nonatomic, strong) PHAssetCollection *assetCollection;

@end
