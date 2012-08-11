//
//  NetworkManager.h
//  omgHelp
//
//  Created by Cong Bach on 11/8/12.
//  Copyright (c) 2012 VSee Lab, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject {
    NSString *_clientId, *_vendorId;
}

@property (retain, nonatomic) NSString *clientId, *vendorId;

- (void)requestCategoriesWithCallBackTarget:(id)target selector:(SEL)selector;

+ (NetworkManager *)sharedNetworkManager;

@end