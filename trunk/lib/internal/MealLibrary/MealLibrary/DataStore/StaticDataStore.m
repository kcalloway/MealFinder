//
//  StaticDataStore.m
//  MealLibrary
//
//  Created by sebbecai on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StaticDataStore.h"
#import "DataStoreSeed.h"

@implementation StaticDataStore
@synthesize dataStoreDelegate;

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

-(NSURL *)storeURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:_datastoreName];
}
#pragma mark DataStore helper methods
-(BOOL) hasWorkingData
{
    NSFileManager *fmanager = [NSFileManager defaultManager];
    return [fmanager fileExistsAtPath:[self.storeURL path]];
}

#pragma mark DataStoreSeeding
- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName expectedColumns:(int) numColumns
              error:(NSError **)outError 
{    
    NSString *fileString = [NSString stringWithContentsOfURL:absoluteURL 
                                                    encoding:NSUTF8StringEncoding error:outError];
    if ( nil == fileString ) return NO;
    
    NSArray *csvData = [fileString csvRows];
    
    id<DataStoreSeed> newObject;
    NSMutableArray   *allObjects = [NSMutableArray arrayWithCapacity:[csvData count]];
    BOOL              seenHeader = FALSE;
    for (NSArray *csvRow in csvData)
    {
        if (!seenHeader) {
            seenHeader = TRUE;
            continue;
        }
        NSLog(@"%@\n", csvRow);
        if ([csvRow count] == numColumns) {
            newObject = [NSEntityDescription
                         insertNewObjectForEntityForName:typeName 
                         inManagedObjectContext:dataStoreDelegate.managedObjectContext];
            
            [newObject setValuesForArr:csvRow];
            [allObjects addObject:newObject];
        }
        NSError *error = nil;
        if (![dataStoreDelegate.managedObjectContext save:&error]) {
#warning Gotta address possible errors here
            // Handle the error.
        }
        
    }
    return YES;
}

#pragma mark DataStore
-(void) seedDataStore
{
    // If there is a datastore that the previous location, detroy it!
    NSFileManager *fmanager = [NSFileManager defaultManager];
    if ([fmanager fileExistsAtPath:[[self storeURL] path]])
	{
        NSError *error = nil;
        if (![fmanager removeItemAtURL:[self storeURL] error:&error])	//Delete it
		{
#warning handle this delete error
			NSLog(@"Delete file error: %@", error);
		}
    }
    
    [self readFromURL:_csvSeedInput ofType:@"MenuItem" expectedColumns:_numCSVColumns error:nil];
}

-(void) clearWorkingData
{
    NSFileManager *fmanager = [NSFileManager defaultManager];
    NSString *workingPath = [[self applicationDocumentsDirectory] path];
    
    
    if ([fmanager fileExistsAtPath:workingPath]) 
    {
    }
    
    // If the file exists
    NSError *error = nil;
    if ([self hasWorkingData]) {
        [fmanager removeItemAtURL:self.storeURL error:&error];
        if (error) {
            NSLog(@"Error destroying file at %@ (%@)", [self.storeURL path], error);
        }
    }
}

-(void) replaceStaticApplicationData
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleStoreURL = [bundle URLForResource:@"MealLibrary" withExtension:@"sqlite"];
    
    NSString *workingPath = [[self applicationDocumentsDirectory] path];
    NSString *storePath = [[self storeURL] path];
    
    NSError *error = nil;
    NSFileManager *fmanager = [NSFileManager defaultManager];
    if ([fmanager fileExistsAtPath:[bundleStoreURL path]])
    {
        // If the path does not exist
        if (![fmanager fileExistsAtPath:workingPath]) 
        {
            [fmanager createDirectoryAtPath:workingPath withIntermediateDirectories:NO attributes:nil error:&error];
            
            if (error) {
                NSLog(@"Error creating directory at %@ (%@)", storePath, error);
            }
        }
        
        if ([fmanager fileExistsAtPath:storePath]) {
            [fmanager removeItemAtURL:self.storeURL error:&error];
            if (error) {
                NSLog(@"Error destroying file at %@ (%@)", storePath, error);
            }
        }
        
        if (![fmanager fileExistsAtPath:storePath]) {
            [fmanager copyItemAtURL:bundleStoreURL toURL:[self storeURL] error:&error];
            if (error) {
                NSLog(@"Error copying default DB to %@ (%@)", storePath, error);
            }
        }
    }
}

#pragma mark Create/Destroy
- (id)initWithDocsDirectory:(NSURL *) docs andCSVURL:(NSURL *) csvURL andDatastoreName:(NSString *)datastoreName
{
    self = [super init];
    if (self) {
        _applicationDocumentsDirectory = docs;
        _csvSeedInput                  = csvURL;
        _datastoreName                 = datastoreName;
        _numCSVColumns = 9;
        
        [_applicationDocumentsDirectory retain];
        [_csvSeedInput                  retain];
        [_datastoreName                 retain];
    }
    
    return self;
}

-(void)dealloc
{
    [_applicationDocumentsDirectory release];
    [_csvSeedInput                  release];
    [_datastoreName                 release];
    
    [super dealloc];
}

-(void) checkCreatePreconditions
{
    NSFileManager *fmanager = [NSFileManager defaultManager];
    if (![fmanager fileExistsAtPath:[_csvSeedInput path]])
	{
        [NSException raise:NSDestinationInvalidException 
                    format:@"_csvSeedInput URL is invalid"];
    }
}

+(id<StaticDataStore>) createWithDocsDirectory:(NSURL *)docs
                                     andCSVURL:(NSURL *)csvURL
                              andDatastoreName:(NSString *)datastoreName
{
    StaticDataStore *result = [[StaticDataStore alloc] initWithDocsDirectory:[StaticDataStore applicationDocumentsDirectory] andCSVURL:csvURL andDatastoreName:datastoreName];
    [result checkCreatePreconditions];

    NSFileManager *fmanager = [NSFileManager defaultManager];
    if (![fmanager fileExistsAtPath:[result storeURL].path])
    {
        [result replaceStaticApplicationData];
    }
    [result autorelease];
    return result;
}

@end
