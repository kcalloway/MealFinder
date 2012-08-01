//
//  MainViewController.m
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "AnnotationInfo.h"
#import "ConfigurationController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize findMyLocationButton;
@synthesize refreshMealsButton;
@synthesize mealDelegate;
@synthesize flipsidePopoverController = _flipsidePopoverController;

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [mapDelegate applicationDidBecomeActive:application];
    applicationJustBecameActive = YES;
}

#pragma mark ViewController Stuff  
-(void)presentDetailController:(UIViewController *)detailCont
{
    [self.navigationController pushViewController:detailCont animated:YES];
}

-(void)setCanUpdateLocation:(BOOL)canUpdate
{
    findMyLocationButton.enabled = canUpdate;
}

-(void)setCanUpdateAnnotations:(BOOL)canUpdate
{
    refreshMealsButton.enabled   = canUpdate;
}

-(void)shouldUpdateMapView:(BOOL)shouldUpdate
{
    if (applicationJustBecameActive) {
        [self findMyLocation:nil];
        [self refreshMeals:nil];
        applicationJustBecameActive = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapDelegate = [MapViewManager createForView:self.view 
                                andRecieverCont:self
                                andMealDelegate:mealDelegate];
    [mapDelegate retain];
    
    [self.view insertSubview:mapDelegate.view atIndex:0];
    [self.navigationController  setNavigationBarHidden:YES animated:NO];  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    mapDelegate = nil;
    [mapDelegate release];
}
- (void)viewDidAppear:(BOOL)animated {  
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {  
    [super viewWillAppear:animated];
    [self.navigationController  setNavigationBarHidden:YES animated:YES];
}

- (IBAction)findMyLocation:(id)sender
{
    [mapDelegate setLocation:[mapDelegate myLocation]];
}

- (IBAction)refreshMeals:(id)sender
{
    [mapDelegate refreshAnnotations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)dealloc
{
    [_flipsidePopoverController release];
    [mealDelegate release];
    [mapDelegate release];

    [super dealloc];
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FlipsideViewController *controller = [[[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil] autorelease];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        if (!self.flipsidePopoverController) {
            FlipsideViewController *controller = [[[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil] autorelease];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[[UIPopoverController alloc] initWithContentViewController:controller] autorelease];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

+(UIViewController *)createForIPhoneWithMealDelegate:(id<MealRestaurantLayer>)mDelegate
{
    MainViewController *mainCont = [[[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil] autorelease];
    mainCont.mealDelegate = mDelegate;
    UINavigationController *navCont = [[[UINavigationController alloc] initWithRootViewController:mainCont] autorelease];

    return navCont;
}

+(MainViewController *)createForIPadWithMealDelegate:(id<MealRestaurantLayer>)mDelegate
{    
    MainViewController *mainCont = [[[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil] autorelease];
    mainCont.mealDelegate = mDelegate;

    return mainCont;
}
@end
