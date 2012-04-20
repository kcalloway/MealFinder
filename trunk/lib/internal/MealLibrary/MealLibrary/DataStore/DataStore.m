//
//  DataStore.m
//  TestingExample
//
//  Created by sebbecai on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DataStore.h"
#import "DataStoreSeed.h"
#import "DietaryConstraint.h"
#import "StaticDataStore.h"

#define NUM_COLUMNS 9


@implementation NSString (ParsingExtensions)

-(NSArray *)csvRows {
    NSMutableArray *rows = [NSMutableArray array];
    
    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
    
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
    
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {        
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
            
            if ( [scanner isAtEnd] ) {
                if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""]; 
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) {  
                if ( insideQuotes ) {
                    [currentColumn appendString:@","];
                }
                else {
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }
    
    return rows;
}

@end

@interface DataStore () 
- (NSURL *)applicationDocumentsDirectory;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation DataStore
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

#pragma mark FoodDataStore
-(NSMutableArray *) getSubPredicatesForDiet:(NSArray*)diet
{
    NSMutableArray *subPredicates = [NSMutableArray array];    
    NSPredicate *curPredicate;
    for (id<DietaryConstraint> constraint in diet) {
        if ([constraint conformsToProtocol:@protocol(QuantitativeDietaryConstraint)]) {
            id<QuantitativeDietaryConstraint> quantConstraint = (id<QuantitativeDietaryConstraint>) constraint;
            NSExpression *lhs, *rhs;
            lhs = [NSExpression expressionForKeyPath:quantConstraint.selectorName];
            rhs = [NSExpression expressionForConstantValue:[NSNumber numberWithInt:quantConstraint.maxValue]];
            curPredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier type:NSLessThanOrEqualToPredicateOperatorType options:0];
            [subPredicates addObject:curPredicate];
        }
        else 
        if ([constraint conformsToProtocol:@protocol(QualitativeDietaryConstraint)]) {
            id<QualitativeDietaryConstraint> qualConstraint = (id<QualitativeDietaryConstraint>) constraint;
            if (qualConstraint.enabled) {
                curPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
                                qualConstraint.selectorName, [qualConstraint expectedValue]];
                
                [subPredicates addObject:curPredicate];
            }
        }
    }

    return subPredicates;
}

-(NSArray *) getAllMenuItemsForRestaurant:(id<Restaurant>)store andDiet:(NSArray *)diet
{
    NSFetchRequest *request       = [[NSFetchRequest alloc] init];
    NSPredicate    *restaurantId  = [NSPredicate predicateWithFormat:@"restaurantId like %@", store.uniqueId];
    NSMutableArray *subPredicates = [self getSubPredicatesForDiet:diet];
    
    [subPredicates addObject:restaurantId];
    [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:subPredicates]];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    return mutableFetchResults;
    
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }

    __managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]]] retain];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    //    [self replaceStaticApplicationData];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[_staticDataStore storeURL] options:nil error:&error])
    {
#warning We need to address this error
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory
/**
 Returns the URL to the application's Documents directory.
 */
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationDocumentsDirectory
{
    return _applicationDocumentsDirectory;
}

#pragma mark StaticDataStore
-(void) seedDataStore
{
    [_staticDataStore seedDataStore];
}
-(void) clearWorkingData
{
    [_staticDataStore clearWorkingData];
}
-(void) replaceStaticApplicationData
{
    [_staticDataStore replaceStaticApplicationData];
}
#pragma mark Create/Destroy
-(void) checkCreatePreconditions
{
    NSFileManager *fmanager = [NSFileManager defaultManager];
    if (![fmanager fileExistsAtPath:[_chainNutrition path]])
	{
        [NSException raise:NSDestinationInvalidException 
                    format:@"_chainNutrition URL is invalid"];
    }
}

- (id)initWithDocsDirectory:(NSURL *) docs andChainURL:(NSURL *) chainURL andDatastoreName:datastoreName
{
    self = [super init];
    if (self) {
        _applicationDocumentsDirectory = docs;
        _chainNutrition = chainURL;
        _datastoreName  = datastoreName;
        
        
        [_applicationDocumentsDirectory retain];
        [_chainNutrition                retain];
        [_datastoreName                 retain];
    }

    return self;
}

- (id)initWithDocsDirectory:(NSURL *) docs andChainURL:(NSURL *) chainURL andDatastoreName:datastoreName andStaticDataStore:(id<StaticDataStore>)staticDataStore
{
    self = [super init];
    if (self) {
        _applicationDocumentsDirectory = docs;
        _chainNutrition  = chainURL;
        _datastoreName   = datastoreName;
        _staticDataStore = staticDataStore;


        [_applicationDocumentsDirectory retain];
        [_chainNutrition                retain];
        [_datastoreName                 retain];
        [_staticDataStore               retain];
    }
    
    return self;
}

-(void)dealloc
{
    [_applicationDocumentsDirectory release];
    [_chainNutrition                release];
    [_datastoreName                 release];
    [_staticDataStore               release];

    [super dealloc];
}

+(id<DataStore>) create
{
    NSURL *chainURL = [[NSBundle mainBundle] URLForResource:@"chain_nutrition" withExtension:@"csv"];
    NSString *datastoreName = @"MealLibrary.sqlite";
    id<StaticDataStore> staticDataStore = [StaticDataStore createWithDocsDirectory:[DataStore applicationDocumentsDirectory] andCSVURL:chainURL andDatastoreName:datastoreName];
    DataStore *result = [[DataStore alloc]
                              initWithDocsDirectory:[DataStore applicationDocumentsDirectory] 
                              andChainURL:chainURL
                              andDatastoreName:datastoreName andStaticDataStore:staticDataStore];
    staticDataStore.dataStoreDelegate = result;
    [result checkCreatePreconditions];
    [result autorelease];
    return result;
}

+(id<DataStore>) createForTestWithCSV:(NSString *)csvName
{
    NSURL *chainURL = [[NSBundle bundleForClass:[self class]] URLForResource:csvName withExtension:@"csv"];
    
    NSString *datastoreName = @"MealLibrary.sqlite";
    id<StaticDataStore> staticDataStore = [StaticDataStore createWithDocsDirectory:[DataStore applicationDocumentsDirectory] andCSVURL:chainURL andDatastoreName:datastoreName];
    
    DataStore *result = [[DataStore alloc]
                         initWithDocsDirectory:[DataStore applicationDocumentsDirectory] 
                         andChainURL:chainURL
                         andDatastoreName:datastoreName andStaticDataStore:staticDataStore];
    staticDataStore.dataStoreDelegate = result;
    [result checkCreatePreconditions];
    
    [result autorelease];
    return result;
}
@end
