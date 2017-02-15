//
//  UserModel.m
//  MChat
//
//  Created by 林涛 on 2017/2/15.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+(instancetype)shareModel{
    static UserModel * model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[UserModel alloc] init];
        model.isOnline = NO;
    });
    return model;
}
-(instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reconnect:)
                                                     name:SockReconnectNotification
                                                   object:nil];
    }
    return self;
}

-(void)reconnect:(NSNotification *)notification{
    if (self.isOnline) {
        return;
    }
    if (!self.name||!self.code) {
        return;
    }
    SockManager * manager = [SockManager shareManager];
    if (!(manager.statue == CONNECTED||manager.statue == CONNECTING)) {
        return;
    }
    NSDictionary * dict = @{@"msg":@{@"name":self.name,
                                     @"code":self.code},
                            @"handle":@"login"};
    
    
    [manager sendData:dict withBack:^(id response) {
        NSLog(@"登录成功");
    }];
}
@end
