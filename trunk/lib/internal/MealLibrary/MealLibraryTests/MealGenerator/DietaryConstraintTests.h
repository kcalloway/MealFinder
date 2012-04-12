//
//  DietaryConstraintTests.h
//  MealLibrary
//
//  Created by sebbecai on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MealGenerator.h"

@interface DietaryConstraintTests : SenTestCase<MealGeneratorDelegate> {
    MealGenerator  *testGenerator;
    NSMutableArray *resultMeals;
    NSArray        *restaurants;
}
@end

