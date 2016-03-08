//
//  LLAMessageReceivedPraiseItemInfo.m
//  LLama
//
//  Created by Live on 16/2/27.
//  Copyright © 2016年 heihei. All rights reserved.
//

#import "LLAMessageReceivedPraiseItemInfo.h"

#import "LLACommonUtil.h"

@implementation LLAMessageReceivedPraiseItemInfo

+ (instancetype) parseJsonWithDic:(NSDictionary *)data {
    
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:data error:nil];
    
}

+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{@"itemIdString":@"id",
             @"authorUser":@"user",
             @"infoImageURL":@"image",
             @"scriptIdString":@"playId",
             @"manageContent":@"content",
             @"editTimeInterval":@"time",
             @"editTimeString":@"time"};
}

+ (NSValueTransformer *)editTimeStringJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        return [LLACommonUtil formatTimeFromTimeInterval:[value longLongValue]];
    }];
}


@end
