//
//  OnLineListView.h
//  MChat
//
//  Created by 林涛 on 2017/2/7.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^LSelectUser)(NSInteger index);
@interface OnLineListView : UIView
//@{name:,image:,newMsg:}
@property (nonatomic, strong) NSMutableArray <NSDictionary *> * users;

@property (nonatomic, copy) LSelectUser selectCallBack;

@property (nonatomic, assign) BOOL isShow;

-(void)showWithFrame:(CGRect)frame;
-(void)hide;
-(void)reload;
@end
