//
//  Service.m
//  ServiceSocket
//
//  Created by Longcai on 16/3/9.
//  Copyright (c) 2016年 Longcai. All rights reserved.
//

#import "Service.h"
#import "GCDAsyncSocket.h"
#import <objc/runtime.h>
#import "UserModel.h"
@interface GCDAsyncSocket(Address)
@property (nonatomic, copy) NSString * address;
@end
static void *strKey = &strKey;
@implementation GCDAsyncSocket(Address)

-(void)setAddress:(NSString *)address{
    objc_setAssociatedObject(self, &strKey, address, OBJC_ASSOCIATION_ASSIGN);
}

-(NSString *)address{
    return objc_getAssociatedObject(self, &strKey);
}

@end

@interface Service()<GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncSocket * serverSocket;
@property (nonatomic,strong) NSMutableArray * clientSockets;
@property (nonatomic,strong) NSMutableDictionary * users;//在线用户,以及对应的client端
@property (nonatomic, strong) NSMutableArray <UserModel *> * usersInfo;//所有用户,包括离线用户
@property (nonatomic, strong) NSMutableDictionary * offLineMessage;//离线信息,以接收者的name为key保存,value是一个字典数组,每一个字典以发送者为key,对应的value是数组,数组记录了所有发送者对接收者的离线信息
@end

@implementation Service

+(Service *)shareServerInstance{
    static dispatch_once_t onceToken;
    static Service * server;
    dispatch_once(&onceToken, ^{
        server = [[Service alloc]init];
    });
    return server;
}

+(Service *)shareServerInstanceNoSingle{
    return [[Service alloc]init];
}



-(GCDAsyncSocket *)serverSocket{
    if (_serverSocket == nil) {
        _serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _serverSocket;
}


-(void)startServer{
    NSError * error = nil;
    [self.serverSocket acceptOnPort:1760 error:&error];
}

-(NSMutableArray *)clientSockets{
    if (_clientSockets == nil) {
        _clientSockets = [NSMutableArray array];
    }
    return _clientSockets;
}

-(NSMutableArray *)usersInfo{
    if (_usersInfo == nil) {
        _usersInfo = [NSMutableArray array];
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSArray <NSDictionary *> * userInfos = [ud valueForKey:@"users"];
        [userInfos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UserModel * model = [UserModel userWithDictionary:obj];
            [_usersInfo addObject:model];
        }];
    }
    return _usersInfo;
}

-(NSMutableDictionary *)users{
    if (_users==nil) {
        _users = [[NSMutableDictionary alloc] init];
    }
    return _users;
}

-(NSMutableDictionary *)offLineMessage{
    if (_offLineMessage == nil) {
        _offLineMessage = [[NSMutableDictionary alloc] init];
    }
    return _offLineMessage;
}

-(void)addNewUserWithModel:(UserModel *)newModel{
    [self.usersInfo addObject:newModel];
    NSMutableArray * userInfos = [[NSMutableArray alloc] init];
    [self.usersInfo enumerateObjectsUsingBlock:^(UserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary * userInfo = [obj formatUser];
        [userInfos addObject:userInfo];
    }];
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:userInfos forKey:@"users"];
    [ud synchronize];
}

-(void)writeDataWithSock:(GCDAsyncSocket *)sock dataDic:(id )dataDic tag:(long)tag{
    NSData * data = [NSJSONSerialization dataWithJSONObject:dataDic options:0 error:nil];
    NSMutableData * mdata = [NSMutableData dataWithData:data];
    [mdata appendData:[GCDAsyncSocket CRLFData]];
    [sock writeData:data withTimeout:-1 tag:tag];
}

#pragma mark --GCDAsyncSocketDelegate--

-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"%p",newSocket);
    [self.clientSockets addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:0];
}


