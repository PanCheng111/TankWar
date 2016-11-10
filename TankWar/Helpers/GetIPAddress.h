//
//  GetIPAddress.h
//  TankWar
//
//  Created by 潘成 on 16/6/30.
//  Copyright © 2016年 潘成. All rights reserved.
//

#ifndef GetIPAddress_h
#define GetIPAddress_h

#import <Foundation/Foundation.h>

@interface GetIPAddress : NSObject

+ (NSString *)deviceIPAdress;
+ (NSString *)routerIPAddress;

@end


#endif /* GetIPAddress_h */
