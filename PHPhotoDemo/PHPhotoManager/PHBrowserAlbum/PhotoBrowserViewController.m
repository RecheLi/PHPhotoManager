//
//  PhotoBrowserViewController.m
//  PHPhotoTest
//
//  Created by liht on 17/2/21.
//  Copyright © 2017年 liht. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoThumbViewController.h"
#import "PhotoDefines.h"
#import "BrowserCell.h"
#import "BrowserAlbumModel.h"

@interface PhotoBrowserViewController () <PHPhotoLibraryChangeObserver>

@property (assign, nonatomic) BOOL isThumbPage;

@end

static NSString *kPhotoBrowserIdentifier = @"kPhotoBrowserIdentifier";

@implementation PhotoBrowserViewController

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    if (![PHPhotoManager photoLibraryAuthorized]) {
        //监听相册
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        return;
    }
    [self getPhotoAlbums];
}

- (void)commonInit {
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"BrowserCell" bundle:nil] forCellReuseIdentifier:kPhotoBrowserIdentifier];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - 获取相册列表
- (void)getPhotoAlbums {
    [PHPhotoManager getPhotoAlbums:^(NSMutableArray * _Nullable result) {
        [self.dataSource addObjectsFromArray:result];
        [self showThumbnailAnimated:NO];
        [self.tableView reloadData];
    }];
}

#pragma mark - 跳转
- (void)showThumbnailAnimated:(BOOL)animated {
    if (self.dataSource.count <= 0) {
        return;
    }
    //获取相机胶卷collection
    __block NSInteger index = 0;
    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BrowserAlbumModel *model = (BrowserAlbumModel *)obj;
        if (model.assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            index = idx;
        }
    }];
    PhotoThumbViewController *vc = [[PhotoThumbViewController alloc]init];
    BrowserAlbumModel *model = [self.dataSource objectAtIndex:index];
    vc.browserVC = self;
    vc.maxSelectedCount = self.maxSelectedCount;
    vc.photoTitle = model.title;
    vc.assetCollection = model.assetCollection;
    __weak typeof(self)weakSelf = self;
    vc.thumbCompletionBlock = ^(NSArray *assets) {
        if (weakSelf.browserCompletionBlock) {
            weakSelf.browserCompletionBlock(assets);
        }
    };
    self.isThumbPage = YES;
    [self.navigationController pushViewController:vc animated:animated];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:kPhotoBrowserIdentifier forIndexPath:indexPath];
    BrowserAlbumModel *model = self.dataSource[indexPath.row];
    [PHPhotoManager requestImageForAsset:model.firstImageAsset size:CGSizeMake(70*3, 70*3) resizeMode:PHImageRequestOptionsResizeModeExact resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.assetImageView.image = result;
        cell.assetName.text = model.title;
    }];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BrowserAlbumModel *model = self.dataSource[indexPath.row];
    PhotoThumbViewController *vc = [[PhotoThumbViewController alloc]init];
    vc.maxSelectedCount = self.maxSelectedCount;
    vc.photoTitle = model.title;
    vc.assetCollection = model.assetCollection;
    vc.browserVC = self;
    __weak typeof(self)weakSelf = self;
    vc.thumbCompletionBlock = ^(NSArray *assets) {
        if (weakSelf.browserCompletionBlock) {
            weakSelf.browserCompletionBlock(assets);
        }
    };
    self.isThumbPage = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (!_isThumbPage) {
            [self getPhotoAlbums];
        } else {
            [self showThumbnailAnimated:YES];
        }
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    });
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    NSLog(@"%s",__func__);
}

@end
