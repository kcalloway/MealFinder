//
//  MealGenerator.m
//  MealGenerator
//
//  Created by sebbecai on 3/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MealGenerator.h"
#import "MenuItem.h"
#import "Meal.h"
#import "Diet.h"

@implementation MealGenerator
@synthesize taskDelegate;

-(void)cancelAllActiveTasks
{
    
}

-(void) checkPreconditions:(NSArray *)restaurants andDiet:(NSArray *)diet
{
    if (!restaurants || !diet) {
        [NSException raise:NSInvalidArgumentException 
                    format:@"Restaurants must be an array of Restaurants, and Diet is a required argument!"];
    }
}

-(void) findMealsForRestaurants:(NSArray *)restaurants
                        andDiet:(id<Diet>)diet
                startingAtIndex:(int)firstMeal
                  endingAtIndex:(int)lastMeal
{
//    [self checkPreconditions:restaurants andDiet:diet];
//    for (id<Restaurant> store in restaurants) {        
//        NSArray *menuItems = [_dataStore getAllMenuItemsForRestaurant:store andDiet:diet];
////        NSMutableArray *meals = [NSMutableArray array];
////        for (id<MenuItem> food in menuItems) {
////            if (food.isMeal) {
////                [meals addObject:[Meal createWithRestaurant:store andMenuItems:[NSArray arrayWithObject:food]]];
////            }
////        }
////        
////        [self.taskDelegate processResultMeals:meals forLocationId:store.uniqueId];
//    }
}

-(void) findMealsForRestaurants:(NSArray *)restaurants andDiet:(NSArray *)diet
{
    [self checkPreconditions:restaurants andDiet:diet];
    for (id<Restaurant> store in restaurants) {
        NSArray *menuItems = [_dataStore getAllMenuItemsForRestaurant:store andDiet:diet];
        NSMutableArray *meals = [NSMutableArray array];
        for (id<MenuItem> food in menuItems) {
            if (food.isMeal) {
                [meals addObject:[Meal createWithRestaurant:store andMenuItems:[NSArray arrayWithObject:food]]];
            }
        }

        [self.taskDelegate processResultMeals:meals forLocationId:store.uniqueId];
    }
}

#pragma mark Create/Destroy
- (id)initWithDataStore:(id<FoodDataStore>)dataStore
{
    self = [super init];
    if (self) {
        _dataStore = dataStore;
        [_dataStore retain];
    }
    
    return self;
}
-(void)dealloc
{
    [_dataStore release];
    [super dealloc];
}

+(id <MealGenerator>) create {
    id<FoodDataStore> foodDataStore = [DataStore create];
    MealGenerator *generator = [[MealGenerator alloc] initWithDataStore:foodDataStore];
    [generator autorelease];
    return generator;
}

@end
