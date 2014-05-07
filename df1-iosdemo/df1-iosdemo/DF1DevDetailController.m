//
//  DF1DevDetailController.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0

#import "DF1DevDetailController.h"
#import "DF1DevListController.h"
#import "DF1Lib.h"

@interface DF1DevDetailController ()
{
    NSTimer *reconnectTimer;
    NSTimer *eventResetTimer;
    BOOL isConnecting;
    double xyzUpdateTime;
    int connectionRetries;
    int subscriptionRetries;
}

@end


@implementation DF1DevDetailController

@synthesize df;

-(id)initWithDF:(DF1*) userdf
{
    self = [super init];
    if(self) {
        [self initializeCells];
        self.df = userdf;
        self.df.delegate = self;
    }
    return self; 
}

-(void)initializeCells
{
    if(!self.accXyzCell) {
        self.accXyzCell = [[AccXYZCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"AccXYZCell"];
        // do other default initialization here
        self.accXyzCell.accLabel.text = @"Acceleration";
        self.accXyzCell.accValueX.text = @"x axis";
        self.accXyzCell.accValueY.text = @"y axis";
        self.accXyzCell.accValueZ.text = @"z axis";
    }
    if(!self.battCell) {
        self.battCell = [[BattCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"BattCell"];
        self.battCell.battLabel.text = @"Battery Level";
        self.battCell.battLevel.text = @"NA";
        self.battCell.battBar.progress = 0.0;
    }
    if(!self.accTapCell) {
        self.accTapCell = [[AccTapCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:@"AccTapCell"];
        self.accTapCell.accLabel.text = @"Tap Event";
        self.accTapCell.accValueTap.text = @"no events";
    }
    // if(!self.rssiCell) {
    //     self.rssiCell = [[RSSICell alloc] initWithStyle:UITableViewCellStyleDefault
    //                                           reuseIdentifier:@"RSSICell"];
    // }
}


-(void)viewDidLoad
{
    [super viewDidLoad];
     
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.navigationController) {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.4
                                                                green:0.4 blue:0.9 alpha:0.5];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    // removing subscription has to happen before we reset the delegate for df object
    [self.df unsubscribeBatt];
    [self.df unsubscribeXYZ8];
    [self.df unsubscribeTap];
    [(DF1DevListController*) self.previousVC willTransitionBack:self.df];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
    // int count = 1; // by default we need the signal strength
    // if([self.d isEnabled:@"Accelerometer service active"])
    //   count += 2;
    // if([self.d isEnabled:@"Battery service active"])
    //   count += 1;
    // if([self.d isEnabled:@"LED service active"])
    //   count += 1;
    // // Return the number of rows in the section.
    // return count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DF_DBG(@"indexpath row: %ld", (long)indexPath.row);
    if(indexPath.row==0) {
        return self.accXyzCell;
    }
    if(indexPath.row==1) {
        return self.accTapCell;
    }
    if(indexPath.row==2) {
        return self.battCell;
    }
    // if (indexPath.row==0 && [self.d isEnabled:@"Accelerometer service active"]) {
    //     [self.babyCell setPosition:UACellBackgroundViewPositionTop];
    //     return self.babyCell;
    // }
    // // Something has gone wrong, because we should never get here, return empty cell
    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Unkown Cell"];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0) return self.accXyzCell.height;
    if(indexPath.row==1) return self.accTapCell.height;
    if(indexPath.row==2) return self.battCell.height;
    return 100;
}


- (void) tableView:(UITableView*) tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
    }
    return @"";
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - DF1Delegate delegate functions

-(bool) didScan:(NSArray*) devices
{
    return true;
}

-(void) didStopScan
{
}

// this function gets called when services and characteristics are all discovered
-(void) didConnect:(CBPeripheral*) peripheral
{
    // [self.df subscribeBatt];
    // [self.df subscribeXYZ8];
    // [self.df subscribeTap];
}

-(void) didSyncParameters:(NSDictionary *)params
{
    NSLog(@"%@",params);
    [self.df subscribeBatt];
    [self.df subscribeXYZ8];
    [self.df subscribeTap];
}

-(void) didUpdateRSSI:(CBPeripheral*) peripheral withRSSI:(float) rssi
{
}

-(void) receivedBatt:(float) battlev
{
    DF_DBG(@"received battery data: %f",battlev);
    self.battCell.battLevel.text = [[NSString alloc] initWithFormat:@"%.0f%%", battlev*100.0];
    self.battCell.battBar.progress = battlev;
    self.battCell.battBar.progressTintColor =
        (battlev > 0.75)                   ? [UIColor greenColor] :
        (battlev > 0.50 & battlev <= 0.75) ? [UIColor orangeColor] :
        (battlev <= 0.50)                  ? [UIColor redColor] : [UIColor redColor];
}

-(void) receivedXYZ8:(NSArray*) data
{
    float x = [data[0] floatValue];
    float y = [data[1] floatValue];
    float z = [data[2] floatValue];
    // self.accXyzCell.accBarX.progress = (x + 2) / 4.0;
    self.accXyzCell.accValueX.text = [[NSString alloc] initWithFormat:@"X: %.3f", x];
    self.accXyzCell.accXStrip.value = x;
    self.accXyzCell.accValueY.text = [[NSString alloc] initWithFormat:@"Y: %.3f", y];
    self.accXyzCell.accYStrip.value = y;
    self.accXyzCell.accValueZ.text = [[NSString alloc] initWithFormat:@"Z: %.3f", z];
    self.accXyzCell.accZStrip.value = z;
}

-(void) receivedXYZ14:(NSArray*) data
{
}

-(void) _resetTap
{
    self.accTapCell.accValueTap.textColor = [UIColor blackColor];
    self.accTapCell.accValueTap.text = @"no event";
}

-(void) receivedTap:(NSMutableDictionary*) tbl
{
    NSInteger hasEvent = [[tbl valueForKey:@"TapHasEvent"] intValue];
    NSInteger isZEvent = [[tbl valueForKey:@"TapIsZEvent"] intValue];
    
    if(hasEvent>0) DF_DBG(@"has tap!");
    
    if(hasEvent) {
        self.accTapCell.accValueTap.textColor = [UIColor redColor];
        self.accTapCell.accValueTap.text = [[NSString alloc] initWithFormat:@"Tap!"];
        eventResetTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(_resetTap)
                                                         userInfo:nil repeats:FALSE];
    } else {
        self.accTapCell.accValueTap.text = @"no event";
    }
}

@end
