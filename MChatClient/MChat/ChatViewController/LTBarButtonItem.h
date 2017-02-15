//
//  LTBarButtonItem.h
//  MChat
//
//  Created by 林涛 on 2017/2/9.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTBarButtonItem : UIView
-(_Nonnull instancetype) initWithTarget:(_Nonnull id)target
                                 action:(_Nonnull SEL)action
                                  image:( UIImage * _Nonnull )image;
-(void)setNumber:(NSInteger)number;
-(void)setVerticalPositionAdjustment:(CGFloat) adjustment;
@end
