//
//  NSData+Additions.m
//  TankWar
//
//  Created by 潘成 on 16/7/3.
//  Copyright © 2016年 潘成. All rights reserved.
//

#import <CFNetwork/CFNetwork.h>
#import <Foundation/Foundation.h>
#import "NSData+Additions.h"
#import <netinet/in.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/ethernet.h>
#import <net/if_dl.h>

@implementation NSData (Additions)

- (int)port
{
    int port;
    struct sockaddr *addr;
    
    addr = (struct sockaddr *)[self bytes];
    if(addr->sa_family == AF_INET)
        // IPv4 family
        port = ntohs(((struct sockaddr_in *)addr)->sin_port);
    else if(addr->sa_family == AF_INET6)
        // IPv6 family
        port = ntohs(((struct sockaddr_in6 *)addr)->sin6_port);
    else
        // The family is neither IPv4 nor IPv6. Can't handle.
        port = 0;
    
    return port;
}


- (NSString *)host
{
    struct sockaddr *addr = (struct sockaddr *)[self bytes];
    if(addr->sa_family == AF_INET) {
        char *address =
        inet_ntoa(((struct sockaddr_in *)addr)->sin_addr);
        if (address)
            return [NSString stringWithCString: address];
    }
    else if(addr->sa_family == AF_INET6) {
        struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addr;
        char straddr[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &(addr6->sin6_addr), straddr,
                  sizeof(straddr));
        return [NSString stringWithCString: straddr];
    }
    return nil;
}

@end
