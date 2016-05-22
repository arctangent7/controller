//
//  ViewController.m
//  nRF UART
//
//  Created by shuhei chiba on 2015/11/12.
//  Copyright (c) 2015 Progress Technologies. All rights reserved.
//

#import "ViewController.h"
#import "BLEViewController.h"
#import "PeripheralList.h"
#import "TaboconSetting.h"


#define TIMER_INT 0.1f      // タイマー動作インターバル(sec)
#define SCAN_TIME 1.0f      // BLEスキャン時間

#define WAIT_COMMAND_OFF @"BWT:0"
#define WAIT_COMMAND_ON @"BWT:1"
#define DEFAULT_LED_VALUE @"127"

static NSTimeInterval count = 0;
static NSUInteger currentPeri = 0;
static ConnectionState state;

static float leftRotation = 0.0f;
static float rightRotation = 0.0f;

static float colorEyeR = 0.0f;
static float colorEyeG = 0.0f;
static float colorEyeB = 0.0f;

@interface ViewController ()
@property CBCentralManager *cm;
@property UARTPeripheral *currentPeripheral;
@end

@implementation ViewController
@synthesize cm = _cm;
@synthesize currentPeripheral = _currentPeripheral;



- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    self.cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [self addTextToConsole:@"Did start application" dataType:LOGGING];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];

    // モーター制御の画面部品を表示
    [self dispMotorControll];
    
    // 初回、アクティブモードとして送信しておく（NAKが来るかもしれないが気にしない）
    [self.currentPeripheral writeString:WAIT_COMMAND_OFF];
            
    // タイマー生成、開始
    [self createTimer];
    
}

