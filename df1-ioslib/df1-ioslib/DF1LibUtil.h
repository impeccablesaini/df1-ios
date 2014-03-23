//
//  DF1LibUtil.h
//  DF1Lib
//
//  Created by JB Kim on 12/16/13.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface DF1LibUtil : NSObject

+(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID
cUUID:(NSString *)cUUID;

+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral
sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable;
+(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID
cUUID:(NSString *)cUUID data:(NSData *)data;

+(void)writeCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID
cCBUUID:(CBUUID *)cCBUUID data:(NSData *)data;
+(void)readCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID
cCBUUID:(CBUUID *)cCBUUID;
+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral
sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID enable:(BOOL)enable;

+(bool) isCharacteristicNotifiable:(CBPeripheral *)peripheral sCBUUID:(CBUUID
*)sCBUUID cCBUUID:(CBUUID *) cCBUUID;

/// Function to expand a TI 16-bit UUID to TI 128-bit UUID
+(CBUUID *) expandToTIUUID:(CBUUID *)sourceUUID;
/// Function to convert an CBUUID to NSString
+(NSString *) CBUUIDToString:(CBUUID *)inUUID;

+(const char *) UUIDToString:(CFUUIDRef)UUID;
+(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
+(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2;
+(UInt16)   CBUUIDToInt:(CBUUID *) UUID;
+(CBUUID *) IntToCBUUID:(UInt16)UUID;
+(UInt16) swap:(UInt16)s;

+(BOOL) doesPeripheral: (CBPeripheral*) p haveServiceUUID:(CBUUID*) uuid;
+(BOOL) isUUID: (CBUUID*) uuid thisInt: (UInt16) intuuid;

@end

//  http://stackoverflow.com/questions/1667994/best-practices-for-error-logging-and-or-reporting-for-iphone

// - (void)myMethod:(NSObject *)xiObj
// {
//   DF_ENTRY;
//   DF_DBG(@"Boring low level stuff");
//   DF_NRM(@"Higher level trace for more important info");
//   DF_ALT(@"Really important trace, something bad is happening");
//   DF_ERR(@"Error, this indicates a coding bug or unexpected condition");
//   DF_EXIT;
// }

#ifndef DF_LEVEL
#if TARGET_IPHONE_SIMULATOR != 0
#define DF_LEVEL 0
#else
#define DF_LEVEL 5
#endif
#endif

/*****************************************************************************/
/* Entry/exit trace macros                                                   */
/*****************************************************************************/
#if DF_LEVEL == 0
#define DF_ENTRY    NSLog(@"ENTRY: %s:%d:", __PRETTY_FUNCTION__,__LINE__);
#define DF_EXIT     NSLog(@"EXIT:  %s:%d:", __PRETTY_FUNCTION__,__LINE__);
#else
#define DF_ENTRY
#define DF_EXIT
#endif

/*****************************************************************************/
/* Debug trace macros                                                        */
/*****************************************************************************/
#if (DF_LEVEL <= 1)
#define DF_DBG(A, ...) NSLog(@"DEBUG: %s:%d:%@", \
    __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define DF_DBG(A, ...)
#endif

#if (DF_LEVEL <= 2)
#define DF_NRM(A, ...) NSLog(@"NORMAL:%s:%d:%@", \
    __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define DF_NRM(A, ...)
#endif

#if (DF_LEVEL <= 3)
#define DF_ALT(A, ...) NSLog(@"ALERT: %s:%d:%@", \
    __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define DF_ALT(A, ...)
#endif

#if (DF_LEVEL <= 4)
#define DF_ERR(A, ...) NSLog(@"ERROR: %s:%d:%@", \
    __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define DF_ERR(A, ...)
#endif
