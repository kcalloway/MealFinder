//
//  Meal.m
//  MealLibrary
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Meal.h"

@implementation Meal
@synthesize origin;
@synthesize menuItems;

@dynamic kcal;
@dynamic restaurantId;
@dynamic isVegetarian;
@dynamic isVegan;

#pragma mark MenuItemProtocol

-(NSNumber *)kcal
{
    int kcal = 0;
    for (id<MenuItem> food in menuItems) {
        kcal += [food.kcal intValue];
    }
    return [NSNumber numberWithInt:kcal];
}

-(NSString *)restaurantId
{
    return origin.uniqueId;
}

-(NSNumber *)isVegetarian
{
    BOOL vegetarian = 0;
    for (id<MenuItem> food in menuItems) {
        vegetarian |= [food.isVegetarian boolValue];
    }
    return [NSNumber numberWithBool:vegetarian];

}
-(NSNumber *)isVegan
{
    BOOL vegan = 0;
    for (id<MenuItem> food in menuItems) {
        vegan |= [food.isVegan boolValue];
    }
    return [NSNumber numberWithBool:vegan];    
}

#pragma mark Create/Destroy
-(id)initWithRestaurant:(id<Restaurant>)restaurant
           andMenuItems:(NSArray *)foodItems
{
    self = [super init];
    if (self) {
        origin    = restaurant;
        menuItems = foodItems;

        [origin    retain];
        [menuItems retain];
    }
    return self;
}

-(void) dealloc
{
    [origin    release];
    [menuItems release];
    
    [super dealloc];
}

+(id<Meal>)createWithRestaurant:(id<Restaurant>)restaurant
                   andMenuItems:(NSArray *)foodItems
{
    Meal *meal = [[Meal alloc] initWithRestaurant:restaurant andMenuItems:foodItems];
    [meal autorelease];
    return meal;
}
@end
