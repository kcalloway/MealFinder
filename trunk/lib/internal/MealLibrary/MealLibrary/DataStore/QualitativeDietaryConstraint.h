//
//  QualitativeDietaryConstraint.h
//  MealLibrary
//
//  Created by sebbecai on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DietaryConstraint.h"

@interface QualitativeDietaryConstraint : NSObject<QualitativeDietaryConstraint> {
    SEL      _selector;
    NSString *selectorName;
    BOOL     _enabled;
}
@property (retain,readonly) NSString *selectorName;
@property BOOL enabled;
-(NSNumber *)expectedValue;

+(id<QualitativeDietaryConstraint>) createVegetarian;
+(id<QualitativeDietaryConstraint>) createVegan;

@end
