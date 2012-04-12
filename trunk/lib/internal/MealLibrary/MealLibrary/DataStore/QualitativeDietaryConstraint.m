//
//  QualitativeDietaryConstraint.m
//  MealLibrary
//
//  Created by sebbecai on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QualitativeDietaryConstraint.h"

@implementation QualitativeDietaryConstraint
@synthesize enabled = _enabled;
@synthesize selectorName;

-(NSNumber *)expectedValue
{
    return [NSNumber numberWithBool:_enabled];
}

#pragma mark Create/Destroy
- (id)initWithSelectorName:(NSString *) selName andEnabledState:(BOOL)enabled
{
    self = [super init];
    if (self) {
        selectorName = selName;
        [selectorName retain];
        _enabled = enabled;
    }
    
    return self;
}

-(void) dealloc
{
    [selectorName release];
    [super dealloc];
}

+(id<QualitativeDietaryConstraint>) createVegan
{
    QualitativeDietaryConstraint *constraint = [[QualitativeDietaryConstraint alloc] initWithSelectorName:@"isVegan" andEnabledState:YES];
    [constraint autorelease];
    return constraint; 
}

+(id<QualitativeDietaryConstraint>) createVegetarian
{
    QualitativeDietaryConstraint *constraint = [[QualitativeDietaryConstraint alloc] initWithSelectorName:@"isVegetarian" andEnabledState:YES];
    [constraint autorelease];
    return constraint;  
}
@end
