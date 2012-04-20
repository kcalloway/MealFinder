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

@interface NSString (ParsingExtensions)
-(NSArray *)csvRows;
@end

@protocol FoodDataStore <NSObject>
-(NSArray *) getAllMenuItemsForRestaurant:(id<Restaurant>)store andDiet:(NSArray *)diet;
@end

@protocol DataStore <NSObject, FoodDataStore>
-(void) seedDataStore;
-(void) clearWorkingData;
-(void) replaceStaticApplicationData;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@protocol StaticDataStore <NSObject>
-(void) seedDataStore;
-(void) clearWorkingData;
-(void) replaceStaticApplicationData;
-(NSURL *)storeURL;
@property (assign) id<DataStore> dataStoreDelegate;
@end

@interface DataStore : NSObject <DataStore, FoodDataStore>
{
    NSURL    *_applicationDocumentsDirectory;
    NSURL    *_chainNutrition;
    NSString *_datastoreName;
    id<StaticDataStore> _staticDataStore;
}
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark Create/Destroy
+(id<DataStore, FoodDataStore>) create;
+(id<DataStore>) createForTestWithCSV:(NSString *)csvName;
@end


