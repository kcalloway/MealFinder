//
//  MealRestaurantLayerTests.h
//  MealRestaurantLayerTests
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MealRestaurantLayer.h"

@interface MealRestaurantLayerTests : SenTestCase{
    MealRestaurantLayer *testRestLayer;
    NSArray  *locationIds;
    NSSet    *addedMeals;
    NSSet    *removedMeals;
    NSString *curLocationId;
}
    
@end
