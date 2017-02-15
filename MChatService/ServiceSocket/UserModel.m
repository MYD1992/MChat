//
//  UserModel.m
//  ServiceSocket
//
//  Created by 林涛 on 2017/2/3.
//  Copyright © 2017年 Longcai. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel
+(instancetype)userWithDictionary:(NSDictionary *)userDic{
    if (userDic[@"name"]==nil||userDic[@"code"]==nil) {
        return nil;
    }
    UserModel * model = [[UserModel alloc] init];
    model.name = userDic[@"name"];
    model.code = userDic[@"code"];
    model.onLine = NO;
    return model;
}

-(NSDictionary *)formatUser{
    NSDictionary * dic = @{@"name":self.name,@"code":self.code};
    return dic;
}

-(BOOL)equal:(UserModel *)model{
    return [self.name isEqualToString:model.name]&&[self.code isEqualToString:model.code];
}
@end
