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

@dynamic restaurantId;
@dynamic isVegetarian;
@dynamic isVegan;

@dynamic kcal;
@dynamic cholesterol;
@dynamic sodium;
@dynamic carbs;

@dynamic isValidMeal;
@dynamic uniqueId;

@dynamic potentialCondiments;

-(NSNumber *)potentialCondiments
{
    int potentialCondiments = 0;
    for (id<MenuItem> menuItem in menuItems) {
        potentialCondiments |= [menuItem.potentialCondiments intValue];
        potentialCondiments &= ~[menuItem.condimentCategories intValue];
    }
    return [NSNumber numberWithInt:potentialCondiments];
}

-(NSString *)uniqueId
{
    return _uniqueId;
}

-(BOOL)isValidMeal
{
    BOOL hasMeal   = NO;
    BOOL hasEntree = NO;
    BOOL hasSide   = NO;

    for (id<MenuItem> menuItem in menuItems) {
        if (menuItem.isMeal) {
            hasMeal = YES;
        }
        hasEntree |= [menuItem.isEntree boolValue];
        hasSide   |= [menuItem.isSide   boolValue];
    }

    // Since some MenuItems are both sides and entrees, we need to make sure
    // That if we have only one of them we recognize that it isn't a valid meal
    return hasMeal || (hasEntree && hasSide && [menuItems count] > 1);
}

#pragma mark MenuItemProtocol
-(NSNumber *)quantValueForSelector:(SEL)selector
{
    int quantValue = 0;
    for (id<MenuItem> food in menuItems) {
        quantValue += [[food performSelector:selector] intValue];
    }
    return [NSNumber numberWithInt:quantValue];
}
-(NSNumber *)cholesterol
{
    return [self quantValueForSelector:@selector(cholesterol)];
}
-(NSNumber *)sodium
{
    return [self quantValueForSelector:@selector(sodium)];
}
-(NSNumber *)carbs
{
    return [self quantValueForSelector:@selector(carbs)];
}

-(NSNumber *)kcal
{
    return [self quantValueForSelector:@selector(kcal)];
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
            andUniqueId:(NSString *)uniqueId
{
    self = [super init];
    if (self) {
        origin    = restaurant;
        menuItems = foodItems;
        _uniqueId = uniqueId;

        [origin    retain];
        [menuItems retain];
        [_uniqueId  retain];
    }
    return self;
}

-(void) dealloc
{
    [origin    release];
    [menuItems release];
    [_uniqueId release];
    
    [super dealloc];
}

+(NSString *) uniqueIdForMenuItems:(NSArray *)menuItems
{
    NSMutableArray *sortedItems = [NSMutableArray arrayWithArray:menuItems];
    [sortedItems sortUsingSelector:@selector(compare:)];
    NSString *uniqueId = @"";
    for (id<MenuItem> food in sortedItems) {
        uniqueId =  [uniqueId stringByAppendingString:food.uniqueId];
    }
    return uniqueId;
}

+(id<Meal>)createWithRestaurant:(id<Restaurant>)restaurant
                   andMenuItems:(NSArray *)foodItems
{
    NSString *uniqueId = [Meal uniqueIdForMenuItems:foodItems];
    Meal *meal = [[Meal alloc] initWithRestaurant:restaurant andMenuItems:foodItems andUniqueId:uniqueId];
    [meal autorelease];
    return meal;
}
@end
