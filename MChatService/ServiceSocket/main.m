//
//  main.m
//  ServiceSocket
//
//  Created by Longcai on 16/3/9.
//  Copyright (c) 2016年 Longcai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[Service shareServerInstance] startServer];
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
