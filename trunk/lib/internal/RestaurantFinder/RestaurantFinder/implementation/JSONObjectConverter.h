//
//  JSONObjectConverter.h
//  RestaurantFinder
//
//  Created by sebbecai on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONObjectConverter <NSObject>
-(NSArray *)objectsForData:(NSData *) data error:(NSError **) error;
@end

@interface JSONObjectConverter : NSObject <JSONObjectConverter>
+(id<JSONObjectConverter>)create;
@end
