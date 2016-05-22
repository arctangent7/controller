//
//  TaboconSetting.m
//  nRF UART
//
//  Created by shuhei chiba on 2015/11/12.
//  Copyright © 2015年 2015 Progress Technologies. All rights reserved.
//

#import "TaboconSetting.h"

@implementation TaboconSetting
+ (void)saveMaxSpeed:(double)max_speed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:max_speed forKey:@"max_speed"];
    [userDefaults synchronize];
}

+ (double)loadMaxSpeed
{
    double ret;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    ret = [userDefaults doubleForKey:@"max_speed"];
    if (ret == 0) {
        return 600;
    }
    return ret;
}

@end
