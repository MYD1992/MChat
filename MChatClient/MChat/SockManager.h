//
//  SockManager.h
//  MChat
//
//  Created by 林涛 on 2017/2/4.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, SockStatue) {
    INIT=1,
    CONNECTING,
    CONNECTED,
    DISCONNECT
};

typedef void(^ResponseCall)(id response);

@interface SockManager : NSObject
@property (nonatomic, assign) SockStatue statue;
+(instancetype)shareManager;
-(void)resetConnectTimes:(NSNotification *)notification;
-(SockStatue)connectWithError:(NSError **)error;
-(SockStatue)getSockStatue;
-(void)sendData:(id )data withBack:(ResponseCall)callBack;
-(void)disconnect;

extern NSString * const SockStatueChangeNotification;
extern NSString * const SockReceiveNewDataNotification;
extern NSString * const SockConnectErrorNotification;
extern NSString * const SockReconnectNotification;
@end
