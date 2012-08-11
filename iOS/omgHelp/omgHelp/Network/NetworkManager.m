//
//  NetworkManager.m
//  omgHelp
//
//  Created by Cong Bach on 11/8/12.
//  Copyright (c) 2012 VSee Lab, Inc. All rights reserved.
//

#import "NetworkManager.h"
#import "AFJSONRequestOperation.h"

@implementation NetworkManager

@synthesize clientId = _clientId, vendorId = _vendorId;


static NetworkManager *_sharedNetworkManager;


+ (NetworkManager *)sharedNetworkManager
{
    if (! _sharedNetworkManager)
        _sharedNetworkManager = [[NetworkManager alloc] init];
    return _sharedNetworkManager;
}


- (id)init
{
    if (self = [super init])
    {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        _clientId = (NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        self.vendorId = @"0";
    }
    return self;
}


- (void)requestCategoriesWithCallBackTarget:(id)target selector:(SEL)selector
{
    NSURL *url = [NSURL URLWithString:@"http://www.omghelp.net/conversation-sample.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            if ([target respondsToSelector:selector])
                [target performSelectorOnMainThread:selector withObject:JSON waitUntilDone:NO];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Failed");
        NSLog(@"Error:%@", error);
    }];
    
    [operation start];
}

@end
