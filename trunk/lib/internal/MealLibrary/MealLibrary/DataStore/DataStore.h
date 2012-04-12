//
//  DataStore.h
//  TestingExample
//
//  Created by sebbecai on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Restaurant.h"

@protocol DataStore <NSObject>
-(void) seedDataStore;
-(void) clearWorkingData;
-(void) replaceStaticApplicationData;
@end

@protocol FoodDataStore <NSObject>
-(NSArray *) getAllMenuItemsForRestaurant:(id<Restaurant>)store andDiet:(NSArray *)diet;
@end

@interface DataStore : NSObject <DataStore, FoodDataStore>
{
    NSURL    *_applicationDocumentsDirectory;
    NSURL    *_chainNutrition;
    NSString *_datastoreName;
}
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark Create/Destroy
+(id<DataStore, FoodDataStore>) create;
+(id<DataStore, FoodDataStore>) createForTest;

#pragma mark Storage Info
-(NSURL *)storeURL;
@end


