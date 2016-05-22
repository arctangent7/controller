//
//  SettingViewController.m
//  nRF UART
//
//  Created by shuhei chiba on 2015/11/12.
//  Copyright © 2015 Progress Technologies. All rights reserved.
//

#import "SettingViewController.h"
#import "TaboconSetting.h"

@implementation SettingViewController

- (void)viewDidLoad {
    _motorStepper.value = [TaboconSetting loadMaxSpeed];
    _motorSpeedLabel.text = [NSString stringWithFormat:@"%.0f",_motorStepper.value];

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (IBAction)changedStepperValue:(id)sender {
    UIStepper *stp = (UIStepper*)sender;
    if (stp.value == 4086) {
        stp.value = 4090;
    }
    _motorSpeedLabel.text = [NSString stringWithFormat:@"%.0f",stp.value];
}

- (IBAction)onDefaultButton:(id)sender {
    _motorStepper.value = 600;
    _motorSpeedLabel.text = @"600";
    
}
- (IBAction)onApplyButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [TaboconSetting saveMaxSpeed:_motorStepper.value];
}
@end
