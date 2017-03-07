//
//  ViewController.m
//  PHPhotoDemo
//
//  Created by liht on 2017/3/7.
//  Copyright © 2017年 linitial. All rights reserved.
//

#import "ViewController.h"
#import "PhotoDefines.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)openPhotoLib:(UIButton *)sender {
    [PHPhotoManager requestAuthorizationForSender:self showCameraCallback:^(PhotoBrowserViewController *browser) {
        [browser dismissViewControllerAnimated:NO completion:^{
            UIImagePickerController *picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
        }];
    } completion:^(NSArray<ThumbAsset *> *assets) {
        NSLog(@"assets is %@",assets);
        [self showHint:@"这里返回添加的照片数组"];
    }];
}

- (void)showHint:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    NSLog(@"%@ finish picking image",[NSThread currentThread]);
    [self showHint:@"这里返回拍照的照片"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
