//
//  AppDelegate.h
//  聊天界面
//
//  Created by  王伟 on 2016/12/4.
//  Copyright © 2016年  王伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerController : UIViewController
@property (nonatomic, copy) NSString * userName;
@property (nonatomic, strong) NSString * userImage;
@property (nonatomic, assign) BOOL isRoomChat;
@property (nonatomic, copy) NSString * friendName;
@property (nonatomic, strong) NSString * friendImage;
@property (nonatomic, strong) NSArray * offMsg;
@property (nonatomic, copy) void (^NewMessageCallBack)(NSDictionary * messageDic,BOOL isRoomChat);
@property (nonatomic, copy) void (^APPBecomeActivity)(NSString * name, void (^NewMessageCallBack)(NSArray * newMessages));
@end
