//
//  DraggableControllerDelegate.m
//  MealFinder
//
//  Created by sebbecai on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DraggableControllerDelegate.h"
#define ANIMATION_DURATION  .35
#define NUM_TOUCHES         1

@implementation DraggableControllerDelegate
@synthesize parentCont;
@synthesize draggingAnchor;

-(void)setupAsConfig
{
    _yMin   = 0;
    _yMax   = 432;
    _xMin   = 0;
    _xMax   = 0;
    _xStart = 0;
    _yStart = 432;
    
    float delta = 20;
    _yMax   += delta;
    _yMin   += delta;
    _yStart += delta;
    
    _isXLocked = YES;
    _isYLocked = NO;
}

-(void)setStartLocation
{        
    CGRect  frame  = [parentCont.view frame];
    frame.origin.x = _xStart;
    frame.origin.y = _yStart;
    [parentCont.view setFrame:frame];
}

-(void)dragToLocationForXPos:(float)xPos andYPos:(float)yPos andCurLocation:(CGPoint) location
{
    CGRect frame   = [parentCont.view frame];
    frame.origin.x = xPos;
    frame.origin.y = yPos;
    
    [UIView beginAnimations:@"DragOverlayView" context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [parentCont.view setFrame:frame];
    [UIView commitAnimations]; 
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    CGPoint offset;
    offset = [gesture locationInView:parentCont.view.superview];
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint location = [gesture locationInView:parentCont.view.superview];
        float xPos = _xStart, yPos = _yStart;
        if (!_isXLocked) {
            xPos = location.y;
            if (xPos > _xMax) {
                xPos = _xMax;
            }
            else if (xPos < _xMin) {
                xPos = _xMin;
            }        
        }
        
        if (!_isYLocked) {
            yPos = location.y;
            if (yPos > _yMax) {
                yPos = _yMax;
            }
            else if (yPos < _yMin) {
                yPos = _yMin;
            }
        }
        
        [self dragToLocationForXPos:xPos andYPos:yPos andCurLocation:location];
    }   
}

- (void)viewDidLoad {     
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    [panRecognizer setMinimumNumberOfTouches:NUM_TOUCHES];
	[panRecognizer setMaximumNumberOfTouches:NUM_TOUCHES];
	[panRecognizer setDelegate:self];
	[draggingAnchor addGestureRecognizer:panRecognizer];
    [self setupAsConfig];
    [self setStartLocation];
}

#pragma mark Create/Destroy
-(id)initWithController:(UIViewController *)controller andWithAnchor:(UIView *)anchor
{
    self = [super init];
    
    if (self) {
        parentCont     = controller;
        draggingAnchor = anchor;
        
        _yMin   = 0;
        _yMax   = 432;
        _xMin   = 0;
        _xMax   = 0;
        _xStart = 0;
        _yStart = 432;
        
        float delta = 20;
        _yMax   += delta;
        _yMin   += delta;
        _yStart += delta;
        
        _isXLocked = YES;
        _isYLocked = NO;
    }
    
    return self;
}

+(id<DraggableControllerDelegate>) createWithController:(UIViewController *)controller andWithAnchor:(UIView *)anchor
{
    DraggableControllerDelegate *delegate = [DraggableControllerDelegate alloc];
    
    [delegate autorelease];
    return delegate;
}

@end
