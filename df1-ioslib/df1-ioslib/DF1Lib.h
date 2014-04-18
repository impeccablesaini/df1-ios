//
//  df1_ioslib.h
//  df1-ioslib
//
//  Created by JB Kim on 3/23/14.
//  Copyright (c) 2014 JB Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1LibDefs.h"
#import "DF1LibUtil.h"

@protocol DF1Delegate;  // forward declaration

@interface DF1 : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

// Delegate properties should always be weak references
// See http://stackoverflow.com/a/4796131/263871 for the rationale
// (Tip: If you're not using ARC, use `assign` instead of `weak`)
@property (nonatomic, assign) id<DF1Delegate> delegate;

//-----------------------------------------------------------------------------
// MEMBERS
//-----------------------------------------------------------------------------
@property (strong,nonatomic) NSMutableArray *devices;
// @property (strong,nonatomic) NSMutableDictionary *registers;
@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) CBPeripheral *p;
@property (retain) CBPeripheral *ptemp;

//-----------------------------------------------------------------------------
// PUBLIC FUNCTIONS
//-----------------------------------------------------------------------------

-(id) initWithDelegate:(id<DF1Delegate>) delegate;
/*!
 *  @method scan:
 *
 *  @param maxDevices maximum number of peripherals to scan for.
 *
 *  @discussion  Initiates CBCentral scan for peripherals.
 *               Invokes {@link didScan:} delegate function for each
 *               unique peripheral discovered.
 */
-(void) scan:(NSUInteger) maxDevices;
-(void) stopScan:(BOOL) clear;
-(void) connect:(CBPeripheral*) peripheral;
-(void) disconnect:(CBPeripheral*) peripheral;
-(void) askRSSI:(CBPeripheral*) peripheral;

-(void) subscription:(UInt16) suuid withCUUID:(UInt16) cuuid onOff:(BOOL)enable;
-(void) subscribeXYZ8;
-(void) subscribeXYZ14;
-(void) subscribeTap;
-(void) subscribeFreefall;
-(void) subscribeMotion;
-(void) subscribeShake;

-(void) unsubscribeXYZ8;

-(void) modifyRange:(UInt8) value;

-(void) modifyTapThsz:(double) g; // 0.064g increment
-(void) modifyTapThsx:(double) g;
-(void) modifyTapThsy:(double) g;
-(void) modifyTapTmlt:(double) msec; // multiples of 10msec
-(void) modifyTapLtcy:(double) msec;
-(void) modifyTapWind:(double) msec;

-(void) modifyFreefallThs:(double) g; // 0.064g increment
-(void) modifyFreefallDeb:(double) msec; // 10msec increment

-(void) modifyMotionThs:(double) g; // 0.064g increment
-(void) modifyMotionDeb:(double) msec; // 10msec increment

-(void) modifyShakeThs:(double) g;
-(void) modifyShakeDeb:(double) msec;
-(void) modifyShakeHpf:(double) hz; // 0.063==1, 0.125=2, 0.25=4, 0.5=8, 1=16, 2=32, 4=64

@end


//-----------------------------------------------------------------------------
// DELEGATE INTERFACE
//-----------------------------------------------------------------------------
@protocol DF1Delegate <NSObject>

@required

-(bool) didScan:(NSArray*) devices;
-(void) didStopScan;
-(void) didConnectPeripheral:(CBPeripheral*) peripheral;
-(void) receivedXYZ8:(double*) data;
-(void) receivedXYZ14:(double*) data;

@optional

-(void) hasCentralErrors:(CBCentralManager*) central;
-(bool) didUpdateRSSI:(CBPeripheral*) peripheral withRSSI:(float) rssi;

@end
