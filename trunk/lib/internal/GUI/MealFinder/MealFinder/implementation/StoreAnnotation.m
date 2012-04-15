//
//  StoreAnnotation.m
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define ANIMATION_DUR .25

#import "StoreAnnotation.h"

@implementation StoreAnnotation
@dynamic title;
@dynamic subtitle;
@dynamic identifier;
@dynamic latitude;
@dynamic longitude;

@synthesize viewDelegate;

-(NSString *)getUniqueId
{
    return [_meal restaurantId];
}

#pragma mark AnnotationInfo
-(void)removeWithAnimationCompleteBlock:(AnimationCompleteBlock)completionBlock
{
    [UIView animateWithDuration:ANIMATION_DUR
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{[viewDelegate setAlpha:0.0f];}
                     completion:completionBlock];
}

-(NSString *)getTitle
{
    if (!_meal) {
        return @"DefaultTitle";
    }
    return [_meal.origin name];
}

-(NSString *)getSubtitle
{
    return @"";
}

-(NSString *)getIdentifier
{
    return @"ShopAnnotationInfoIdentifier";
}

-(float)latitude
{
    return [self coordinate].latitude;
}

-(float)longitude
{
    return [self coordinate].longitude;
}

#pragma mark MKAnnotation
- (CLLocationCoordinate2D)coordinate {
    return _location.coordinate;
}

// Optional
- (NSString *)title {
    return [self getTitle];
}

// Optional
- (NSString *)subtitle {
    return [self getSubtitle ];
}

#pragma mark Create/Destroy
-(id)initWithMeal:(id<Meal>)inputMeal
    andCoordinate:(CLLocation *)location
{
    self = [super init];
    if (self) {
        _meal     = inputMeal;
        _location = location;
        
        [_meal     retain];
        [_location retain];
    }
    return self;
}


-(void)dealloc
{
    [_meal     release];
    [_location release];

    [super dealloc];
}

+(id<MKAnnotation, AnnotationInfo>)createWithLocation:(CLLocation *)location
{
    id<StoreAnnotation> annotation = [[StoreAnnotation alloc] initWithMeal:nil andCoordinate:location];
    [annotation autorelease];
    return annotation;    
}

+(id<StoreAnnotation>)createWithMeal:(id<Meal>)inputMeal
                       andCoordinate:(CLLocation *)location
{
    id<StoreAnnotation> annotation = [[StoreAnnotation alloc] initWithMeal:inputMeal andCoordinate:location];
    [annotation autorelease];
    return annotation;
}

@end
