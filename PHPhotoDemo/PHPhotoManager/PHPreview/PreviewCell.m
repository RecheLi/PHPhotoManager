//
//  PreviewCell.m
//  PHPhotoTest
//
//  Created by liht on 17/2/22.
//  Copyright © 2017年 liht. All rights reserved.
//

#import "PreviewCell.h"
#import "PhotoDefines.h"
#import "ThumbAsset.h"

@interface PreviewCell ()

@property (nonatomic, strong) PhotoAssetView *scrollView;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation PreviewCell
- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.hidesWhenStopped = YES;
        _activityView.center = self.contentView.center;
    }
    return _activityView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [PhotoAssetView new];
        _scrollView.frame = self.bounds;
        _scrollView.cell = self;
        [self.contentView addSubview:_scrollView];
        [self.contentView addSubview:self.activityView];
    }
    return self;
}

- (void)setThumAsset:(ThumbAsset *)thumAsset {
    _thumAsset = thumAsset;
    [_activityView startAnimating];
    CGFloat width = MIN(kScreenWidth, kAssetImageWidth);
    CGSize size = CGSizeMake(width*kScreenScale, width*kScreenScale*_thumAsset.pixelHeight/_thumAsset.pixelWidth);
    [PHPhotoManager requestImageForAsset:_thumAsset size:size resizeMode:PHImageRequestOptionsResizeModeFast resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [self.activityView stopAnimating];
        }
        self.scrollView.assetImageView.image = result;
        [self.scrollView resizeImageView];
    }];
}


@end

@interface PhotoAssetView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *imageContainerView;

@end

@implementation PhotoAssetView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
        self.zoomScale = 1.0;
        self.maximumZoomScale = 3;
        self.multipleTouchEnabled = YES;
        self.alwaysBounceVertical = NO;
        self.delaysContentTouches = NO;
        [self addSubview:self.imageContainerView];
        [self.imageContainerView addSubview:self.assetImageView];
        [self commonInit];
    }
    return self;
}

- (UIView *)imageContainerView {
    if (!_imageContainerView) {
        _imageContainerView = [UIView new];
    }
    return _imageContainerView;
}

- (UIImageView *)assetImageView {
    if (!_assetImageView) {
        _assetImageView = [UIImageView new];
        _assetImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _assetImageView;
}

- (void)commonInit {
    self.assetImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideNavigation:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomAssetImage:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)hideNavigation:(UITapGestureRecognizer *)tap {
    if (self.cell.tapImageViewAction) {
        self.cell.tapImageViewAction();
    }
}

- (void)zoomAssetImage:(UITapGestureRecognizer *)tap {
    UIScrollView *scrollView = (UIScrollView *)tap.view;
    CGFloat scale = (scrollView.zoomScale != 3.0) ? 3 : 1;
    CGRect zoomRect = CGRectZero;;
    CGPoint center = [tap locationInView:tap.view];
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height /2.0);
    [scrollView zoomToRect:zoomRect animated:YES];
}

- (void)resizeImageView {
    CGRect frame;
    frame.origin = CGPointZero;
    
    UIImage *image = self.assetImageView.image;
    CGFloat imageScale = image.size.height/image.size.width;
    CGFloat screenScale = kScreenHeight/kScreenWidth;
    if (image.size.width <= CGRectGetWidth(self.frame) && image.size.height <= CGRectGetHeight(self.frame)) {
        frame.size.width = image.size.width;
        frame.size.height = image.size.height;
    } else {
        frame.size.height = (imageScale > screenScale) ? CGRectGetHeight(self.frame) : CGRectGetWidth(self.frame) * imageScale;
        frame.size.width = (imageScale > screenScale) ? (CGRectGetHeight(self.frame)/imageScale) : CGRectGetWidth(self.frame);
    }
    
    self.zoomScale = 1;
    self.contentSize = frame.size;
    [self scrollRectToVisible:self.bounds animated:NO];
    self.imageContainerView.frame = frame;
    self.imageContainerView.center = self.center;
    self.assetImageView.frame = self.imageContainerView.bounds;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = _imageContainerView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
