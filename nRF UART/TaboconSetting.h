//
//  TaboconSetting.h
//  nRF UART
//
//  Created by shuhei chiba on 2015/11/12.
//  Copyright © 2015年 Nordic Semiconductor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaboconSetting : NSObject
+ (void)saveMaxSpeed:(double)max_speed;
+ (double)loadMaxSpeed;

@end
