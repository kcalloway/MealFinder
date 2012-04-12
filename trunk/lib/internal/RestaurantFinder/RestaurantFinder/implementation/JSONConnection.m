//
//  JSONConnection.m
//  RestaurantFinder
//
//  Created by sebbecai on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JSONConnection.h"
#define JSON_CONN_TIMEOUT   60.0

@implementation JSONConnection
@synthesize taskDelegate;

#pragma mark JSONConnection
-(void)start
{
    // Create the request.
    if (!_started) {
        [_request initWithURL:_targetURL
                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                 timeoutInterval:JSON_CONN_TIMEOUT];
        
        // Starts the connection on a separate thread
        [_connection initWithRequest:_request delegate:self];
        if (!_connection) {
            // Inform the user that the connection failed.
        }    
    }
    _started = YES;
}

-(void)cancel
{
    if (_started) {
        [_connection cancel];
        _completed = YES;
    }
}

-(BOOL)done
{
    return _completed;
}

#pragma mark ConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    _completed = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSError *error = nil;
    NSArray *convertedObjects =[_jsonConverter objectsForData:_receivedData error:&error];
    [taskDelegate processResultData:convertedObjects];
    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
}

#pragma mark Create/Destroy
- (id)initWithRequest:(NSURLRequest *) request
        andConnection:(NSURLConnection *) connection
      andReceivedData:(NSMutableData *) recievedData
           andStarted:(BOOL) started
         andCompleted:(BOOL) completed
               andURL:(NSURL *) url
         andConverter:(id<JSONObjectConverter>) converter
{
    self = [super init];
    if (self) {
        _request       = request;
        _connection    = connection;
        _receivedData  = recievedData;
        _targetURL     = url;
        _started       = started;
        _completed     = completed;
        _jsonConverter = converter;

        [_request       retain];
        [_connection    retain];
        [_receivedData  retain];
        [_targetURL     retain];
        [_jsonConverter retain];
    }

    return self;
}

+(id<JSONConnection, ConnectionDelegate>) createWithURL:(NSURL *) url
{
    NSURLRequest    *request       = [NSURLRequest alloc];
    NSURLConnection *urlConnection = [NSURLConnection alloc];
    NSMutableData   *receivedData  = [NSMutableData data];
    
    id<JSONObjectConverter> converter = [JSONObjectConverter create];

    JSONConnection *connection = [[JSONConnection alloc] initWithRequest:request
                                                           andConnection:urlConnection 
                                                         andReceivedData:receivedData 
                                                              andStarted:NO
                                                            andCompleted:NO 
                                                                  andURL:url 
                                                            andConverter:converter];
    [request release];
    [urlConnection release];
    [connection autorelease];
    return connection;
}

-(void) dealloc
{
    [_targetURL     release];
    [_request       release];
    [_connection    release];
    [_receivedData  release];    
    [_jsonConverter release];

    [super dealloc];
}
@end
