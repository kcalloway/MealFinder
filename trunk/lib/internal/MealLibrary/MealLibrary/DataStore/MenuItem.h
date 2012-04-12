//
//  MenuItem.h
//  MealLibrary
//
//  Created by sebbecai on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataStoreSeed.h"

@protocol MenuItem <NSObject>
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * kcal;
@property (nonatomic, retain) NSString * restaurantId;
@property (nonatomic, retain) NSNumber * isMeal;
@property (nonatomic, retain) NSNumber * isVegetarian;
@property (nonatomic, retain) NSNumber * isVegan;
@property (nonatomic, retain) NSNumber * cholesterol;
@property (nonatomic, retain) NSNumber * sodium;
@property (nonatomic, retain) NSNumber * carbs;
@end

@interface MenuItem : NSManagedObject <MenuItem, DataStoreSeed> {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * kcal;
@property (nonatomic, retain) NSString * restaurantId;
@property (nonatomic, retain) NSNumber * isMeal;
@property (nonatomic, retain) NSNumber * isVegetarian;
@property (nonatomic, retain) NSNumber * isVegan;
@property (nonatomic, retain) NSNumber * cholesterol;
@property (nonatomic, retain) NSNumber * sodium;
@property (nonatomic, retain) NSNumber * carbs;
@end
