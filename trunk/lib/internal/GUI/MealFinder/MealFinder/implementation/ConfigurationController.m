//
//  ConfigurationController.m
//  DraggableControllerTest
//
//  Created by sebbecai on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigurationController.h"
#import "DietaryConstraint.h"

#define ANIMATION_DURATION  .35

@interface ConfigurationController ()

@end

@implementation ConfigurationController
@synthesize firstSegment;
@synthesize firstSlider;
@synthesize draggingAnchor;
@synthesize veganSwitch;
@synthesize vegetarianSwitch;
@synthesize sliderTitle;

-(void)beginSearchForDiet
{
    [_mealDelegate cancelDietSearch];
    [_mealDelegate findMealsForDiet:[_dietaryConstraints allValues]];
}

-(void)updateSliderToValue:(int)sliderValue
{
    firstSlider.minimumValue = 0;
    firstSlider.maximumValue = 1000;
    [firstSlider setValue:sliderValue animated:YES];
}

-(void)updateSegmentToValue:(int)newValue
{
    [firstSegment setTitle:[NSString stringWithFormat:@"%d",newValue] 
         forSegmentAtIndex:[firstSegment selectedSegmentIndex]];
}

- (IBAction)updateSegmentForSender:(id)sender
{
    NSString *segmentStr = [firstSegment titleForSegmentAtIndex:[firstSegment selectedSegmentIndex]];

    [self updateSliderToValue:[segmentStr intValue]];
    sliderTitle.text = [_quantitativeConstraintKeys objectAtIndex:[firstSegment selectedSegmentIndex]];
}

- (IBAction)updateSliderForSender:(id)sender
{
    [self updateSegmentToValue:[firstSlider value]];
    
    NSString *key = [_quantitativeConstraintKeys objectAtIndex:[firstSegment selectedSegmentIndex]];
    ((id<QuantitativeDietaryConstraint>)[_dietaryConstraints objectForKey:key]).maxValue = [firstSlider value];
    [self beginSearchForDiet];
}

- (IBAction)switchWasModified:(id)sender
{
    id<QualitativeDietaryConstraint> constraint;
    constraint = [_dietaryConstraints objectForKey:@"Vegan"];
    constraint.enabled = [veganSwitch isOn];
    
    constraint = [_dietaryConstraints objectForKey:@"Vegetarian"];
    constraint.enabled = [vegetarianSwitch isOn];
    [self beginSearchForDiet];
}

-(void)updateTitles
{
    for (int i = 0; i < [_quantitativeConstraintKeys count]; i++) {
        NSString *key = [_quantitativeConstraintKeys objectAtIndex:i];
        NSString *title = [NSString stringWithFormat:@"%d",((id<QuantitativeDietaryConstraint>)[_dietaryConstraints objectForKey:key]).maxValue];
        [firstSegment setTitle:title forSegmentAtIndex:i];
    }
    
    id<QualitativeDietaryConstraint> constraint;
    constraint = [_dietaryConstraints objectForKey:@"Vegan"];
    [veganSwitch setOn:constraint.enabled];

    constraint = [_dietaryConstraints objectForKey:@"Vegetarian"];
    [vegetarianSwitch setOn:constraint.enabled];

    [self updateSegmentForSender:nil];
}

#pragma mark DraggableController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad { 
    [super viewDidLoad];

    _dragDelegate.draggingAnchor = draggingAnchor;
    [_dragDelegate viewDidLoad];
    
    [self updateTitles];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Create\Destroy
-(void)dealloc
{
    [_dragDelegate       release];
    [_dietaryConstraints release];
    [_quantitativeConstraintKeys     release];
    [_mealDelegate       release];

    [super dealloc];
}

-(id)initWithNibName:(NSString *)nibNameOrNil 
           andBundle:(NSBundle *)curBundle 
     andDragDelegate:(id<DraggableControllerDelegate>)dragDelegate
      andConstraints:(NSMutableDictionary *)constraints 
   andConstraintKeys:(NSMutableArray *)constraintKeys 
     andMealDelegate:(id<MealRestaurantLayer>)mealDelegate
{
    self = [super initWithNibName:nibNameOrNil bundle:curBundle];
    if (self) {
        _dragDelegate       = dragDelegate;
        _dietaryConstraints = constraints;
        _quantitativeConstraintKeys     = constraintKeys;
        _mealDelegate       = mealDelegate;
        [_dragDelegate       retain];
        [_dietaryConstraints retain];
        [_quantitativeConstraintKeys     retain];
        [_mealDelegate       retain];
    }
    return self;
}

+(ConfigurationController *)createWithMealDelegate:(id<MealRestaurantLayer>)mealDelegate
{
    NSString *nibNameOrNil = @"AdvancedConfigView";
    NSBundle *curBundle = [NSBundle mainBundle];
    
    NSMutableDictionary *dietaryConstraints = [DietaryConstraint namesToConstraints];
    NSMutableArray *constraintKeys = [DietaryConstraint quantitativeNames];
    id<DraggableControllerDelegate> dragDelegate = [DraggableControllerDelegate createWithController:nil andWithAnchor:nil];
    ConfigurationController *configController = [[ConfigurationController alloc] initWithNibName:nibNameOrNil andBundle:curBundle andDragDelegate:dragDelegate andConstraints:dietaryConstraints andConstraintKeys:constraintKeys andMealDelegate:mealDelegate];
    dragDelegate.parentCont = configController;
    [configController autorelease];
    return configController;
}

@end
