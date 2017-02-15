//
//  SockManager.m
//  MChat
//
//  Created by 林涛 on 2017/2/4.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import "SockManager.h"
#import <GCDAsyncSocket.h>


NSString * const SockStatueChangeNotification = @"SockStatueChangeNotification";
NSString * const SockReceiveNewDataNotification = @"SockReceiveNewDataNotification";
NSString * const SockConnectErrorNotification = @"SockConnectErrorNotification";
NSString * const SockReconnectNotification = @"SockReconnectNotification";
int connect_times;

SockManager * manager = nil;

@interface SockManager()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket * client;

@property (nonatomic, strong) NSMutableArray <NSDictionary *> * sendDatas;
@property (nonatomic, strong) NSMutableDictionary * sendCallBackDic;
@property (nonatomic, strong) NSMutableArray * tags;
@property (nonatomic, assign) BOOL isReconnect;

@end

@implementation SockManager
+(instancetype)shareManager{
    if (manager==nil) {
        manager = [[SockManager alloc] init];
        [manager client];
        manager.statue = INIT;
        connect_times = 0;
        manager.isReconnect = NO;
    }
    return manager;
}

-(instancetype)init{
    if (self = [super init]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetConnectTimes:) name:UIApplicationWillEnterForegroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectWithError:) name:UIApplicationDidBecomeActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

-(GCDAsyncSocket *)client{
    if (_client == nil) {
        _client = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _client;
}

-(NSMutableArray *)sendDatas{
    if (!_sendDatas) {
        _sendDatas = [[NSMutableArray alloc] init];
    }
    return _sendDatas;
}

-(NSMutableDictionary *)sendCallBackDic{
    if (_sendCallBackDic == nil) {
        _sendCallBackDic = [NSMutableDictionary dictionary];
    }
    return _sendCallBackDic;
}

-(NSMutableArray *)tags{
    if (_tags == nil) {
        _tags = [[NSMutableArray alloc] init];
    }
    return _tags;
}

-(void)resetConnectTimes:(NSNotification *)notification{
    connect_times = 0;
}

-(SockStatue)connectWithError:(NSError **)error{
    if (connect_times >= 5) {
        *error = [NSError errorWithDomain:@"未能连接服务器" code:1009 userInfo:@{@"code":@(1009),@"domain":@"未能连接服务器"}];
        return self.statue;
    }else{
        if (self.statue == CONNECTING||self.statue == CONNECTED) {
            return CONNECTING;
        }
        self.statue = CONNECTING;
        if(![self.client connectToHost:@"192.168.2.73" onPort:1760 error:error]&&!error){
            [[NSNotificationCenter defaultCenter] postNotificationName:SockConnectErrorNotification
                                                                object:nil
                                                              userInfo:nil];
            self.statue = DISCONNECT;
            self.isReconnect = YES;
        }
        connect_times ++;
        return self.statue;
    }
}

-(SockStatue)getSockStatue{
    if (self.client.isConnected) {
        return CONNECTED;
    }
    return DISCONNECT;
}

-(void)disconnect{
    [self.client disconnect];
    connect_times = 5;
    self.statue = DISCONNECT;
}

-(void)sendData:(id )data withBack:(ResponseCall)callBack{
    NSString * idStr = [self ret32bitString];
    NSMutableDictionary * sendDic = [NSMutableDictionary dictionary];
    [sendDic addEntriesFromDictionary:data];
    [sendDic addEntriesFromDictionary:@{@"id":idStr}];
    
    NSMutableData * senderData = [NSMutableData
                                  dataWithData:[NSJSONSerialization dataWithJSONObject:sendDic
                                                                               options:0
                                                                                 error:nil]];
    [senderData appendData:[GCDAsyncSocket CRLFData]];
    if (self.statue == CONNECTED) {
        [self.client writeData:senderData withTimeout:-1 tag:0];
        [self.sendCallBackDic setObject:callBack forKey:idStr];
        [self.client readDataWithTimeout:-1 tag:0];
    }
    
    if (self.statue == CONNECTING) {
        NSDictionary * dict = nil;
        dict = @{@"sendData":senderData,@"callBack":callBack,@"id":idStr};
        [self.sendDatas addObject:dict];
    }
    
    if (self.statue == DISCONNECT) {
        NSError * error ;
        [self connectWithError:&error];
        if (error) {
            callBack(@{@"code":@(1009),@"msg":@"无法连接服务器!"});
        }
    }
}




-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --Utils--
-(NSString *)ret32bitString
{
    char data[32];
    for (int x=0;x< 32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

#pragma mark --GCDAsyncSocketDelegate--
//连上服务器时触发
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功");
    self.statue = CONNECTED;
    connect_times = 0;
    if(self.sendDatas.count != 0){
        [self.sendDatas enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData * sendData = obj[@"sendData"];
            ResponseCall callBack = obj[@"callBack"];
            NSString * idStr = obj[@"id"];
            [self.client writeData:sendData withTimeout:-1 tag:0];
            callBack != nil&&idStr!=nil? [self.sendCallBackDic setObject:callBack
                                                                  forKey:idStr]:[NSNull null];
        }];
    }
    [self.sendDatas removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:SockStatueChangeNotification
                                                        object:nil
                                                      userInfo:nil];
    if (self.isReconnect) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SockReconnectNotification
                                                            object:nil
                                                          userInfo:nil];
    }
}

//收到数据的处理
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"收到新消息");
    NSError * error;
    NSMutableDictionary * obj = [NSMutableDictionary dictionary];
    [obj addEntriesFromDictionary: [NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];
    NSString * idStr;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        idStr = obj[@"id"];
    }
    ResponseCall callBack = idStr != nil ? self.sendCallBackDic[idStr]:nil;
    [obj removeObjectForKey:@"id"];
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                callBack(@{@"code":@(1004),@"msg":@"can't anlyse read data"});
            }
        });
    }else{
        if ([obj[@"handle"] isEqualToString:@"newMsg"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SockReceiveNewDataNotification object:nil userInfo:obj];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callBack) {
                    callBack(obj);
                }
            });
        }
        if (idStr != nil && [self.sendCallBackDic.allKeys containsObject:idStr]) {
            [self.sendCallBackDic removeObjectForKey:idStr];
        }
    }
    [self.client readDataWithTimeout:-1 tag:0];
}

//向服务器发送信息时调用
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [sock readDataWithTimeout:-1 tag:tag];
    NSLog(@"向服务器发送新消息");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    NSLog(@"与服务器失去联系");
    self.statue = DISCONNECT;
    if (connect_times >= 5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SockStatueChangeNotification
                                                            object:nil
                                                          userInfo:nil];
        return;
    }
    NSError * error;
    [self connectWithError:&error];
}
@end
