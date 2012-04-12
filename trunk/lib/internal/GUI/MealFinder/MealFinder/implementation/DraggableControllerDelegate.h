//
//  DraggableControllerDelegate.h
//  MealFinder
//
//  Created by sebbecai on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DraggableControllerDelegate <NSObject>
@property(assign) UIView *draggingAnchor;
@property(assign) UIViewController *parentCont;
- (void)viewDidLoad;
@end


@interface DraggableControllerDelegate : NSObject <DraggableControllerDelegate,UIGestureRecognizerDelegate> {
    BOOL    _isXLocked;
    BOOL    _isYLocked;
    float   _xMin;
    float   _xMax;
    float   _yMin;
    float   _yMax;
    float   _xStart;
    float   _yStart;
    
    UIViewController *parentCont;
}
@property(assign) UIView *draggingAnchor;
@property(assign) UIViewController *parentCont;

+(id<DraggableControllerDelegate>) createWithController:(UIViewController *)controller andWithAnchor:(UIView *)anchor;
@end
