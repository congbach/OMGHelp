//
//  HomeViewController.m
//  omgHelp
//
//  Created by Cong Bach on 11/8/12.
//  Copyright (c) 2012 VSee Lab, Inc. All rights reserved.
//

#import "HomeViewController.h"
#import "NetworkManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "CategoriesViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize activityIndicator = _activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    [[NetworkManager sharedNetworkManager] requestCategoriesWithCallBackTarget:self selector:@selector(displayCategoriesFromJSON:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)displayCategoriesFromJSON:(id)JSON
{
    [self.activityIndicator stopAnimating];
    CategoriesViewController *categoriesViewController = [[[CategoriesViewController alloc] initWithJSONCategoriesArray:[JSON valueForKeyPath:@"MenuCategories"]] autorelease];
    categoriesViewController.title = @"omgHelp";
    categoriesViewController.navigationItem.hidesBackButton = YES;
    [[[AppDelegate sharedAppDelegate] navigationController] pushViewController:categoriesViewController animated:NO];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
