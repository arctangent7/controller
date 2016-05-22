//
//  PeripheralList.h
//  nRF UART
//
//  Created by shuhei chiba on 2015/10/14.
//  Copyright © 2015年 Progress Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralList : NSObject

+ (void) add: (CBPeripheral*) peripheral: (NSDictionary*) dict;
+ (void) clear;
+ (NSUInteger) count;
+ (CBPeripheral*) getAtIndex: (NSUInteger)index;
+ (NSDictionary*) getDictAtIndex: (NSUInteger)index;

@end
