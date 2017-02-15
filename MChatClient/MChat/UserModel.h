//
//  UserModel.h
//  MChat
//
//  Created by 林涛 on 2017/2/15.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
@property (nonatomic, copy)  NSString * name;
@property (nonatomic, copy)  NSString * code;
@property (nonatomic, assign) BOOL isOnline;
+(instancetype)shareModel;
@end
