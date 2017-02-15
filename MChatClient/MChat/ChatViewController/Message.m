//
//  AppDelegate.h
//  聊天界面
//
//  Created by  王伟 on 2016/12/4.
//  Copyright © 2016年  王伟. All rights reserved.
//

#import "Message.h"
#define CELL_MARGIN_TB  4.0
#define CELL_MARING_LR  10.0
#define CELL_CORNOR     18.0
#define CELL_TAIL_WIDTH 16.0
#define MAX_WIDTH_OF_TEXT  200.0
#define CELL_PADDING    8.0
#define SCREENWIDTH     [UIScreen mainScreen].bounds.size.width
@implementation Message

+ (instancetype) messageWihtContent:(NSString *)content isRight:(BOOL)isRight {
    Message *msg = [Message new];
    msg.content = content;
    msg.isRight = isRight;
    
    CGRect rect = [msg.content boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
    CGRect frameOfLabel = CGRectZero;
    
    frameOfLabel.size = rect.size;
    if (msg.isRight) {
        frameOfLabel.origin.x = SCREENWIDTH - CELL_MARING_LR - CELL_TAIL_WIDTH - CELL_PADDING - rect.size.width - 30;
        frameOfLabel.origin.y = CELL_MARGIN_TB + CELL_PADDING;
        msg.contentframe = frameOfLabel;
        
        CGRect frameOfPop = frameOfLabel;
        frameOfPop.origin.x -= CELL_PADDING;
        frameOfPop.origin.y -= CELL_PADDING;
        frameOfPop.size.width += 2 * CELL_PADDING + CELL_TAIL_WIDTH;
        frameOfPop.size.height += 2* CELL_PADDING;
        msg.popframe = frameOfPop;
        
        CGRect bounds = CGRectMake(0, 0, SCREENWIDTH, 0);
        bounds.size.height = frameOfPop.size.height +2 * CELL_MARGIN_TB + 15;
        msg.bounds = bounds;
        
        msg.headerFrame = CGRectMake(SCREENWIDTH - 40, frameOfPop.size.height - 25, 30, 30);
        
        msg.userFrame = CGRectMake(SCREENWIDTH - 110, CGRectGetMaxY(msg.headerFrame), 100, 15);
        
        msg.errorFrame = CGRectMake(CGRectGetMinX(frameOfPop) -  10 - 20, CGRectGetMidY(frameOfPop) - 10, 20, 20);
    } else {
        frameOfLabel.origin.x = CELL_MARING_LR + CELL_TAIL_WIDTH + CELL_PADDING  + 30;
        frameOfLabel.origin.y = CELL_MARGIN_TB + CELL_PADDING;
        msg.contentframe = frameOfLabel;
        
        CGRect frameOfPop = frameOfLabel;
        frameOfPop.origin.x = CELL_MARING_LR + 30;
        frameOfPop.origin.y = CELL_MARGIN_TB;
        frameOfPop.size.width += 2*CELL_PADDING + CELL_TAIL_WIDTH;
        frameOfPop.size.height += 2 * CELL_PADDING;
        msg.popframe = frameOfPop;
        CGRect bounds = CGRectMake(0, 0, SCREENWIDTH, 0);
        bounds.size.height = frameOfPop.size.height +2 * CELL_MARGIN_TB + 15;
        msg.bounds = bounds;
        msg.headerFrame = CGRectMake(10, frameOfPop.size.height - 25, 30, 30);
        msg.userFrame = CGRectMake(10, CGRectGetMaxY(msg.headerFrame), 100, 15);
        msg.errorFrame = CGRectMake(CGRectGetMaxX(frameOfPop) + 10,  CGRectGetMidY(frameOfPop) - 10, 20, 20);
    }
    return msg;
}

//构造消息对象 -- 消息图片
+ (instancetype) messageWihtImage:(UIImage *)image isRight:(BOOL)isRight {
    Message *msg = [Message new];
    msg.image = image;
    msg.isRight = isRight;
    
    CGRect rect = CGRectMake(0, 0, image.size.width / image.size.height * 120, 120);//[msg.content boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
    CGRect frameOfLabel = CGRectZero;
    
    frameOfLabel.size = rect.size;
    if (msg.isRight) {
        frameOfLabel.origin.x = SCREENWIDTH - CELL_MARING_LR - CELL_TAIL_WIDTH - CELL_PADDING - rect.size.width - 30;
        frameOfLabel.origin.y = CELL_MARGIN_TB + CELL_PADDING;
        msg.imageFrame = frameOfLabel;
        
        CGRect frameOfPop = frameOfLabel;
        frameOfPop.origin.x -= CELL_PADDING;
        frameOfPop.origin.y -= CELL_PADDING;
        frameOfPop.size.width += 2 * CELL_PADDING + CELL_TAIL_WIDTH;
        frameOfPop.size.height += 2* CELL_PADDING;
        msg.popframe = frameOfPop;
        
        CGRect bounds = CGRectMake(0, 0, SCREENWIDTH, 0);
        bounds.size.height = frameOfPop.size.height +2 * CELL_MARGIN_TB;
        msg.bounds = bounds;
        
        msg.headerFrame = CGRectMake(SCREENWIDTH - 40, frameOfPop.size.height - 25, 30, 30);
    } else {
        frameOfLabel.origin.x = CELL_MARING_LR + CELL_TAIL_WIDTH + CELL_PADDING  + 30;
        frameOfLabel.origin.y = CELL_MARGIN_TB + CELL_PADDING;
        msg.imageFrame = frameOfLabel;
        
        CGRect frameOfPop = frameOfLabel;
        frameOfPop.origin.x = CELL_MARING_LR + 30;
        frameOfPop.origin.y = CELL_MARGIN_TB;
        frameOfPop.size.width += 2*CELL_PADDING + CELL_TAIL_WIDTH;
        frameOfPop.size.height += 2 * CELL_PADDING;
        msg.popframe = frameOfPop;
        CGRect bounds = CGRectMake(0, 0, SCREENWIDTH, 0);
        bounds.size.height = frameOfPop.size.height +2 * CELL_MARGIN_TB;
        msg.bounds = bounds;
        msg.headerFrame = CGRectMake(10, frameOfPop.size.height - 25, 30, 30);
    }
    return msg;
}


@end
