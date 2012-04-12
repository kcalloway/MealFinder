//
//  RestaurantDisambiguatorTests.h
//  MealRestaurantLayer
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RestaurantDisambiguator.h"

@interface RestaurantDisambiguatorTests : SenTestCase {
    id<RestaurantDisambiguator> testDisambiguator;
    NSMutableArray *inputRestaurants;
    NSMutableDictionary *originalRestaurants;
}

@end
