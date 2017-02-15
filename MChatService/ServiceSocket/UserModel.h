//
//  UserModel.h
//  ServiceSocket
//
//  Created by 林涛 on 2017/2/3.
//  Copyright © 2017年 Longcai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * code;
@property (nonatomic, assign) BOOL onLine;
+(instancetype)userWithDictionary:(NSDictionary *)userDic;
-(NSDictionary *)formatUser;
-(BOOL)equal:(UserModel *)model;
@end
