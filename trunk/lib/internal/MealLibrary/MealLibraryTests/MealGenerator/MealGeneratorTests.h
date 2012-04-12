//
//  MealGeneratorTests.h
//  MealGeneratorTests
//
//  Created by sebbecai on 3/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MealGenerator.h"

@interface MealGeneratorTests : SenTestCase<MealGeneratorDelegate> {
    MealGenerator  *testGenerator;
    NSMutableArray *resultMeals;
    NSArray        *restaurants;
}
@end
