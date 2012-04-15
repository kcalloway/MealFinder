//
//  MapViewManager.m
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewManager.h"
#import "AnnotationInfo.h"
#import "StoreAnnotation.h"
#import "RestaurantTableViewController.h"

#define METERS_PER_MILE 1600

@implementation MapViewManager
@synthesize receiverDelegate;
@synthesize view = _mapView;
@synthesize shouldUpdateToCurLocation;

#pragma mark AnnotationStuff
-(void)addAnnotationsForArray:(NSArray *)annotations
{
    NSString *locationId = @"";
    for (id<MKAnnotation, StoreAnnotation> marker in annotations) {
        if (![locationId isEqualToString:[marker getUniqueId]]) {
            locationId = [marker getUniqueId];
            [_annotations setObject:annotations forKey:locationId];
        }
        [_mapView addAnnotation:marker];
    }

}

-(void)makeFakeAnnotations
{
    NSMutableArray *arr = [NSMutableArray array];
    CLLocation *oLocation = [[CLLocation alloc] initWithLatitude:[_mapView centerCoordinate].latitude longitude:[_mapView centerCoordinate].longitude];
    [oLocation autorelease];
    [arr addObject:[StoreAnnotation createWithLocation:oLocation]];

    [self addAnnotationsForArray:arr];
}

-(void)clearAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    
//    //Get the current user location annotation.
//    id userAnnotation=mapView.userLocation;
//    
//    //Remove all added annotations
//    [mapView removeAnnotations:mapView.annotations]; 
//    
//    // Add the current user location annotation again.
//    if(userAnnotation!=nil)
//        [mapView addAnnotation:userAnnotation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSString *uniqueAnnotationId = [((id<StoreAnnotation>)view.annotation) getUniqueId];
    UIViewController *detailCont = [RestaurantTableViewController createWithRestaurantLayer:mealDelegate andUniqueId:uniqueAnnotationId];
    [receiverDelegate presentDetailController:detailCont];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation, StoreAnnotation>)annotation {    
    if (![annotation conformsToProtocol:@protocol(StoreAnnotation)])
        return nil;

    static NSString *ident = @"ShopAnnotationInfoIdentifier";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:ident];
    if (!pinView) {
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ident] autorelease];
        pinView.pinColor       = MKPinAnnotationColorRed;
        pinView.animatesDrop   = YES;
        pinView.canShowCallout = YES;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
    } else {
        pinView.annotation = annotation;
    }
    return pinView;
}

#pragma mark MealStuff
-(void)addNewRestaurantMeals:(NSArray *)meals
{
//    [self addAnnotationsForArray:meals];
}

-(void)locationAdded:(NSNotification *)caughtNotification
{
    NSArray *annotations = [[caughtNotification userInfo] objectForKey:[MealRestaurantLayer userInfoAnnotationKey]];
    NSLog(@"added = %@\n", annotations);

    [self addAnnotationsForArray:annotations];
}

-(void)locationChanged:(NSDictionary *)changed
{
}

-(void)locationRemoved:(NSNotification *)caughtNotification
{
    NSArray *locationIdArr = [[caughtNotification userInfo] objectForKey:[MealRestaurantLayer userInfoDataKey]];
    
    for (NSString *locationId in locationIdArr) {
        [_mapView removeAnnotations:[_annotations objectForKey:locationId]];
        [_annotations removeObjectForKey:locationId];
    }
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (shouldUpdateToCurLocation)
    {
        [self setUserRegion];
        shouldUpdateToCurLocation = NO;
    }
}

#pragma mark MKMapViewDelegateMapStuff
-(BOOL)shouldUpdateAnnotationsForLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationDistance locDistance = [newLocation distanceFromLocation:oldLocation];

    if (locDistance > 2500) {
        return YES;
    }
    return NO;
}

