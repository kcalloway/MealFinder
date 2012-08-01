//
//  MainViewController.h
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MapViewManager.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, DetailReceiverDelegate, MapButtonDelegate> {
    MapViewManager *mapDelegate;
    id<MealRestaurantLayer>  mealDelegate;
    BOOL applicationJustBecameActive;

}
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (retain) id<MealRestaurantLayer>  mealDelegate;
@property (retain) IBOutlet UIBarButtonItem *findMyLocationButton;
@property (retain) IBOutlet UIBarButtonItem *refreshMealsButton;

- (void)applicationDidBecomeActive:(UIApplication *)application;

-(void)presentDetailController:(UIViewController *)detailCont;
- (IBAction)showInfo:(id)sender;
- (IBAction)findMyLocation:(id)sender;
- (IBAction)refreshMeals:(id)sender;
+(MainViewController *)createForIPhoneWithMealDelegate:(id<MealRestaurantLayer>)mDelegate;
+(MainViewController *)createForIPadWithMealDelegate:(id<MealRestaurantLayer>)mDelegate;
@end
