//
//  CallViewController.m
//  omgHelp
//
//  Created by Cong Bach on 11/8/12.
//  Copyright (c) 2012 VSee Lab, Inc. All rights reserved.
//

#import "CallViewController.h"
#import "AppDelegate.h"
#import "NetworkManager.h"
#import "OMGDebugger.h"

@interface CallViewController ()

@end

@implementation CallViewController

static NSString *const kApiKey = @"1127";//@"17077042";

@synthesize categoryId = _categoryId;
@synthesize activityIndicator = _activityIndicator;
@synthesize connectingLabel = _connectingLabel;
@synthesize videoView = _videoView;
@synthesize overlayView = _overlayView;
@synthesize JSON = _JSON;
@synthesize token = _token;
@synthesize sessionId = _sessionId;
@synthesize opentokSession = _opentokSession;
@synthesize opentokPublisher = _opentokPublisher;
@synthesize pullRequestTimer = _pullRequestTimer;

#pragma mark - CallViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}


- (id)initWithCategoryId:(int)categoryId
{
    if (self = [self init])
    {
        self.categoryId = categoryId;
    }
    return self;
}


- (void)dealloc
{
    self.JSON = nil;
    self.token = nil;
    self.sessionId = nil;
    self.opentokSession = nil;
    self.opentokPublisher = nil;
    self.pullRequestTimer = nil;
    
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[AppDelegate sharedAppDelegate] navigationController] navigationBar].hidden = YES;
    
    // hack to get correct video ration
    [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:(id)UIInterfaceOrientationLandscapeRight];
    
    [self.activityIndicator startAnimating];
    [[NetworkManager sharedNetworkManager] startCallWithCategoryId:self.categoryId callbackTarget:self selector:@selector(startCallWithJSON:)];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tapRecoginzer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureCallback:)] autorelease];
    [self.videoView addGestureRecognizer:tapRecoginzer];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)pullCallInfo
{
    [[NetworkManager sharedNetworkManager] pullCallInfoWithSessionId:self.sessionId callbackTarget:self selector:@selector(updateCallWithJSON::)];
}


- (void)startCallWithJSON:(id)JSON
{
    self.JSON = JSON;
    
    self.token = [JSON valueForKeyPath:@"Conversation.Token"];
    self.sessionId = [JSON valueForKeyPath:@"Conversation.SessionId"];
    
    [self doConnect];
}


- (void)updateCallWithJSON:(id)JSON
{
    self.JSON = JSON;
    
    [[OMGDebugger sharedDebugger] log:[NSString stringWithFormat:@"%@", [JSON valueForKeyPath:@"Conversation.Image"]]];
}


- (void)tapGestureCallback:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    BOOL hidden = ! self.overlayView.hidden;
    float alpha = hidden ? 0.0f : 1.0f;
    self.overlayView.hidden = hidden;
    self.overlayView.alpha = alpha;
    [UIView setAnimationDuration:1.0f];
    [UIView commitAnimations];
}


#pragma mark - IBActions

- (IBAction)endCall:(id)sender
{
    [self doUnpublish];
    [self doDisconnect];
    [[NetworkManager sharedNetworkManager] endCallWithSessionId:self.sessionId];

    [[[AppDelegate sharedAppDelegate] navigationController] popToRootViewControllerAnimated:NO];
}


#pragma mark - OpenTok methods

- (void)doConnect 
{
    _opentokSession = [[OTSession alloc] initWithSessionId:_sessionId delegate:self];
    [_opentokSession connectWithApiKey:kApiKey token:_token];
}

- (void)doDisconnect 
{
    [_opentokSession disconnect];
}

- (void)doPublish
{
    _opentokPublisher = [[OTPublisher alloc] initWithDelegate:self];
    _opentokPublisher.publishAudio = YES;
    _opentokPublisher.publishVideo = YES;
    _opentokPublisher.cameraPosition = AVCaptureDevicePositionBack;
    [_opentokSession publish:_opentokPublisher];
    [self.videoView addSubview:_opentokPublisher.view];
    [_opentokPublisher.view setFrame:CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height)];
    [_opentokPublisher.view setUserInteractionEnabled:NO];
    
    self.pullRequestTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(pullCallInfo) userInfo:nil repeats:YES];
}

- (void)doUnpublish
{
    [_opentokSession unpublish:_opentokPublisher];
    [self.pullRequestTimer invalidate];
    self.pullRequestTimer = nil;
}


#pragma mark - OTSessionDelegate methods

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect: %@", session.sessionId);
    NSLog(@"- connectionId: %@", session.connection.connectionId);
    NSLog(@"- creationTime: %@", session.connection.creationTime);
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session 
{
    NSLog(@"sessionDidDisconnect: %@", session.sessionId);
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"session: didFailWithError:");
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
    
    [[OMGDebugger sharedDebugger] logError:[NSString stringWithFormat:@"Error connecting to session:%@", error]];
}

- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    NSLog(@"session: didReceiveStream:");
    NSLog(@"- connection.connectionId: %@", stream.connection.connectionId);
    NSLog(@"- connection.creationTime: %@", stream.connection.creationTime);
    NSLog(@"- session.sessionId: %@", stream.session.sessionId);
    NSLog(@"- streamId: %@", stream.streamId);
    NSLog(@"- type %@", stream.type);
    NSLog(@"- creationTime %@", stream.creationTime);
    NSLog(@"- name %@", stream.name);
    NSLog(@"- hasAudio %@", (stream.hasAudio ? @"YES" : @"NO"));
    NSLog(@"- hasVideo %@", (stream.hasVideo ? @"YES" : @"NO"));
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream
{
    NSLog(@"session didDropStream (%@)", stream.streamId);
}

#pragma mark - OTPublisherDelegate methods

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error
{
    NSLog(@"publisher: %@ didFailWithError:", publisher);
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}

- (void)publisherDidStartStreaming:(OTPublisher *)publisher
{
    NSLog(@"publisherDidStartStreaming: %@", publisher);
    NSLog(@"- publisher.session: %@", publisher.session.sessionId);
    NSLog(@"- publisher.name: %@", publisher.name);
}

-(void)publisherDidStopStreaming:(OTPublisher*)publisher
{
    NSLog(@"publisherDidStopStreaming:%@", publisher);
}

@end
