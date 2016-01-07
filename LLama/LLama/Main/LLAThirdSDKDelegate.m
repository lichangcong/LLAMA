//
//  LLAThirdSDKDelegate.m
//  LLama
//
//  Created by WanDa on 16/1/7.
//  Copyright © 2016年 heihei. All rights reserved.
//

#import "LLAThirdSDKDelegate.h"
#import "LLAUser.h"
#import "LLAHttpUtil.h"

#define SDK_REDIRECT_URL @"http://www.hillama.com"

@interface LLAThirdSDKDelegate()
{
    TencentOAuth *qqAuth;
}

@end

@implementation LLAThirdSDKDelegate

+ (instancetype) shareInstance {
    static LLAThirdSDKDelegate *shareInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shareInstance = [[[self class] alloc] init];
    });
    return shareInstance;
}

#pragma mark - Init

- (instancetype) init {
    self = [super init];
    if (self) {
        qqAuth = [[TencentOAuth alloc] initWithAppId:LLA_QQ_APPID andDelegate:self];
    }
    return self;
}

#pragma mark - Public Method

- (void) qqLogin {
    NSArray *permissions = [NSArray arrayWithObjects:@"all", nil];
    [qqAuth authorize:permissions inSafari:NO];
}

- (void) weChatLogin {
    if(![WXApi isWXAppInstalled]){
        //未安装微信
        return;
    }
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
    req.state = SDK_REDIRECT_URL ;
    [WXApi sendReq:req];
}

- (void) sinaWeiBoLogin {
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];

    request.redirectURI = SDK_REDIRECT_URL;
    request.scope = @"all";
    request.userInfo = @{@"type": @"login"};
    [WeiboSDK sendRequest:request];
}

#pragma mark - SinaWeiBoDelegate

- (void) didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

- (void) didReceiveWeiboResponse:(WBBaseResponse *)response {
    WeiboSDKResponseStatusCode statusCode = response.statusCode;
    if(statusCode == WeiboSDKResponseStatusCodeSuccess){
        NSString *type = [response.requestUserInfo valueForKey:@"type"];
        if([type isEqualToString:@"login"]){
            
            WBAuthorizeResponse *authorizeResponse = (WBAuthorizeResponse *)response;
            NSString *accessToken = authorizeResponse.accessToken;
            NSString *uid = authorizeResponse.userID;
            
            LLAUser *user = [LLAUser new];
            user.loginType = UserLoginType_SinaWeiBo;
            user.sinaWeiBoUid = [uid integerValue];
            user.sinaWeiBoAccess_Token = accessToken;
            
            [self fetchUserAccessTokenInfoWithInfo:user];
            
        }else if([type isEqualToString:@"share"]){
        
        }
    }
}

#pragma mark - WeiXinDelegate

- (void) onReq:(BaseReq *)req {
    
}

- (void) onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        //pay
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                break;
            }
            default:
            {
                break;
            }
        }
        
    }else if(resp.errCode == WXSuccess){
        if ([resp isKindOfClass:[SendAuthResp class]]) {
            //login
            if (resp.errCode == 0) {
                NSLog(@"用户同意");
                SendAuthResp *aresp = (SendAuthResp *)resp;
                if (aresp.code != nil) {
                    //获取token和openUid
                    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",LLA_WEIXIN_APPID,LLA_WEIXIN_APP_SECRET,aresp.code];
                    
                    NSURL *url = [NSURL URLWithString:urlString];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (data){
                                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                if ([dict objectForKey:@"errcode"]){
                                    NSLog(@"获取token错误");
                                }
                                else{
                                    
                                    NSString *openId = [dict objectForKey:@"openid"];
                                    NSString *accessToken = [dict objectForKey:@"access_token"];
                                    
                                    LLAUser *user = [LLAUser new];
                                    user.loginType = UserLoginType_WeChat;
                                    user.weChatOpenId = openId;
                                    user.weChatAccess_Token = accessToken;
                                    
                                    [self fetchUserAccessTokenInfoWithInfo:user];
                                    
                                }
                            }
                        });
                    });
                }
                
            }else if(resp.errCode ==-4){
                NSLog(@"用户拒绝");
            }else if(resp.errCode == -2){
                NSLog(@"用户取消");
            }

            
        }
        
    }

}

#pragma mark - Tencent Login

- (void) tencentDidLogin {
    //login
//    if ([qqAuth getUserInfo]) {
//        
//    }
    
    LLAUser *user = [LLAUser new];
    
    user.loginType = UserLoginType_QQ;
    user.qqOpenId = qqAuth.openId;
    user.qqAccess_Token = qqAuth.accessToken;
    
    [self fetchUserAccessTokenInfoWithInfo:user];
}

- (void) tencentDidNotLogin:(BOOL)cancelled {
    
    if (cancelled) {
        //cancel login
    }else {
        //login failed
    }
}

- (void) tencentDidNotNetWork {
    //bad network
}

- (void)isOnlineResponse:(NSDictionary *)response {
    
}

//- (void) getUserInfoResponse:(APIResponse *)response {
//    
//}

#pragma mark - Get UserInfo

- (void) fetchUserAccessTokenInfoWithInfo:(LLAUser *) user {
    
    NSString *url = @"";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (user.loginType == UserLoginType_MobilePhone) {
        url = @"/login/mobileLogin";
    }else if (user.loginType == UserLoginType_SinaWeiBo) {
        url = @"/login/weiboLogin";
        [params setValue:@(user.sinaWeiBoUid) forKey:@"uid"];
        [params setValue:user.sinaWeiBoAccess_Token forKey:@"access_token"];
        
    }else if (user.loginType == UserLoginType_WeChat) {
        url = @"/login/weixinLogin";
        [params setValue:user.weChatOpenId forKey:@"openid"];
        [params setValue:user.weChatAccess_Token forKey:@"access_token"];
        
    }else if (user.loginType == UserLoginType_QQ) {
        url = @"/login/qqLogin";
        [params setValue:user.qqOpenId forKey:@"openid"];
        [params setValue:user.qqAccess_Token forKey:@"access_token"];
        
    }
    
    [LLAHttpUtil httpPostWithUrl:url param:params progress:NULL responseBlock:^(id responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        
        NSString *token = [responseObject valueForKey:@"token"];
        self.tempToken = token;
        
        //get userInfo
        [LLAHttpUtil httpPostWithUrl:@"/user/getUserInfo" param:[NSMutableDictionary dictionary] progress:NULL responseBlock:^(id responseObject) {
            LLAUser *loginUser = [LLAUser parseJsonWidthDic:[responseObject valueForKey:@"user"]];
            NSLog(@"%@",responseObject);
        } exception:^(NSInteger code, NSString *errorMessage) {
            NSLog(@"%@",errorMessage);
        } failed:^(NSURLSessionTask *sessionTask, NSError *error) {
            NSLog(@"%@",error);
        }];
        
    } exception:^(NSInteger code, NSString *errorMessage) {
        NSLog(@"errorMessage:%@",errorMessage);
    } failed:^(NSURLSessionTask *sessionTask, NSError *error) {
        NSLog(@"error:%@",error);
    }];
}

@end