//
//  Restaurant.h
//  MealGenerator
//
//  Created by sebbecai on 3/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#pragma mark Protocol
@protocol Restaurant <NSObject>
@property (retain) NSString *uniqueId;
@property (retain, readonly) NSString *name;
@property (retain, readwrite) NSMutableArray *franchises;
-(int)numLocations;
-(void)addLocation:(CLLocation *)location;
@end

#pragma mark Class
@interface Restaurant : NSObject <Restaurant> {
    NSString       *name;
    NSString       *uniqueId;
    NSMutableArray *_franchises;
}
@property (retain) NSString *uniqueId;
@property (retain, readonly) NSString *name;

-(int)numLocations;
#pragma mark Factory Methods
+(id <Restaurant>) createWithId:(NSString *)restaurantName;
+(id <Restaurant>) createWithId:(NSString *)myId
                        andName:(NSString *)restaurantName
                  andFranchises:(NSMutableArray *)franchises;
@end
