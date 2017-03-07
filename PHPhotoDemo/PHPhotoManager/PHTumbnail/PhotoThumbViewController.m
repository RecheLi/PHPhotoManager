//
//  PhotoThumbViewController.m
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import "PhotoThumbViewController.h"
#import "PhotomPreviewController.h"
#import "PhotoThumbLayout.h"
#import "PhotoDefines.h"
#import "ThumbCell.h"
#import "ThumbAsset.h"

@interface PhotoThumbViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIButton *completeButton;

@property (weak, nonatomic) IBOutlet UIButton *previewButton;

@property (weak, nonatomic) UIActivityIndicatorView *activityView;

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) NSMutableArray <ThumbAsset *>*selectData;

/*最先选中的照片
 */
@property (assign, nonatomic) NSInteger firstSelectedIndex;

@end

static NSString *kPhotoThumbIdentifier = @"kPhotoThumbIdentifier";

@implementation PhotoThumbViewController

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray *)selectData {
    if (!_selectData) {
        _selectData = [NSMutableArray array];
    }
    return _selectData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonConfig];
    [self getAllPhotos:self.assetCollection];
}

- (void)commonConfig {
    [self setupNavItem];
    self.maxSelectedCount = self.maxSelectedCount == 0 ? 9 : self.maxSelectedCount;
    self.countLabel.text = [NSString stringWithFormat:@"最多%@张",@(self.maxSelectedCount)];
    self.completeButton.enabled = NO;
    self.previewButton.enabled = NO;
    [self configCollectionView];
    
    //加载
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(kScreenWidth/2.0, (kScreenHeight-kNavigationBarHeight)/2.0);
    activityView.hidesWhenStopped = YES;
    [self.view addSubview:activityView];
    [self.view bringSubviewToFront:activityView];
    self.activityView = activityView;
    [self.activityView startAnimating];
}

- (void)configCollectionView {
    self.collectionView.decelerationRate = .5;
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.collectionViewLayout = [[PhotoThumbLayout alloc]init];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ThumbCell" bundle:nil] forCellWithReuseIdentifier:kPhotoThumbIdentifier];
}

- (void)setupNavItem {
    self.navigationItem.title = self.photoTitle;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark － 获取所有图片
- (void)getAllPhotos:(PHAssetCollection *)collection {
    NSArray *data = [PHPhotoManager getAssetsInCollection:collection ascending:NO];
    [self.dataSource addObjectsFromArray:data];
    [self.activityView stopAnimating];
    [self.collectionView reloadData];
}

#pragma mark - 预览
- (IBAction)showPreview:(UIButton *)sender {
    [self showPreviewControllerWithData:self.selectData selectedIndex:self.selectData.count-1];
}

#pragma mark - 完成
- (IBAction)selectCompleted:(UIButton *)sender {
    //完成后回调选中的图片
    if (_thumbCompletionBlock) {
        _thumbCompletionBlock(self.selectData);
    }
}

#pragma mark - setter
- (void)setPhotoTitle:(NSString *)photoTitle {
    if (!photoTitle) {
        _photoTitle = @"相册";
        return;
    }
    _photoTitle = photoTitle;
}

#pragma mark - 刷新底部按钮状态
- (void)reloadButtonStatus {
    self.previewButton.enabled = self.selectData.count<=0 ? NO : YES;
    self.completeButton.enabled = self.selectData.count<=0 ? NO : YES;
    if (self.selectData.count <= 0) {
        self.countLabel.text = [NSString stringWithFormat:@"最多%@张",@(self.maxSelectedCount)];
    } else {
        self.countLabel.text = [NSString stringWithFormat:@"最多%@张,已选%@张",@(self.maxSelectedCount),@(self.selectData.count)];
    }
}

- (void)reloadSelectDataAtIndexPath:(NSIndexPath *)selectedIndexPath
                    isSelectedPhoto:(BOOL)isSelectedPhoto
                      currentButton:(UIButton *)sender {
    ThumbAsset *asset = self.dataSource[selectedIndexPath.row - 1];
    if (!isSelectedPhoto) {
        if (self.selectData.count>=self.maxSelectedCount) {
            NSString *message = [NSString stringWithFormat:@"最多选择%@张",@(self.maxSelectedCount)];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        [self.selectData addObject:asset];
    } else {
        [self.selectData enumerateObjectsUsingBlock:^(ThumbAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.localIdentifier isEqualToString:asset.localIdentifier]) {
                [self.selectData removeObject:obj];
            }
        }];
    }
    sender.selected = !sender.selected;
    [self reloadButtonStatus];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoThumbIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.selectButton.hidden = YES;
        cell.thumbImageView.image = [UIImage imageNamed:@"camera_"];
        return cell;
    }
    ThumbAsset *asset = self.dataSource[indexPath.row - 1];
    cell.selectButton.hidden = NO;
    cell.indexPath = indexPath;
    cell.thumbAsset = asset;
    __weak typeof(self)weakSelf = self;
    __weak typeof(cell)weakCell = cell;
    [self.selectData enumerateObjectsUsingBlock:^(ThumbAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([asset.localIdentifier isEqualToString:obj.localIdentifier]) {
            cell.selectButton.selected = YES;
            *stop = YES;
        } else {
            cell.selectButton.selected = NO;
        }
    }];
    cell.selectPhotoCompleted = ^(NSIndexPath *selectedIndexPath, BOOL isSelectedPhoto) {
        NSLog(@"select indexPath %@ %@",indexPath, @(isSelectedPhoto));
        [weakSelf reloadSelectDataAtIndexPath:selectedIndexPath isSelectedPhoto:isSelectedPhoto currentButton:weakCell.selectButton];
    };
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //调用相机
        if (![PHPhotoManager isSourceTypeAvailable] || ![PHPhotoManager isCameraDeviceAvailable]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该设备不支持摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                if (self.browserVC.showCameraForBrowserController) {
                    self.browserVC.showCameraForBrowserController(self.browserVC);
                }
            } else {
                NSString *message = [NSString stringWithFormat:@"请在\"设置-隐私-相机\"选项中，允许%@访问你的相机", [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        return;
    }
    ThumbCell *cell = (ThumbCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (!cell.selectButton.selected) {
        [self showPreviewControllerWithData:self.dataSource selectedIndex:indexPath.row - 1];
        return;
    }
    [self reloadSelectDataAtIndexPath:indexPath isSelectedPhoto:YES currentButton:cell.selectButton];
}

- (void)showPreviewControllerWithData:(NSArray *)data selectedIndex:(NSInteger)selectedIndex {
    PhotomPreviewController *vc = [[PhotomPreviewController alloc]init];
    vc.assets = data;
    vc.maxSelectedCount = self.maxSelectedCount;
    vc.selectedIndex = selectedIndex;
    vc.selectedAssets = [self.selectData mutableCopy];
    __weak typeof(self)weakSelf = self;
    vc.selectPhotoCallback = ^(NSArray *selectedAssets) {
        [weakSelf.selectData removeAllObjects];
        [weakSelf.selectData addObjectsFromArray:selectedAssets];
        [weakSelf.collectionView reloadData];
        [weakSelf reloadButtonStatus];
    };
    vc.selectCompletionBlock = ^(NSArray *selectedAssets){
        [weakSelf.selectData removeAllObjects];
        [weakSelf.selectData addObjectsFromArray:selectedAssets];
        [weakSelf selectCompleted:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}


@end
