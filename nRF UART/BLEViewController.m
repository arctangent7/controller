//
//  BLETableViewController.m
//  nRF UART
//
//  Created by shuhei chiba on 2015/10/14.
//  Copyright © 2015年 Progress Technologies. All rights reserved.
//

#import "ViewController.h"
#import "BLEViewController.h"
#import "PeripheralList.h"

@implementation BLEViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //ibeacon
    // delegateの設定
    self.tableBleList.delegate = self;
    self.tableBleList.dataSource = self;
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)awakeFromNib
{
    NSDictionary *dict;
    // tableデータの設定
    if (_rows == nil) {
        _rows = [NSMutableArray alloc];
    }
    else {
        [_rows removeAllObjects];
    }

    NSUInteger cnt = [PeripheralList count];
    _rows = [NSMutableArray arrayWithCapacity:cnt];
    for(NSUInteger i=0 ; i< cnt; i++) {
        dict = [PeripheralList getDictAtIndex:i];
        [_rows addObject:dict[@"kCBAdvDataLocalName"]];
    }
    
    [super awakeFromNib];
}

// ▼▼▼▼▼▼▼▼▼TableView用デリゲートメソッドの実装　ここから▼▼▼▼▼▼▼▼▼
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rows.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [_rows objectAtIndex:indexPath.row];
    // "cell"というkeyでcellデータを取得
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    // cellデータが無い場合、UITableViewCellを生成して、"cell"というkeyでキャッシュする
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = title;
    
    return cell;
}

// cellがタップされた際の処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択されたセルを取得
    
    [ViewController setSelectedPeripheral:indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// セルの選択がはずれた時に呼び出される
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
}
// ▲▲▲▲▲▲▲TableView用デリゲートメソッドの実装　ここまで▲▲▲▲▲▲▲▲

- (IBAction)pushedBleCancel:(id)sender {
    [ViewController cancelSelection];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
