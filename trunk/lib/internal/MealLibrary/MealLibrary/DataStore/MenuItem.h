//
//  MenuItem.h
//  MealLibrary
//
//  Created by sebbecai on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataStoreSeed.h"

@protocol NutritionData <NSObject>
@property (nonatomic, retain) NSNumber * kcal;
@property (nonatomic, retain) NSNumber * isVegetarian;
@property (nonatomic, retain) NSNumber * isVegan;
@property (nonatomic, retain) NSNumber * cholesterol;
@property (nonatomic, retain) NSNumber * sodium;
@property (nonatomic, retain) NSNumber * carbs;

@end

@protocol MenuItem <NSObject, NutritionData>
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * restaurantId;
@property (nonatomic, retain) NSNumber * isMeal;
@property (nonatomic, retain) NSNumber * isEntree;
@property (nonatomic, retain) NSNumber * isSide;
@property (nonatomic, retain) NSNumber * isDessert;
@property (nonatomic, retain) NSNumber * isBreakfast;
@property (readonly) NSString * uniqueId;

// BEWARE:This is a 16-byte bitMask.  Any menu with more than 16 condiments
//        will require changing this
@property (nonatomic, retain) NSNumber * potentialCondiments;
@property (nonatomic, retain) NSNumber * condimentCategories;
@end

@interface MenuItem : NSManagedObject <MenuItem, DataStoreSeed> {
@private
    uint16_t potentialCondimentsMask;
    uint16_t condimentCategoriesMask;
}
@end
