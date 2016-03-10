//
//  LLAMessageReceivedPraiseMainInfo.h
//  LLama
//
//  Created by Live on 16/3/8.
//  Copyright © 2016年 heihei. All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"
#import "LLAMessageReceivedPraiseItemInfo.h"

@interface LLAMessageReceivedPraiseMainInfo : MTLModel<MTLJSONSerializing>

/**
 *  当前页
 */
@property(nonatomic , assign) NSInteger currentPage;
/**
 *  每页尺寸
 */
@property(nonatomic , assign) NSInteger pageSize;
/**
 *
 */
@property(nonatomic , strong) NSMutableArray<LLAMessageReceivedPraiseItemInfo *> *dataList;
/**
 *  是否是第一页
 */
@property(nonatomic , assign) BOOL isFirstPage;
/**
 *  是否是最后一页
 */
@property(nonatomic , assign) BOOL isLastPage;
/**
 *  总页数
 */
@property(nonatomic , assign) NSInteger totalPageNumbers;
/**
 *  总数据量
 */
@property(nonatomic , assign) NSInteger totalDataNumbers;

+ (LLAMessageReceivedPraiseMainInfo *) parseJsonWithDic:(NSDictionary *) data;


@end