//
//  Meal.h
//  MealLibrary
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"
#import "Restaurant.h"

@protocol Meal <NSObject, NutritionData>
@property (readonly) id<Restaurant> origin;
@property (readonly) NSArray *menuItems;
@property (readonly) BOOL     isValidMeal;
@property (readonly) NSString *uniqueId;

@property (readonly) NSNumber * kcal;
@property (readonly) NSString * restaurantId;
@property (readonly) NSNumber * isVegetarian;
@property (readonly) NSNumber * isVegan;
@end

@interface Meal : NSObject <Meal> {
    id<Restaurant> origin;
    NSString       *_uniqueId;
    NSArray        *menuItems;
}

+(id<Meal>)createWithRestaurant:(id<Restaurant>)restaurant
                   andMenuItems:(NSArray *)foodItems;
@end
