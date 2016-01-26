//
//  TMChangePwdController.m
//  LLama
//
//  Created by tommin on 15/12/28.
//  Copyright © 2015年 heihei. All rights reserved.
//

#import "TMChangePwdController.h"
#import "LLAChangBoundPhonesViewController.h"

@interface TMChangePwdController ()

@end

@implementation TMChangePwdController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = TMCommonBgColor;
    
    self.navigationItem.title = @"更换绑定的手机号";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)nextStep:(UIButton *)sender {
    
    LLAChangBoundPhonesViewController *changeBounds = [[LLAChangBoundPhonesViewController alloc] init];
    [self.navigationController pushViewController:changeBounds animated:YES];
}

@end
