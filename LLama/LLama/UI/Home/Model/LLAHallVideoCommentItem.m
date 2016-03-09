//
//  LLAHallVideoCommentItem.m
//  LLama
//
//  Created by Live on 16/1/13.
//  Copyright © 2016年 heihei. All rights reserved.
//

#import "LLAHallVideoCommentItem.h"

#import "LLACommonUtil.h"

@implementation LLAHallVideoCommentItem

@synthesize textContainer;

+ (LLAHallVideoCommentItem *) parseJsonWithDic:(NSDictionary *)data {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:data error:nil];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"commentIdString":@"id",
             //@"scriptIdString":@"uid",
             @"commentContent":@"content",
             @"commentTimeString":@"time",
             @"commentTime":@"time",
             @"authorUser":@"user",
             @"replyToUser":@"tgt",
             
             //
             @"authorUidString":@"uid",
             @"authorName":@"uname",
             @"authorHeadURL":@"imgUrl",
             
             @"replyToUserIdString":@"targetUid",
             @"replyToUserName":@"target",
             @"replyToUserHeadURL":@"tartgetImgUrl",
             
             
             };
}

+ (NSValueTransformer *)authorUserJSONTransformer {
    
    [LLAUser setIsSimpleUserModel:YES];
    return [MTLJSONAdapter arrayTransformerWithModelClass:[LLAUser class]];
}

+ (NSValueTransformer *)replyToUserJSONTransformer {
    
    [LLAUser setIsSimpleUserModel:YES];
    return [MTLJSONAdapter arrayTransformerWithModelClass:[LLAUser class]];
}


+ (NSValueTransformer *)commentTimeStringJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [LLACommonUtil formatTimeFromTimeInterval:[value longLongValue]];
    }];
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    
    LLAHallVideoCommentItem *item = [super initWithDictionary:dictionaryValue error:error];
    
    //construct author user,reply user
    
    if (!self.authorUser) {
    
        LLAUser *author = [LLAUser new];
        
        author.userIdString = self.authorUidString;
        author.userName = self.authorName;
        author.headImageURL = self.authorHeadURL;
        item.authorUser = author;
    }
    
    //reply user
    if (!self.replyToUser) {
        NSString *replyUserName = self.replyToUserName;
        if (replyUserName.length > 0) {
            
            LLAUser *replyToUser = [LLAUser new];
            replyToUser.userName = replyUserName;
            replyToUser.userIdString = self.replyToUserIdString;
            replyToUser.headImageURL = self.replyToUserHeadURL;
            
            item.replyToUser = replyToUser;
        }

    }
    
    
    return item;
}

@end
