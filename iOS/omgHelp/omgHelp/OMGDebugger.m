//
//  OMGDebugger.m
//  omgHelp
//
//  Created by Cong Bach on 11/8/12.
//  Copyright (c) 2012 VSee Lab, Inc. All rights reserved.
//

#import "OMGDebugger.h"

@implementation OMGDebugger

static OMGDebugger *_sharedDebugger;

+ (OMGDebugger *)sharedDebugger
{
    if (! _sharedDebugger)
        _sharedDebugger = [[OMGDebugger alloc] init];
    return _sharedDebugger;
}

- (void)log:(NSString *)msg
{
#if BUILD_RELEASE
    NSLog(@"%@", msg);
#elif BUILD_DEBUG
    NSLog(@"%@", msg);
#endif
}

@end
