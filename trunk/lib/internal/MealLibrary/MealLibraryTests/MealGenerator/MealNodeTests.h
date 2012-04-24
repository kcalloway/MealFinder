//
//  MealNodeTests.h
//  MealLibrary
//
//  Created by sebbecai on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MealNode.h"
#import "DataStore.h"

@interface MealNodeTests : SenTestCase {
    MealNode *testMealNode;
    
    id<DataStore> dataStore;
    NSArray       *menuItems;
    id<Diet>      diet;
}
@end
