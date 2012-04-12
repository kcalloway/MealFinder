//
//  BatchProcessTests.h
//  RestaurantFinder
//
//  Created by sebbecai on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BatchTask.h"

@interface BatchProcessTests : SenTestCase {
    id<BatchTask>      testBatchProcess;
    NSNotificationCenter *myNotCenter;
    NSString             *notificationData;
}
@end
