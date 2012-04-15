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

typedef void (^AnimationCompleteBlock)(BOOL);

@protocol StoreAnnotation <NSObject, MKAnnotation, AnnotationInfo>
-(NSString *)getUniqueId;
-(void)removeWithAnimationCompleteBlock:(AnimationCompleteBlock)completionBlock;
@property (assign) UIView *viewDelegate;
@end

@interface StoreAnnotation : NSObject <StoreAnnotation> {
    id<AnnotationInfo> notationInfo;
    id<Meal> _meal;

    CLLocation * _location;
    UIView     *viewDelegate;
}
@property (assign) UIView *viewDelegate;
+(id<MKAnnotation, AnnotationInfo>)createWithLocation:(CLLocation *)location;
+(id<StoreAnnotation>)createWithMeal:(id<Meal>)inputMeal
                       andCoordinate:(CLLocation *)location;
@end
