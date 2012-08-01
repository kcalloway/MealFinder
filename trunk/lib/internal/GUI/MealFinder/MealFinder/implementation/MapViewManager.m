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

#define METERS_PER_MILE     1600
#define MILES_DEFAULT       2
#define SIG_ZOOM_MULT       3
#define MAX_LOCATION_AGE    5.0f

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
    annotation.viewDelegate = pinView;
    [pinView setAlpha:1.0];

    return pinView;
}

#pragma mark MealStuff
-(void)addNewRestaurantMeals:(NSArray *)meals
{
//    [self addAnnotationsForArray:meals];
}

-(void)locationAdded:(NSNotification *)caughtNotification
{
//    CLLocation *centerLocation = [[CLLocation alloc] 
//                                  initWithLatitude:[_mapView centerCoordinate].latitude 
//                                  longitude:[_mapView centerCoordinate].longitude];
//    [centerLocation autorelease];
    NSArray *annotations = [[caughtNotification userInfo] objectForKey:[MealRestaurantLayer userInfoAnnotationKey]];

    NSLog(@"annotations = %@\n",annotations);
    [self addAnnotationsForArray:annotations];
}

-(void)locationChanged:(NSDictionary *)changed
{
}

-(void)locationRemoved:(NSNotification *)caughtNotification
{
    NSArray *locationIdArr = [[caughtNotification userInfo] objectForKey:[MealRestaurantLayer userInfoDataKey]];
    
    for (NSString *locationId in locationIdArr) {
        for (StoreAnnotation *ann in [_annotations objectForKey:locationId]) {            
            AnimationCompleteBlock removalBlock = ^(BOOL finished) {
                if (finished) {
                    [_mapView removeAnnotation:ann];
                }
            };
            [ann removeWithAnimationCompleteBlock:removalBlock];
        }
        [_annotations removeObjectForKey:locationId];
    }
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    if (oldLocation && locationAge < MAX_LOCATION_AGE) {        
        // we have a measurement that meets our requirements, so we can stop updating the location
        // 
        // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
        //
        [locationManager stopUpdatingLocation];
        
        // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];

        [receiverDelegate shouldUpdateMapView:YES];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [locationManager startUpdatingLocation];
}

#pragma mark MKMapViewDelegateMapStuff
-(BOOL)zoomOutIsSignificantForSpan:(MKCoordinateSpan)span
{
    float spanArea = span.longitudeDelta * span.latitudeDelta;
    if (spanArea > _prevSpanArea*SIG_ZOOM_MULT) {
        return YES;
    }
    return NO;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    BOOL hasSignificantDist = [self 
                               prevLocationIsSignificantlyFarFromLoc:[self centerLocation]];

    BOOL hasSignificantZoom = [self 
                               zoomOutIsSignificantForSpan:mapView.region.span];

    [receiverDelegate setCanUpdateLocation:hasSignificantDist];
    [receiverDelegate setCanUpdateAnnotations:(hasSignificantDist || hasSignificantZoom)];
}

-(float)milesFromMeters:(int)numMeters
{
    return ((float)numMeters)/((float)METERS_PER_MILE);
}

-(BOOL)shouldUpdateAnnotationsForLocation:(CLLocation *)newLocation 
                             fromLocation:(CLLocation *)oldLocation
{
    CLLocationDistance locDistance = [newLocation 
                                      distanceFromLocation:oldLocation];

    if ([self milesFromMeters:locDistance] > MILES_DEFAULT) {        
        return YES;
    }
    return NO;
}

-(BOOL)prevLocationIsSignificantlyFarFromLoc:(CLLocation *)newLocation
{
    CLLocationDistance locDistance = [newLocation distanceFromLocation:_curAnnotationCenter];

    if ([self milesFromMeters:locDistance] > MILES_DEFAULT) {
        return YES;
    }

    return NO;
}

-(BOOL)shouldUpdateLocations
{
    CLLocation *centerLocation = [[CLLocation alloc] 
                                  initWithLatitude:[_mapView centerCoordinate].latitude 
                                  longitude:[_mapView centerCoordinate].longitude];
    [centerLocation autorelease];
    return [self prevLocationIsSignificantlyFarFromLoc:centerLocation];
}

-(void)updateAnnotationCenter:(CLLocation *)newLocation
{
    [_curAnnotationCenter release];
    _curAnnotationCenter = newLocation; 
     [_curAnnotationCenter retain];
}

-(void)setUserRegionForLocation:(CLLocation *)newLocation
{
    int metersDistance = MILES_DEFAULT*METERS_PER_MILE;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([newLocation coordinate], metersDistance, metersDistance);
    
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];                
    
    [_mapView setRegion:adjustedRegion animated:TRUE];
}

-(void)refreshAnnotations
{
    int metersDistance = MILES_DEFAULT*METERS_PER_MILE;

    NSLog(@"%f %f %d\n", _mapView.centerCoordinate.latitude, _mapView.centerCoordinate.longitude, metersDistance);
    [mealDelegate findMealsForLocation:_mapView.centerCoordinate
                             andMeters:metersDistance];
    
    MKCoordinateSpan span = _mapView.region.span;
    _prevSpanArea = span.longitudeDelta * span.latitudeDelta;
}

-(CLLocation *)myLocation
{
    return [locationManager location];    
}

-(CLLocation *)centerLocation
{
    CLLocation *loc = [[CLLocation alloc] 
                       initWithLatitude:_mapView.centerCoordinate.latitude
                       longitude:_mapView.centerCoordinate.longitude];
    return loc;
}

-(void)setLocation:(CLLocation *)location
{
    [self updateAnnotationCenter:location];
    [self setUserRegionForLocation:location];    
}

-(void)setMeterRange:(int)meterRange
{  
}

-(void)configureMap
{
    // Set the map type such as Standard, Satellite, Hybrid
	_mapView.mapType = MKMapTypeStandard;
    
    // Config user interactions
	_mapView.zoomEnabled = YES;
	_mapView.scrollEnabled = YES;

	_mapView.delegate = self;
    
    // Show the user's location
    _mapView.showsUserLocation = YES;
}

-(MKMapView *) loadMapOnView:(UIView *)view
{
    MKMapView *resultMap = [[MKMapView alloc] initWithFrame:view.bounds];
    [resultMap autorelease];
    
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
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
    [manager configureMap];
    [manager autorelease];
    return manager;
}
@end
