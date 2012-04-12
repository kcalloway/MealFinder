//
//  RestaurantTableviewControllerViewController.h
//  MealFinder
//
//  Created by sebbecai on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealRestaurantLayer.h"

@interface RestaurantTableViewController : UITableViewController {
    id<MealRestaurantLayer> _restaurantLayer;
    NSString                *_uniqueId;
    NSArray                 *_cellInfos;
}
+(UITableViewController *)createWithRestaurantLayer:(id<MealRestaurantLayer>)restaurantLayer
                                        andUniqueId:(NSString *)uniqueId;

@end

