//
//  MealCellInfo.h
//  MealFinder
//
//  Created by sebbecai on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Meal.h"

@protocol MealCellInfo <NSObject>
-(NSString *)title;
-(NSString *)subtitle;
@end

@interface MealCellInfo : NSObject <MealCellInfo> {
    id<Meal> _meal;
}

+(id<MealCellInfo>)createWithMeal:(id<Meal>)meal;
@end
