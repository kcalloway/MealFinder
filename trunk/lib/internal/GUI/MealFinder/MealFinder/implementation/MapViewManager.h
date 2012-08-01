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

@protocol MapButtonDelegate <NSObject>
-(void)setCanUpdateLocation:(BOOL)canUpdate;
-(void)setCanUpdateAnnotations:(BOOL)canUpdate;
-(void)shouldUpdateMapView:(BOOL)shouldUpdate;
@end

@interface MapViewManager : NSObject <CLLocationManagerDelegate, MKMapViewDelegate, MealDisplayDelegate> {
    MKMapView      *_mapView;
    NSMutableDictionary *_annotations;

    CLLocation     *_curAnnotationCenter;
    float _prevSpanArea;
    
    CLLocationManager       *locationManager;
    id<MealRestaurantLayer>  mealDelegate;
    
    id<DetailReceiverDelegate, MapButtonDelegate> receiverDelegate;
    BOOL shouldUpdateToCurLocation;
}
@property (readonly) UIView *view;
@property (assign) id<DetailReceiverDelegate> receiverDelegate;
@property BOOL shouldUpdateToCurLocation;

-(MKMapView *) loadMapOnView:(UIView *)view;
-(void)locationManager:(CLLocationManager *)manager 
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation;
-(MKAnnotationView *)mapView:(MKMapView *)theMapView
           viewForAnnotation:(id <MKAnnotation>)annotation;
-(BOOL)prevLocationIsSignificantlyFarFromLoc:(CLLocation *)prevLocation;
-(CLLocation *)myLocation;
-(CLLocation *)centerLocation;
-(void)applicationDidBecomeActive:(UIApplication *)application;

-(void)setLocation:(CLLocation *)location;
-(void)refreshAnnotations;

+(MapViewManager *)createForView:(UIView *)inputView 
                 andRecieverCont:(id<DetailReceiverDelegate>)receiverCont
                 andMealDelegate:(id<MealRestaurantLayer>)mealDelegate;
@end
