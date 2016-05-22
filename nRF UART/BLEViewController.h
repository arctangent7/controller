//
//  BLETableViewController.h
//  nRF UART
//
//  Created by shuhei chiba on 2015/10/14.
//  Copyright © 2015年 Progress Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLEViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
   NSMutableArray *dataSource;
}
@property (weak, nonatomic) IBOutlet UITableView *tableBleList;

@property (strong, nonatomic) NSMutableArray *rows; // TableViewの文字列



@end
