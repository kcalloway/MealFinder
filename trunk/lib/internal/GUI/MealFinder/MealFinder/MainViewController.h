//
//  MainViewController.h
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MapViewManager.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, DetailReceiverDelegate> {
    MapViewManager *mapDelegate;
    id<MealRestaurantLayer>  mealDelegate;

}
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (retain) id<MealRestaurantLayer>  mealDelegate;

-(void)presentDetailController:(UIViewController *)detailCont;
- (IBAction)showInfo:(id)sender;
+(UIViewController *)createForIPhoneWithMealDelegate:(id<MealRestaurantLayer>)mDelegate;
+(MainViewController *)createForIPadWithMealDelegate:(id<MealRestaurantLayer>)mDelegate;
@end