-(void)updateAnnotationCenter:(CLLocation *)newLocation
{
    if (!_curAnnotationCenter) {
        _curAnnotationCenter = [locationManager location];
        [_curAnnotationCenter retain];
    }

    if (_curAnnotationCenter && [self shouldUpdateAnnotationsForLocation:newLocation fromLocation:_curAnnotationCenter]) {
        [_curAnnotationCenter release];
        _curAnnotationCenter = newLocation;   
//        [self makeFakeAnnotations];
//        MKCoordinateRegion region = _mapView.region;

        [mealDelegate findMealsForLocation:newLocation.coordinate andMeters:2000];
        [_curAnnotationCenter retain];

    }
}

-(void)setUserRegion
{
    CLLocation *location = [locationManager location];
    [self updateAnnotationCenter:location];
    int metersDistance = 2*METERS_PER_MILE;

    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([location coordinate], metersDistance, metersDistance);

    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];                

    [_mapView setRegion:adjustedRegion animated:TRUE];
//    [self makeFakeAnnotations];

    [mealDelegate findMealsForLocation:_curAnnotationCenter.coordinate andMeters:metersDistance];
}

-(void)configureMap
{
    // Set the map type such as Standard, Satellite, Hybrid
	_mapView.mapType = MKMapTypeStandard;
    
    // Config user interactions
	_mapView.zoomEnabled = YES;
	_mapView.scrollEnabled = YES;

	_mapView.delegate = self;
    
//    [self setUserRegion];

    // Show the user's location
    _mapView.showsUserLocation = YES;
}

-(MKMapView *) loadMapOnView:(UIView *)view
{
    MKMapView *resultMap = [[MKMapView alloc] initWithFrame:view.bounds];
    [resultMap autorelease];
    
//    CLLocationManager *lManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    shouldUpdateToCurLocation = YES;
    
    return resultMap;
}

#pragma mark Create/Destroy
-(id)initWithMapView:(MKMapView *)mapView 
  andLocationManager:(CLLocationManager *)lManager 
andMealDelegate:(id<MealRestaurantLayer>)delegate 
      andAnnotations:(NSMutableDictionary *)annotations
{
    self = [super init];
    if (self) {
        _mapView        = mapView;
        locationManager = lManager;
        mealDelegate    = delegate;
        _annotations    = annotations;
        _curAnnotationCenter = nil;

        [_mapView        retain];
        [locationManager retain];
        [mealDelegate    retain];
        [_annotations    retain];
    }

    return self;
}

-(void)dealloc
{
    [locationManager release];
    [_mapView        release];
    [mealDelegate    release];
    [_annotations    release];
    [_curAnnotationCenter release];

    NSNotificationCenter *myNotCenter = [NSNotificationCenter defaultCenter];
    [myNotCenter removeObserver:self];
    
    [super dealloc];
}

-(void)registerForNotifications
{
    NSNotificationCenter *myNotCenter = [NSNotificationCenter defaultCenter];
    [myNotCenter addObserver:self 
                    selector:@selector(locationAdded:)
                        name:[MealRestaurantLayer LocationAddedNotification] 
                      object:nil];
    [myNotCenter addObserver:self 
                    selector:@selector(locationChanged:)
                        name:[MealRestaurantLayer LocationChangedNotification] 
                      object:nil];
    [myNotCenter addObserver:self 
                    selector:@selector(locationRemoved:)
                        name:[MealRestaurantLayer LocationRemovedNotification] 
                      object:nil];
}

+(MapViewManager *)createForView:(UIView *)inputView 
                 andRecieverCont:(id<DetailReceiverDelegate>)receiverCont
                 andMealDelegate:(id<MealRestaurantLayer>)mealDelegate
{
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:inputView.bounds];
    [mapView autorelease];
    
    CLLocationManager *lManager = [[[CLLocationManager alloc] init] autorelease];
    lManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

    [lManager startUpdatingLocation];
    NSMutableDictionary *annotations = [NSMutableDictionary dictionary];
    
    MapViewManager *manager = [[MapViewManager alloc] initWithMapView:mapView 
                                                   andLocationManager:lManager
                                                      andMealDelegate:mealDelegate
                                                       andAnnotations:annotations];
    lManager.delegate            = manager;
    manager.receiverDelegate     = receiverCont;
    mealDelegate.displayDelegate = manager;
    [manager registerForNotifications];
    [manager autorelease];
    return manager;
}
@end
