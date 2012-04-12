//
//  RestaurantRequest.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestaurantRequest.h"

@interface NSString (NSString_Extensions)
- (NSString *)urlEncode;
@end
@implementation NSString (NSString_Extensions)
- (NSString *)urlEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || 
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end

NSString *GOOGLE_PLACES_API_KEY = @"AIzaSyBGSUuH2mhoD-zAUYb23D44kmSTpR038i0";

@implementation RestaurantRequest
-(NSURL *) url
{
    NSString *url = [NSString stringWithFormat:@"%@://%@/%@/%@?", _scheme, _domain, _subDomain, _format];
    NSArray  *parameterKeys = [_parameters allKeys];
    NSString *queryString   = @"";
    NSString *parameterString;
    BOOL hasLooped = NO;
    
    for (NSString *key in parameterKeys) {
        if (hasLooped) {
            queryString = [queryString stringByAppendingFormat:@"&"];            
        }
        hasLooped = YES;
        
        parameterString = [[_parameters objectForKey:key] urlEncode];
        if ([_urlEncodingBlacklist containsObject:key]) {
            parameterString = [_parameters objectForKey:key];
        }
        queryString = [queryString stringByAppendingFormat:@"%@=%@", key, parameterString];
    }
    
    url = [url stringByAppendingFormat:@"%@",queryString];

    return [NSURL URLWithString:url];
}

#pragma mark Create/Destroy
- (id)initWithScheme:(NSString *) scheme andDomain:(NSString *)domain andSubDomain:(NSString *)subDomain andFormat:(NSString *)format andParameters:(NSDictionary *)parameters andBlackList:(NSSet *)blackList
{
    self = [super init];
    if (self) {
        _scheme               = scheme;
        _domain               = domain;
        _subDomain            = subDomain;
        _format               = format;
        _parameters           = parameters;
        _urlEncodingBlacklist = blackList;
        
        [_scheme retain];
        [_domain retain];
        [_subDomain retain];
        [_format retain];
        [_parameters retain];
        [_urlEncodingBlacklist retain];
    }

    return self;
}

- (void)dealloc {
    [_scheme release];
    [_domain release];
    [_subDomain release];
    [_format release];
    [_parameters release];
    [_urlEncodingBlacklist release];
    
    [super dealloc];
}

+(id<URLWrapper>) createWithLatitude:(NSString *) latitude 
                        andLongitude:(NSString *) longitude 
                           andRadius:(NSString *) radius 
                           andApiKey:(NSString *) apiKey 
                            andIsGPS:(BOOL) isGps 
                          andHasName:(NSString *) restaurantName
{
    NSString *location = [NSString stringWithFormat:@"%@,%@", latitude, longitude];
    NSString *sensor   = (isGps) ? @"true" : @"false";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:apiKey forKey:@"key"];
    [parameters setObject:location forKey:@"location"];
    [parameters setObject:radius forKey:@"radius"];
    [parameters setObject:sensor forKey:@"sensor"];
    [parameters setObject:@"food" forKey:@"types"];
    [parameters setObject:restaurantName forKey:@"name"];
    
    NSSet *urlEncodingBlacklist = [NSSet setWithObject:@"location"];
    
    id<URLWrapper> request = [[RestaurantRequest alloc] initWithScheme:@"https" 
                                                                    andDomain:@"maps.googleapis.com"
                                                                 andSubDomain:@"maps/api/place/search"
                                                                    andFormat:@"json"
                                                                andParameters:parameters 
                                                                 andBlackList:urlEncodingBlacklist];
    [request autorelease];
    
    return request;
}

+(id<URLWrapper>) createWithLatitude:(NSString *) latitude 
                        andLongitude:(NSString *) longitude 
                           andRadius:(NSString *) radius 
                          andHasName:(NSString *) restaurantName
{
    return [RestaurantRequest createWithLatitude:latitude 
                                    andLongitude:longitude
                                       andRadius:radius
                                       andApiKey:GOOGLE_PLACES_API_KEY
                                        andIsGPS:YES 
                                      andHasName:restaurantName];
}

@end
