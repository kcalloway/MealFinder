//
//  ConfigurationController.h
//  DraggableControllerTest
//
//  Created by sebbecai on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealRestaurantLayer.h"
#import "DraggableControllerDelegate.h"

@interface ConfigurationController : UIViewController <UIGestureRecognizerDelegate> {    
    id<DraggableControllerDelegate> _dragDelegate;
    
    id<MealRestaurantLayer>  _mealDelegate;
    NSMutableDictionary *_dietaryConstraints;
    NSMutableArray      *_quantitativeConstraintKeys;
}

@property(nonatomic, retain) IBOutlet UIView *draggingAnchor;
@property(nonatomic, retain) IBOutlet UISegmentedControl *firstSegment;
@property(nonatomic, retain) IBOutlet UISlider *firstSlider;
@property(nonatomic, retain) IBOutlet UISwitch *vegetarianSwitch;
@property(nonatomic, retain) IBOutlet UISwitch *veganSwitch;
@property(nonatomic, retain) IBOutlet UILabel  *sliderTitle;


- (IBAction)updateSegmentForSender:(id)sender;
- (IBAction)updateSliderForSender:(id)sender;
- (IBAction)switchWasModified:(id)sender;

+(ConfigurationController *)createWithMealDelegate:(id<MealRestaurantLayer>)mealDelegate;

@end
