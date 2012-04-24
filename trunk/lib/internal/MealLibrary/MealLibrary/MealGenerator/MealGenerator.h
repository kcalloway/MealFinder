//
//  MealGenerator.h
//  MealGenerator
//
//  Created by sebbecai on 3/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataStore.h"
#import "BatchTask.h"

#pragma mark Protocol
@protocol MealGeneratorDelegate <NSObject>
-(void)processResultMeals:(NSArray*) meals forLocationId:(NSString *)locationId;
@end

@protocol MealGenerator <NSObject>
-(void) findMealsForRestaurants:(NSArray *) restaurants andDiet:(NSArray *) diet;
-(void) findMealsForRestaurants:(NSArray *)restaurants
                        andDiet:(NSArray *)diet
                startingAtIndex:(int)firstMeal
                  endingAtIndex:(int)lastMeal;
-(void)cancelAllActiveTasks;
@property (assign) id<MealGeneratorDelegate> taskDelegate;
@end

#pragma mark Class
@interface MealGenerator : NSObject <MealGenerator> {
    id<FoodDataStore> _dataStore;
}

#pragma mark Factory Methods
+(id <MealGenerator>) create;
- (id)initWithDataStore:(id<FoodDataStore>)dataStore;
@end