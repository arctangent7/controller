//
//  ViewController.h
//  nRF UART
//
//  Created by Ole Morten on 1/11/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UARTPeripheral.h"

typedef enum
{
    IDLE = 0,
    SCANNING,
    SELECTING,
    SELECTED,
    CANCELED,
    CONNECTED,
} ConnectionState;

typedef enum
{
    LOGGING,
    RX,
    TX,
} ConsoleDataType;

@interface ViewController : UITableViewController <UITextFieldDelegate, CBCentralManagerDelegate, UARTPeripheralDelegate>
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectorMode;
@property (weak, nonatomic) IBOutlet UIButton *buttonLeftRotate;


- (IBAction)connectButtonPressed:(id)sender;


+ (void)setSelectedPeripheral:(NSUInteger)index;
+ (void)cancelSelection;
@end
