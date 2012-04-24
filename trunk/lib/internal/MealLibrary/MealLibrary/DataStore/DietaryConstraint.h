//
//  DietaryConstraint.h
//  MealLibrary
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meal.h"

@protocol DietaryConstraint <NSObject>
@property (retain,readonly) NSString *selectorName;
-(BOOL)allowsMeal:(id<Meal>)meal;
@end

@protocol QualitativeDietaryConstraint <NSObject, DietaryConstraint> 
-(NSNumber *)expectedValue;
@property BOOL enabled;
@end

@protocol QuantitativeDietaryConstraint <NSObject, DietaryConstraint> 
@property int maxValue;
@end

@interface DietaryConstraint : NSObject <QuantitativeDietaryConstraint> {
    int       maxValue;
    int       minValue;
    SEL       _selector;
    NSString *selectorName;
}

@property (retain,readonly) NSString *selectorName;
@property int maxValue;

+(id<QuantitativeDietaryConstraint>) createCaloricWithMax:(int)maxCalories;
+(id<QuantitativeDietaryConstraint>) createCarbohydrateWithMax:(int)maxCarbs;
+(id<QuantitativeDietaryConstraint>) createSodiumWithMax:(int)maxSodium;
+(id<QuantitativeDietaryConstraint>) createCholesterolWithMax:(int)maxChol;

+(id<QualitativeDietaryConstraint>) createVegan;
+(id<QualitativeDietaryConstraint>) createVegetarian;

+(NSMutableArray *)quantitativeNames;
+(NSMutableDictionary *)namesToConstraints;
@end
