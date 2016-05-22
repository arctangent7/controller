//
//  SettingViewController.h
//  nRF UART
//
//  Created by shuhei chiba on 2015/11/12.
//  Copyright © 2015年 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIStepper *motorStepper;
@property (weak, nonatomic) IBOutlet UILabel *motorSpeedLabel;
@end
