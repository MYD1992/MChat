//
//  Service.h
//  ServiceSocket
//
//  Created by Longcai on 16/3/9.
//  Copyright (c) 2016年 Longcai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Service : NSObject
-(void)startServer;
+(Service *)shareServerInstance;
+(Service *)shareServerInstanceNoSingle;
@end
