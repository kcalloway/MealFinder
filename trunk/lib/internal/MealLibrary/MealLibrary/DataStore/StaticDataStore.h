//
//  StaticDataStore.h
//  MealLibrary
//
//  Created by sebbecai on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStore.h"

@interface StaticDataStore : NSObject <StaticDataStore> {
    NSURL    *_applicationDocumentsDirectory;
    NSURL    *_csvSeedInput;
    NSString *_datastoreName;

    int       _numCSVColumns;
    
    id<DataStore> dataStoreDelegate;
}
@property (assign) id<DataStore> dataStoreDelegate;
-(NSURL *)storeURL;

+(id<StaticDataStore>) createWithDocsDirectory:(NSURL *) docs andCSVURL:(NSURL *) csvURL andDatastoreName:(NSString *)datastoreName;
@end