-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSError * error;
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data
                                                          options:0
                                                            error:&error];
    if (error) {
        NSDictionary * responseDic = @{@"code":@(1005),@"msg":@"error"};
        [self writeDataWithSock:sock dataDic:responseDic tag:0];
        return;
    }
    NSString * idStr = dict[@"id"];
    if ([dict[@"handle"] isEqualToString:@"register"]) {//注册
        NSDictionary * userInfo = dict[@"msg"];
        __block BOOL isExit;
        [self.usersInfo enumerateObjectsUsingBlock:^(UserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:userInfo[@"name"]]) {
                isExit = YES;
                *stop = YES;
            }
        }];
        NSDictionary * responseDic;
        if (isExit) {
            responseDic = @{@"code":@(1006),@"msg":@"the name is exsit",@"handle":@"register",@"id":idStr};
        }else{
            UserModel * model = [UserModel userWithDictionary:userInfo];
            if (model==nil) {
                responseDic = @{@"code":@(1005),@"msg":@"format error",@"handle":@"register",@"id":idStr};
            }else{
                [self addNewUserWithModel:model];
                responseDic = @{@"code":@(8888),@"msg":@"success",@"handle":@"register",@"id":idStr};
                model.onLine = YES;
                [self.users setObject:@{@"info":model,@"client":sock} forKey:model.name];
            }
            
        }
        [self writeDataWithSock:sock dataDic:responseDic tag:0];
    }
    
    if ([dict[@"handle"] isEqualToString:@"login"]) {//登录
        NSDictionary * userInfo = dict[@"msg"];
        UserModel * model = [UserModel userWithDictionary:userInfo];
        [self.usersInfo enumerateObjectsUsingBlock:^(UserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj equal:model]){
                obj.onLine = YES;
                model.onLine = YES;
            }
        }];
        NSDictionary * responseDic;
        if (!model.onLine) {
            responseDic = @{@"code":@(1004),@"msg":[NSString stringWithFormat:@"not found name : %@",model.name],@"handle":@"login",@"id":idStr};
        }else{
            responseDic = @{@"code":@(8888),@"msg":@"success",@"handle":@"login",@"id":idStr};
            [self.users setObject:@{@"info":model,@"client":sock} forKey:model.name];
        }
        [self writeDataWithSock:sock dataDic:responseDic tag:0];
    }
    if ([dict[@"handle"] isEqualToString:@"chat"]) {//聊天
        NSString * from = dict[@"from"];
        id to = dict[@"to"];
        NSString * msg = dict[@"msg"];
        if (from.length == 0||msg.length == 0) {
            NSDictionary * dict = @{@"code":@(10010),@"msg":@"user or content error",@"handle":@"chat",@"id":idStr};
            [self writeDataWithSock:sock dataDic:dict tag:0];
        }
        
        if (![to isEqual:[NSNull null]]) {//私聊
            __block BOOL isExist = NO;
            __block NSUInteger index = -1;
            [self.usersInfo enumerateObjectsUsingBlock:^(UserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.name isEqualToString: to]) {
                    isExist = YES;
                    *stop = YES;
                    index = idx;
                }
            }];
            if (!isExist) {
                NSDictionary * dict = @{@"handle":@"chat",@"code":@"1011",@"msg":@"not find is user",@"from":from,@"to":to,@"id":idStr};
                [self writeDataWithSock:sock dataDic:dict tag:0];
            }else{
                NSDictionary * dict = @{@"handle":@"newMsg",@"msg":msg,@"from":from,@"to":to};
                UserModel * model = self.usersInfo[index];
                NSDictionary * userInfo = [self.users valueForKey:model.name];
                if (userInfo == nil) {
                    [self addOffLineMessage:dict];
                }else{
                    GCDAsyncSocket * toSock = userInfo[@"client"];
                    if (toSock != nil) {
                        [self writeDataWithSock:toSock dataDic:dict tag:0];
                    }else{
                        [self addOffLineMessage:dict];
                    }
                    NSDictionary * respDic = @{@"handle":@"chat",@"code":@(8888),@"id":idStr};
                    [self writeDataWithSock:sock dataDic:respDic tag:0];
                }
            }
        }else{//群聊
            NSDictionary * newMessage = @{@"handle":@"newMsg",@"msg":msg,@"from":from};
            [self.usersInfo enumerateObjectsUsingBlock:^(UserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.name isEqualToString:from]) {
                    return ;
                }
                NSDictionary * dict = self.users[obj.name];
                if (dict!=nil||[dict isKindOfClass:[NSNull class]]) {//在线
                    GCDAsyncSocket * friendClient = dict[@"client"];
                    [self writeDataWithSock:friendClient dataDic:newMessage tag:0];
                }else{//离线
                    [self addOffLineRoomMessageTo:obj.name message:newMessage];
                }
            }];
            
            NSDictionary * respDic = @{@"handle":@"chat",@"code":@(8888),@"id":idStr};
            [self writeDataWithSock:sock dataDic:respDic tag:0];
        }
    }
    if([dict[@"handle"] isEqualToString:@"getFriend"]){//获取好友及离线消息
        __block NSMutableArray <NSDictionary *> * users = [NSMutableArray array];
        [self.usersInfo enumerateObjectsUsingBlock:^(UserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray * offlineMessages = self.offLineMessage[dict[@"name"]][obj.name];
            NSDictionary * friend = @{@"name":obj.name,@"newMsg":offlineMessages==nil?[NSNull null]:offlineMessages};
            [users addObject:friend];
        }];
        NSArray * offlineRoomMsg = self.offLineMessage[dict[@"name"]][@"all"];
        if ([offlineRoomMsg isKindOfClass:[NSArray class]]&&offlineRoomMsg.count!=0) {
            NSDictionary * roomMsg = @{@"name":@"all",@"newMsg":offlineRoomMsg};
            [users addObject:roomMsg];
        }
        [self.offLineMessage removeObjectForKey:dict[@"name"]];
        NSDictionary * responce = @{@"handle":@"getFriend",@"id":idStr,@"users":users};
        [self writeDataWithSock:sock dataDic:responce tag:0];
    }
    if ([dict[@"handle"] isEqualToString:@"getNewMessage"]) {//主动获取新信息
        NSDictionary * offLineMessages = self.offLineMessage[dict[@"name"]]?self.offLineMessage[dict[@"name"]]:[NSNull null];
        NSDictionary * response = @{@"handle":@"getNewMessage",@"id":idStr,@"newMsg":offLineMessages};
        [self writeDataWithSock:sock dataDic:response tag:0];
        [self.offLineMessage removeObjectForKey:dict[@"name"]];
    }
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)addOffLineMessage:(NSDictionary*) message{
    NSString * from = message[@"from"];
    NSString * to = message[@"to"];
    NSMutableDictionary * dict = self.offLineMessage[to];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    NSMutableArray * fromMessage = dict[from];
    if (fromMessage == nil) {
        fromMessage = [NSMutableArray array];
    }
    [fromMessage addObject:message];
    [dict setObject:fromMessage forKey:from];
    [self.offLineMessage setObject:dict forKey:to];
}

-(void)addOffLineRoomMessageTo:(NSString *)name message:(NSDictionary *)message{
    NSMutableDictionary * dict = self.offLineMessage[name];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    NSMutableArray * fromMessage = dict[@"all"];
    if (fromMessage == nil) {
        fromMessage = [NSMutableArray array];
    }
    [fromMessage addObject:message];
    [dict setObject:fromMessage forKey:@"all"];
    [self.offLineMessage setObject:dict forKey:name];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"%p",sock);
    __block NSString * leaveUserName;
    [self.users enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj[@"client"] isEqual:sock]){
            leaveUserName = key;
            *stop = YES;
        }
    }];
    if (leaveUserName!=nil) {
        [self.users removeObjectForKey:leaveUserName];
    }
}

@end
