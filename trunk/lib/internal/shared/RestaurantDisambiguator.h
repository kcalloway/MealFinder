//
//  RestaurantDisambiguator.h
//  MealRestaurantLayer
//
//  Created by sebbecai on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RestaurantDisambiguator <NSObject>
-(NSMutableArray *)disambiguateForRestaurants:(NSArray *)toDisambiguate;
-(void)uniqueifyOriginalRestaurants:(NSMutableDictionary *)originals withInput:(NSArray *)input;
@end

@interface RestaurantDisambiguator : NSObject <RestaurantDisambiguator> {
    NSSet *_uniqueIds;
    NSDictionary *_aliases;
}

+(NSArray *)supportedRestaurants;
+(id<RestaurantDisambiguator>)create;
@end
