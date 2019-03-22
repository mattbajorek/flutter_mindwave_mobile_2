/*
 *  MWMDelegate.h
 *
 *  Copyright 2016 NeuroSky, Inc.. All rights reserved.
 *
 *  All methods are required.
 */

#import <Foundation/Foundation.h>
#import "MWMEnum.h"

// Modified from original delegate
@protocol MWMDelegate <NSObject>

-(void)didConnect;
-(void)didDisconnect;

-(void)eegSample:(int) sample;

-(void)eSense:(int)poorSignal Attention:(int)attention Meditation:(int)meditation;

-(void)eegBlink:(int) blinkValue;

@end
