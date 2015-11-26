//
//  ScannerTableViewController.h
//  VIsual
//
//  Created by Jacob Rosenthal on 11/25/15.
//  Copyright © 2015 Augmentous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ScannerTableViewController : UITableViewController <CBCentralManagerDelegate>

@property (strong) NSArray* services;

- (id)initWithCompletion:(void(^)(CBPeripheral *peripheral))completion;

@end
