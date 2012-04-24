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

#pragma mark DietaryConstraint
-(BOOL)allowsMeal:(id<Meal>)meal
{
    NSNumber *curValue = [meal performSelector:_selector];
    return (_enabled) ? [curValue boolValue] : YES;
}

#pragma mark Create/Destroy
- (id)initWithSelectorName:(NSString *) selName andSelector:(SEL)sel andEnabledState:(BOOL)enabled
{
    self = [super init];
    if (self) {
        _selector    = sel;
        _enabled     = enabled;

        selectorName = selName;
        [selectorName retain];
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
    QualitativeDietaryConstraint *constraint = [[QualitativeDietaryConstraint alloc] initWithSelectorName:@"isVegan" andSelector:@selector(isVegan) andEnabledState:YES];
    [constraint autorelease];
    return constraint; 
}

+(id<QualitativeDietaryConstraint>) createVegetarian
{
    QualitativeDietaryConstraint *constraint = [[QualitativeDietaryConstraint alloc] initWithSelectorName:@"isVegetarian" andSelector:@selector(isVegetarian) andEnabledState:YES];
    [constraint autorelease];
    return constraint;  
}
@end
