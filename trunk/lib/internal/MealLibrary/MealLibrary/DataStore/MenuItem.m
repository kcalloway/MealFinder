//
//  MenuItem.m
//  MealLibrary
//
//  Created by sebbecai on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem
@dynamic name;
@dynamic kcal;
@dynamic restaurantId;
@dynamic isMeal;
@dynamic isVegan;
@dynamic isVegetarian;
@dynamic cholesterol;
@dynamic sodium;
@dynamic carbs;

-(void) setValuesForArr:(NSArray *) stringArr
{
    [self setRestaurantId:[stringArr objectAtIndex:0]];
    [self setName:[stringArr objectAtIndex:1]];
    NSString *roles = [stringArr objectAtIndex:2];
    if ([roles isEqualToString:@"meal"]) {
        [self setIsMeal:[NSNumber numberWithBool:YES]];
    }

    [self setKcal:[NSNumber numberWithInt:[[stringArr objectAtIndex:3] intValue]]];
    [self setCholesterol:[NSNumber numberWithInt:[[stringArr objectAtIndex:4] intValue]]];
    [self setSodium:[NSNumber numberWithInt:[[stringArr objectAtIndex:5] intValue]]];
    [self setCarbs:[NSNumber numberWithInt:[[stringArr objectAtIndex:6] intValue]]];
    [self setIsVegetarian:[NSNumber numberWithInt:[[stringArr objectAtIndex:7] boolValue]]];
    [self setIsVegan:[NSNumber numberWithInt:[[stringArr objectAtIndex:8] boolValue]]];


}

@end