//
//  StoreAnnotation.h
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AnnotationInfo.h"
#import "Meal.h"

@protocol StoreAnnotation <NSObject, MKAnnotation, AnnotationInfo>
-(NSString *)getUniqueId;
@end

@interface StoreAnnotation : NSObject <StoreAnnotation> {
    id<AnnotationInfo> notationInfo;
    id<Meal> _meal;
    CLLocation * _location;
}

+(id<MKAnnotation, AnnotationInfo>)createWithLocation:(CLLocation *)location;
+(id<StoreAnnotation>)createWithMeal:(id<Meal>)inputMeal
                       andCoordinate:(CLLocation *)location;
@end
