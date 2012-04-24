//
//  Diet.m
//  MealLibrary
//
//  Created by sebbecai on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Diet.h"
#import "DietaryConstraint.h"

@implementation Diet
@synthesize dietaryConstraints;

-(BOOL)allowsMeal:(id<Meal>)meal
{
    for (id<DietaryConstraint> constraint in dietaryConstraints) {
        if (![constraint allowsMeal:meal]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark Create/Destroy
-(id<Diet>)initWithContraints:(NSMutableArray*)constraints
{
    self = [super init];
    if (self) {
        dietaryConstraints = constraints;
        [dietaryConstraints retain];
    }
    return self;
}

-(void)dealloc
{
    [dietaryConstraints release];
    [super dealloc];
}

+(id<Diet>)createWithConstraints:(NSMutableArray*)constraints
{
    Diet *diet = [[Diet alloc] initWithContraints:constraints];
    [diet autorelease];
    return diet;
}
@end
