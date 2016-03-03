//
//  LLAMessageReceivedCommentCell.h
//  LLama
//
//  Created by Live on 16/2/29.
//  Copyright © 2016年 heihei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLAMessageReceivedCommentItemInfo;

@interface LLAMessageReceivedCommentCell : UITableViewCell

- (void) updateCellWithInfo:(LLAMessageReceivedCommentItemInfo *) info tableWidth:(CGFloat) width;

+ (CGFloat) calculateHeightWithInfo:(LLAMessageReceivedCommentItemInfo *) info tableWidth:(CGFloat) width;

@end