- (void)viewWillAppear:(BOOL)animated {

    NSString *writeData = @"";
    switch (self.selectorMode.selectedSegmentIndex) {
        case 0:            // Active Mode
            writeData = WAIT_COMMAND_OFF;
            [self.currentPeripheral writeString:writeData];
            [self enableActiveMode:YES];
            break;
        case 1:
        default:
            writeData = WAIT_COMMAND_ON;
            [self.currentPeripheral writeString:writeData];
            [self enableActiveMode:NO];
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enableActiveMode:(BOOL)enable {
   
}

- (void)dispMotorControll
{
    // Motor操作に関する画面部品の表示
    self.settingButton.hidden = NO;
    
}

- (void)dispLedControll
{
    // Motor操作に関する画面部品の表示
    self.settingButton.hidden = YES;
}

/**
 * 目のカラーを徐々に切り替える
 */
- (void)updateEyeColor
{
    NSString *writeData = @"";
    writeData = [NSString stringWithFormat:@"LAL:500,%.0f,%.0f,%.0f", colorEyeR, colorEyeG, colorEyeB];
    [self.currentPeripheral writeString:writeData];
}

/**
 * タイマーを生成する
 */
- (void)createTimer
{
    // タイマーを生成（3秒後にdoTimer:メソッドを呼び出す．繰り返し）
    
    [NSTimer scheduledTimerWithTimeInterval:TIMER_INT
                                     target:self
                                   selector:@selector(doTimer:)
                                   userInfo:nil
                                    repeats:YES
     ];
    
}

/**
 * 指定時間後にタイマーから呼ばれる
 * @param timer 呼び出し元のNSTimerオブジェクト
 */
- (void)doTimer:(NSTimer *)timer
{
    NSString *writeData = @"";
    CBPeripheral* peripheral;

    switch (state) {
        case SCANNING:
            count += TIMER_INT;
            if (count >= SCAN_TIME) {
                // スキャンを停止しリスト画面へ。
                [self.cm stopScan];
                
                BLEViewController *view =  [self.storyboard instantiateViewControllerWithIdentifier:@"BLEViewController"];
                [self presentViewController:view animated:YES completion:nil];//YESならModal,Noなら何もなし
                state = SELECTING;
            }
            break;
        case SELECTING:
            break;
        case SELECTED:
            peripheral = [PeripheralList getAtIndex:currentPeri];
            self.currentPeripheral = [[UARTPeripheral alloc] initWithPeripheral:peripheral delegate:self];
            [self.cm connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
            [self updateEyeColor];
            
            break;
        case CANCELED:
            state = IDLE;
            
            NSLog(@"Stopped scan");
            [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            
            //[self.cm stopScan];
            break;

        case CONNECTED:
            writeData = [NSString stringWithFormat:@"MDD:%.0f, %.0f", rightRotation, leftRotation];
           [self.currentPeripheral writeString:writeData];
            break;

        default:
            break;
    }
}



// 接続ボタン
- (IBAction)connectButtonPressed:(id)sender
{
    switch (state) {
        case IDLE:
            state = SCANNING;
            
            NSLog(@"Started scan ...");
            [self.connectButton setTitle:@"Scanning ..." forState:UIControlStateNormal];
            [PeripheralList clear];
            [self.cm scanForPeripheralsWithServices:@[UARTPeripheral.uartServiceUUID] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @NO}];
            count = 0;  // BLEスキャン時間カウントのリセット
            break;
        case SELECTING:
            break;
        case SELECTED:
            break;
        case SCANNING:
            state = IDLE;

            NSLog(@"Stopped scan");
            [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];

            [self.cm stopScan];
            break;
            
        case CONNECTED:
            NSLog(@"Disconnect peripheral %@", self.currentPeripheral.peripheral.name);
            [self.cm cancelPeripheralConnection:self.currentPeripheral.peripheral];
            break;

        default:
            break;
    }
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}


- (void) didReadHardwareRevisionString:(NSString *)string
{
    [self addTextToConsole:[NSString stringWithFormat:@"Hardware revision: %@", string] dataType:LOGGING];
}

- (void) didReceiveData:(NSString *)string
{
    [self addTextToConsole:string dataType:RX];
}
- (IBAction)modeChanged:(id)sender {
    UISegmentedControl *sc = (UISegmentedControl*)sender;
    NSString *writeData = @"";
    switch ([sc selectedSegmentIndex]) {
        case 0:            // Active Mode
            writeData = WAIT_COMMAND_OFF;
            [NSThread sleepForTimeInterval:0.1];
            [self.currentPeripheral writeString:writeData];
            [self enableActiveMode:YES];
            break;
        case 1:
        default:
            writeData = WAIT_COMMAND_ON;
            [NSThread sleepForTimeInterval:0.1];
            [self.currentPeripheral writeString:writeData];
            [self enableActiveMode:NO];
            break;
    }
}
- (IBAction)segmentChanged:(id)sender {
    UISegmentedControl *sc = (UISegmentedControl*)sender;
    switch ([sc selectedSegmentIndex]) {
        case 0:         // モーター操作モード
            [self dispMotorControll];
            
            break;
            
        case 1:         // LED操作モード
        default:
            [self dispLedControll];
            break;
    }
}

// 送信データ表示
- (void) addTextToConsole:(NSString *) string dataType:(ConsoleDataType) dataType
{
    NSString *direction;
    switch (dataType)
    {
        case RX:
            direction = @"RX";
            break;
            
        case TX:
            direction = @"TX";
            break;
            
        case LOGGING:
            direction = @"Log";
    }
    
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSS"];
    
}

/**
 * たぼちゃん怒る
 */
- (IBAction)setEyeColorAngry:(id)sender {
    colorEyeR = 150.0f;
    colorEyeG = 0.0f;
    colorEyeB = 0.0f;
    if (state==CONNECTED) {
        [self updateEyeColor];
    }
}

/**
 * たぼちゃん喜ぶ
 */
- (IBAction)setEyeColorJoy:(id)sender {
    colorEyeR = 0.0f;
    colorEyeG = 150.0f;
    colorEyeB = 0.0f;
    if (state==CONNECTED) {
        [self updateEyeColor];
    }
}

- (IBAction)onLeftRotate:(id)sender {
    leftRotation = 50.0f;
    self.selectorMode.enabled = NO;
    if (state == CONNECTED) {
        self.connectButton.enabled = NO;
    }
}

- (IBAction)offLeftRotate:(id)sender {
    leftRotation = 0.0f;
    self.selectorMode.enabled = YES;
    if (state == CONNECTED) {
        self.connectButton.enabled = YES;
    }
}

- (IBAction)onRightRotate:(id)sender {
    rightRotation = 50.0f;
    self.selectorMode.enabled = NO;
    if (state == CONNECTED) {
        self.connectButton.enabled = NO;
    }
}

- (IBAction)offRightRotate:(id)sender {
    rightRotation = 0.0f;
    self.selectorMode.enabled = YES;
    if (state == CONNECTED) {
        self.connectButton.enabled = YES;
    }
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ((central.state == CBCentralManagerStatePoweredOn) ||    // BLEがON、またはシステムとの接続が一時的に切れた
        (central.state == CBCentralManagerStateResetting)) {
        [self.connectButton setEnabled:YES];
    }
    
}


// BLEのスキャンによりペリフェラルが見つかった！
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral %@", peripheral.name);
    if (peripheral.name.length > 0) {
        [PeripheralList add:[peripheral copy] : [advertisementData copy]];
    }
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect peripheral %@", peripheral.name);
    state = CONNECTED;
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    if ([self.currentPeripheral.peripheral isEqual:peripheral])
    {
        [self.currentPeripheral didConnect];
    }
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did disconnect peripheral %@", peripheral.name);
    state = IDLE;
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    
    if ([self.currentPeripheral.peripheral isEqual:peripheral])
    {
        [self.currentPeripheral didDisconnect];
    }
}


+ (void)setSelectedPeripheral:(NSUInteger)index {
    currentPeri = index;
    state = SELECTED;
}


+ (void)cancelSelection {
    state = CANCELED;
    
}



@end
