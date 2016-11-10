//
//  GetIPAddress.m
//  TankWar
//
//  Created by 潘成 on 16/6/30.
//  Copyright © 2016年 潘成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetIPAddress.h"


#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation GetIPAddress

+ (NSString *)deviceIPAdress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    NSLog(@"手机的IP是：%@", address);
    return address;  
}

+ (NSString *)routerIPAddress {
    if ([self deviceIPAdress].length > 0) {
        NSArray *ipArray = [[self deviceIPAdress] componentsSeparatedByString:@"."];
        NSString *ip = @"";
        for (int i = 0; i < 3; i++) {
            if (i == 0) ip = [NSString stringWithFormat:@"%@", ipArray[i]];
            else ip = [NSString stringWithFormat:@"%@.%@", ip, ipArray[i]];
        }
        ip = [NSString stringWithFormat:@"%@.1", ip];
        return ip;
    }
    else return nil;
}

@end
