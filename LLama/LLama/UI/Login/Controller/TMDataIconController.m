//
//  TMDataIconController.m
//  LLama
//
//  Created by tommin on 15/12/24.
//  Copyright © 2015年 heihei. All rights reserved.
//

#import "TMDataIconController.h"
#import "TMDataVideoController.h"

#import "LLAViewUtil.h"
#import "LLAUploadFileUtil.h"
#import "LLALoadingView.h"
#import "LLAHttpUtil.h"
#import "LLAUser.h"


@interface TMDataIconController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImage *choosedImage;
    
    LLALoadingView *HUD;
}
@property (weak, nonatomic) IBOutlet UIButton *ChooseHeadImageButton;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;

@end

@implementation TMDataIconController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"个人资料";
    
    self.ChooseHeadImageButton.clipsToBounds = YES;
    self.ChooseHeadImageButton.layer.cornerRadius = self.ChooseHeadImageButton.frame.size.height/2;
    
    HUD = [LLAViewUtil addLLALoadingViewToView:self.view];
    [HUD hide:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextStepButtonClick:(UIButton *)sender {
    
    // 推出键盘
    [self.view endEditing:YES];
    
    if (self.nickNameTextField.text.length < 1) {
    
        [LLAViewUtil showAlter:self.view withText:@"给自己起个名字吧"];
        
        return;
    }
    
    if (!choosedImage) {
        
        [LLAViewUtil showAlter:self.view withText:@"给自己找个头像吧"];
        
        return;
    }
    
    if (!self.femaleButton.selected && !self.maleButton.selected) {
        
        [LLAViewUtil showAlter:self.view withText:@"请选择性别"];
        
        return;
        
    }
    
    //first upload image to Qiniu,then change user's profiles
    
    [HUD show:YES];
    
    __weak typeof(self) blockSelf = self;
    
    [LLAUploadFileUtil llaUploadWithFileType:LLAUploadFileType_Image file:choosedImage tokenBlock:^(NSString *uploadToken, NSString *uploadKey) {
        
    } uploadProgress:^(NSString *uploadKey, float percent) {
        
    } complete:^(LLAUploadFileResponseCode responseCode, NSString *uploadToken, NSString *uploadKey, NSDictionary *respDic) {
        
        if (uploadKey && uploadToken && respDic) {
            //change user's profiles
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            
            [params setValue:blockSelf.nickNameTextField.text forKey:@"name"];
            [params setValue:uploadKey forKey:@"imgKey"];
            [params setValue:blockSelf.maleButton.selected ? @"男":@"女" forKey:@"gender"];
            
            [LLAHttpUtil httpPostWithUrl:@"/user/updateUserInfo" param:params responseBlock:^(id responseObject) {
                //
                
                [HUD hide:YES];
                
                LLAUser *user = [LLAUser parseJsonWidthDic:responseObject];
                
                [LLAUser updateUserInfo:user];
                //
                TMDataVideoController *dataVideo = [[TMDataVideoController alloc] init];
                
                [self.navigationController pushViewController:dataVideo animated:YES];
                
            } exception:^(NSInteger code, NSString *errorMessage) {
                
                [HUD hide:YES];
                [LLAViewUtil showAlter:blockSelf.view withText:errorMessage];
                
            } failed:^(NSURLSessionTask *sessionTask, NSError *error) {
                [HUD hide:YES];
                [LLAViewUtil showAlter:blockSelf.view withText:error.localizedDescription];
            }];
            
            
        }else {
            
            [HUD hide:YES];
            
            [LLAViewUtil showAlter:blockSelf.view withText:[LLAUploadFileUtil llaUploadResponseCodeToDescription:responseCode]];
            
        }
        
    }];
    
    

    
}
- (IBAction)chooseHeadImageButtonClicked:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self.navigationController presentViewController:imagePicker animated:YES completion:^{
        
    }];
    
    
}

- (IBAction)backBtnClick:(UIButton *)sender {
    
    // 推出键盘
    [self.view endEditing:YES];

}

- (IBAction)maleButtonClicked:(id)sender {
    [self.view endEditing:YES];
    
    self.maleButton.selected = YES;
    self.femaleButton.selected = NO;

}
- (IBAction)femaleButtonClicked:(id)sender {
    
    [self.view endEditing:YES];
    self.femaleButton.selected = YES;
    self.maleButton.selected = NO;
}

// 点击屏幕时也推出键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - UIImagePickerViewController

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = nil;
    
    if (picker.allowsEditing){
        image = [info valueForKey:UIImagePickerControllerEditedImage];
    }else{
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        choosedImage = image;
        
        [self.ChooseHeadImageButton setImage:choosedImage forState:UIControlStateNormal];
        
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
