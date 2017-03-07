//
//  PhotomPreviewController.m
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import "PhotomPreviewController.h"
#import "PreviewFlowLayout.h"
#import "PhotoDefines.h"
#import "PreviewCell.h"
#import "ThumbAsset.h"

@interface PhotomPreviewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UICollectionView *collectionView;

/**底部视图
 */
@property (nonatomic, strong) UIView *bottomView;

/**导航栏右侧按钮
 */
@property (nonatomic, strong) UIButton *navButton;

/**完成按钮
 */
@property (nonatomic, strong) UIButton *completeButton;

/**当前是第几页
 */
@property (nonatomic, assign) NSInteger currentPage;

@end

static NSString *const kPhotoPreviewCellIdentifier = @"kPhotoPreviewCellIdentifier";
const NSTimeInterval kAnimationDuration = 0.3;


@implementation PhotomPreviewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:({
            CGRect rect = {0, 0, kScreenWidth, kScreenHeight};
            rect;
        }) collectionViewLayout:({
            PreviewFlowLayout *layout = [[PreviewFlowLayout alloc]init];
            layout;
        })];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[PreviewCell class] forCellWithReuseIdentifier:kPhotoPreviewCellIdentifier];
    }
    return _collectionView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:({
            CGRect rect = {0, kScreenHeight-kBottomViewHeight, kScreenWidth, kBottomViewHeight};
            rect;
        })];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [_bottomView addSubview:self.completeButton];
        CGFloat buttonWidth = 56.0, buttonHeight = 30.0;
        _completeButton.frame = CGRectMake(kScreenWidth-buttonWidth, (kBottomViewHeight-buttonHeight)/2.0, buttonWidth, buttonHeight);
    }
    return _bottomView;
}

- (UIButton *)completeButton {
    if (!_completeButton) {
        UIColor *normalColor = [UIColor colorWithRed:66/255.0 green:194/255.0 blue:132/255.0 alpha:1];
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_completeButton setTitle:@"完成" forState:UIControlStateNormal];
        [_completeButton setTitleColor:normalColor forState:UIControlStateNormal];
        [_completeButton setTitleColor:[normalColor colorWithAlphaComponent:.5] forState:UIControlStateDisabled];
        [_completeButton addTarget:self action:@selector(clickCompleteButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeButton;
}

- (NSMutableArray<ThumbAsset *> *)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.currentPage = self.selectedIndex + 1;
    [self setupNavButton];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    [self.dataSource addObjectsFromArray:self.assets];
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(kScreenWidth*(self.selectedIndex), 0)];
    [self reloadButtonStatus];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@/%@",@(_currentPage),@(_dataSource.count)];
}

- (void)setupNavButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"btnBack"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBack)];
    
    _navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _navButton.frame = CGRectMake(0, 0, 25, 25);
    UIImage *normalImg = [UIImage imageNamed:@"unselect"];
    UIImage *selectImg = [UIImage imageNamed:@"select"];
    [_navButton setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_navButton setBackgroundImage:selectImg forState:UIControlStateSelected];
    [_navButton addTarget:self action:@selector(clickNavButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navButton];
}

- (void)popBack {
    if (_selectPhotoCallback) {
        _selectPhotoCallback(self.selectedAssets);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickNavButton:(UIButton *)sender {
    if (!sender.selected && self.selectedAssets.count>=self.maxSelectedCount) { //未选中
        NSString *message = [NSString stringWithFormat:@"最多选择%@张",@(self.maxSelectedCount)];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    sender.selected = !sender.selected;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPage-1 inSection:0];
    [self reloadSelectAssetIndexPath:indexPath isSelectedPhoto:sender.selected];
}

- (void)reloadSelectAssetIndexPath:(NSIndexPath *)selectedIndexPath
                    isSelectedPhoto:(BOOL)isSelectedPhoto {
    ThumbAsset *asset = self.dataSource[selectedIndexPath.row];
    if (!isSelectedPhoto) {
        [self.selectedAssets enumerateObjectsUsingBlock:^(ThumbAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.localIdentifier isEqualToString:asset.localIdentifier]) {
                [self.selectedAssets removeObject:obj];
            }
        }];
    } else {
        [self.selectedAssets addObject:asset];
    }
    _completeButton.enabled = self.selectedAssets.count > 0 ? YES : NO;
}

#pragma mark - 完成按钮点击
- (void)clickCompleteButton {
    if (_selectCompletionBlock) {
        _selectCompletionBlock(self.selectedAssets);
    }
}

#pragma mark - 刷新导航栏按钮状态
- (void)reloadButtonStatus {
    ThumbAsset *currentAsset = self.dataSource[_currentPage-1];
    [self.selectedAssets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ThumbAsset *asset = (ThumbAsset *)obj;
        if ([currentAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
            self.navButton.selected = YES;
            *stop = YES;
        } else {
            self.navButton.selected = NO;
        }
    }];
    _completeButton.enabled = self.selectedAssets.count > 0 ? YES : NO;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoPreviewCellIdentifier forIndexPath:indexPath];
    ThumbAsset *asset = self.dataSource[indexPath.row];
    cell.thumAsset = asset;
    __weak typeof(self)weakSelf = self;
    cell.tapImageViewAction = ^{
        [weakSelf hideNavigationAndBottomView];
    };
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        NSInteger currentIndex = scrollView.contentOffset.x/kScreenWidth;
        self.currentPage =  currentIndex + 1;
        self.navigationItem.title = [NSString stringWithFormat:@"%@/%@",@(_currentPage),@(_dataSource.count)];
        [self reloadButtonStatus];
    }
}

#pragma mark - 隐藏导航栏/状态栏/底部视图
- (void)hideNavigationAndBottomView {
    if (!self.navigationController.isNavigationBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            CGRect rect = self.bottomView.frame;
            rect.origin.y = kScreenHeight;
            self.bottomView.frame = rect;
        } completion:nil];
        return;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        CGRect rect = self.bottomView.frame;
        rect.origin.y = kScreenHeight - kBottomViewHeight;
        self.bottomView.frame = rect;
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
