//
//  RestaurantRequest.h
//  RestaurantFinder
//
//  Created by sebbecai on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol URLWrapper <NSObject>
-(NSURL *) url;
@end

@interface RestaurantRequest : NSObject <URLWrapper>
{
    NSString     *_scheme;
    NSString     *_domain;
    NSString     *_subDomain;
    NSString     *_format;
    NSDictionary *_parameters;
    NSSet        *_urlEncodingBlacklist;
}

#pragma mark Create/Destroy
+(id<URLWrapper>) createWithLatitude:(NSString *) latitude 
                        andLongitude:(NSString *) longitude 
                           andRadius:(NSString *) radius 
                           andApiKey:(NSString *) apiKey 
                            andIsGPS:(BOOL) isGps 
                          andHasName:(NSString *) restaurantName;

+(id<URLWrapper>) createWithLatitude:(NSString *) latitude 
                        andLongitude:(NSString *) longitude 
                           andRadius:(NSString *) radius 
                          andHasName:(NSString *) restaurantName;
@end
