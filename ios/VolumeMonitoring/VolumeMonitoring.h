//
//  VolumeMonitoring.h
//  VolumeMonitoring
//
//  Created by meitongzhou on 2019/3/7.
//  Copyright © 2019 meitongzhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface VolumeMonitoring : RCTEventEmitter<RCTBridgeModule>
@property (nonatomic, readonly) BOOL isMonitoring;
@end
