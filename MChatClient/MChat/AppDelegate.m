//
//  AppDelegate.m
//  MChat
//
//  Created by 林涛 on 2017/2/4.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self connectToServe];
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * name = [ud objectForKey:@"name"];
    NSString * code = [ud objectForKey:@"code"];
    if (name&&code) {
        UserModel * model = [UserModel shareModel];
        model.name = name;
        model.code = code;
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    //即将退出时
    SockManager * shareManager = [SockManager shareManager];
    [shareManager disconnect];
    shareManager = nil;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //已退出
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    //即将进入前台
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    //已进入前台
    SockManager * manager = [SockManager shareManager];
    __autoreleasing NSError * error = nil;
    [manager resetConnectTimes:nil];
    SockStatue statue = [manager connectWithError:&error];
    if (statue != CONNECTING) {
        [self.window makeToast:@"连接服务器失败" duration:2 position:CSToastPositionBottom];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    //程序即将终止
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)connectToServe{
    SockManager * manager = [SockManager shareManager];
    __autoreleasing NSError * error = nil;
    SockStatue statue = [manager connectWithError:&error];
    if (statue != CONNECTING) {
        [self.window makeToast:@"连接服务器失败" duration:2 position:CSToastPositionBottom];
    }
}

@end
