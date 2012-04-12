//
//  JSONConnection.h
//  RestaurantFinder
//
//  Created by sebbecai on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONObjectConverter.h"
#import "BatchTask.h"

@protocol JSONConnection <NSObject, IndividualTask>
@end

@protocol ConnectionDelegate <NSObject>
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end

@interface JSONConnection : NSObject <JSONConnection, ConnectionDelegate> {
    NSURL           *_targetURL;
    NSURLConnection *_connection;
    NSURLRequest    *_request;
    NSMutableData   *_receivedData;
    
    BOOL            _started;
    BOOL            _completed;

    id<JSONObjectConverter>  _jsonConverter;
    id<BatchTaskDelegate> _processDelegate;
}

@property (assign) id<BatchTaskDelegate> taskDelegate;

#pragma mark Create/Destroy
- (id)initWithRequest:(NSURLRequest *) request
        andConnection:(NSURLConnection *) connection
      andReceivedData:(NSMutableData *) recievedData
           andStarted:(BOOL) started
         andCompleted:(BOOL) completed
               andURL:(NSURL *) url
         andConverter:(id<JSONObjectConverter>) converter;

+(id<JSONConnection, ConnectionDelegate>) createWithURL:(NSURL *) url;

@end
