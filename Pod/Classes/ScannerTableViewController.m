//
//  ScannerTableViewController.m
//  VIsual
//
//  Created by Jacob Rosenthal on 11/25/15.
//  Copyright © 2015 Augmentous. All rights reserved.
//

#import "ScannerTableViewController.h"

@interface ScannerTableViewController ()

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableDictionary *advertisingData;
@property (strong, nonatomic) NSMutableArray *foundPeripherals;
@property (strong, nonatomic) UINavigationBar* navigationBar;
@property (nonatomic, copy) void(^completion)(CBPeripheral *peripheral);

@end

@implementation ScannerTableViewController

@synthesize centralManager;
@synthesize foundPeripherals;
@synthesize advertisingData;

- (id)initWithCompletion:(void(^)(CBPeripheral *peripheral))completion
{
    self = [super init];
    if( self )
    {
        _completion = completion;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.foundPeripherals = [NSMutableArray arrayWithCapacity:8];
    self.advertisingData = [[NSMutableDictionary alloc] init];
    
    self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];

    self.navigationItem.title = @"Select your device";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [centralManager stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [foundPeripherals objectAtIndex:indexPath.row];
    _completion(peripheral);
    [self dismiss:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.foundPeripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"%li", (long)indexPath.row];
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CBPeripheral *periph = [self.foundPeripherals objectAtIndex:indexPath.row];
    
    NSMutableDictionary *dict = [self.advertisingData objectForKey:periph.identifier];
    NSDictionary *advertisementData = [dict objectForKey:@"advertisementData"];
    cell.textLabel.text = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    return cell;
}


#pragma mark - CBCentral

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:self.services options:nil];
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![foundPeripherals containsObject:peripheral]) {
        [foundPeripherals addObject:peripheral];
    }
    
    NSMutableDictionary *peripheralDict = [[NSMutableDictionary alloc] init];
    [peripheralDict setObject:RSSI forKey:@"RSSI"];
    [peripheralDict setObject:advertisementData forKey:@"advertisementData"];
    [peripheralDict setObject:[NSDate date] forKey:@"lastSeen"];
    
    [advertisingData setObject:peripheralDict forKey:[peripheral identifier]];

    
    [self.tableView reloadData];
}


#pragma mark - UIView

- (IBAction)dismiss:(id)sender{
    [self dismissViewControllerAnimated: YES completion: nil];
}


@end
