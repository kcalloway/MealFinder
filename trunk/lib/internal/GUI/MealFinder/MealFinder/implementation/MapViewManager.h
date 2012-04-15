//
//  MapViewManager.h
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MealRestaurantLayer.h"

@protocol DetailReceiverDelegate <NSObject>
-(void)presentDetailController:(UIViewController *)detailCont;
@end

@interface MapViewManager : NSObject <CLLocationManagerDelegate, MKMapViewDelegate, MealDisplayDelegate> {
    MKMapView      *_mapView;
    NSMutableDictionary *_annotations;

    CLLocation     *_curAnnotationCenter;
    
    CLLocationManager       *locationManager;
    id<MealRestaurantLayer>  mealDelegate;
    
    id<DetailReceiverDelegate> receiverDelegate;
    BOOL shouldUpdateToCurLocation;
}
@property (readonly) UIView *view;
@property (assign) id<DetailReceiverDelegate> receiverDelegate;
@property BOOL shouldUpdateToCurLocation;

-(void)configureMap;
-(MKMapView *) loadMapOnView:(UIView *)view;
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
-(MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation;

+(MapViewManager *)createForView:(UIView *)inputView 
                 andRecieverCont:(id<DetailReceiverDelegate>)receiverCont
                 andMealDelegate:(id<MealRestaurantLayer>)mealDelegate;
@end
