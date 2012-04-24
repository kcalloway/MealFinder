//
//  Diet.h
//  MealLibrary
//
//  Created by sebbecai on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meal.h"

@protocol Diet <NSObject>
@property (readonly) NSArray *dietaryConstraints;
-(BOOL)allowsMeal:(id<Meal>)meal;
@end

@interface Diet : NSObject <Diet> {
    NSMutableArray *dietaryConstraints;
}
+(id<Diet>)createWithConstraints:(NSMutableArray*)constraints;
@end
