//
//  PeripheralList.m
//  nRF UART
//
//  Created by shuhei chiba on 2015/10/14.
//  Copyright © 2015年 Progress Technologies. All rights reserved.
//

#import "PeripheralList.h"

static NSMutableArray *peri;
static NSUInteger cnt = 0;
static CBPeripheral *periList[50];
static NSDictionary *dicList[50];


@implementation PeripheralList



+ (void)initialize {
    if (peri == nil) {
        peri = [NSMutableArray alloc];
    }
}
+ (void)add:(CBPeripheral *)peripheral :(NSDictionary*) dict{
    
    //if ([peri containsObject:peripheral] == NO) {
    //    [peri addObject:peripheral];
    periList[cnt] = peripheral;
    dicList[cnt] = dict;
    
    //}
    cnt++;
}


+ (void) clear {
    cnt = 0;
}

+ (NSUInteger) count {
    return cnt;
}

+ (CBPeripheral*) getAtIndex: (NSUInteger)index {
    return periList[index];
}
+ (NSDictionary*) getDictAtIndex: (NSUInteger)index {
    return dicList[index];
}


@end
