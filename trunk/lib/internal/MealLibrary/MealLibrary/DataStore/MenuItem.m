//
//  MenuItem.m
//  MealLibrary
//
//  Created by sebbecai on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuItem.h"

static NSMutableDictionary *condimentCategoryDict   = nil;

@implementation MenuItem
@dynamic name;
@dynamic kcal;
@dynamic restaurantId;
@dynamic isMeal;
@dynamic isVegan;
@dynamic isVegetarian;
@dynamic cholesterol;
@dynamic sodium;
@dynamic carbs;
@dynamic isEntree;
@dynamic isSide;

@dynamic isDessert;
@dynamic isBreakfast;
@dynamic potentialCondiments;
@dynamic condimentCategories;

@dynamic uniqueId;

-(NSString *)uniqueId
{
    return [NSString stringWithFormat:@"%@:%@",self.restaurantId,self.name];
}

- (NSComparisonResult)compare:(id<MenuItem>)otherObject 
{
    return [self.uniqueId localizedCaseInsensitiveCompare:otherObject.uniqueId];
}

-(void)setupDictsForRestaurant:(NSString *)restName
{
    if (condimentCategoryDict == nil) {
        condimentCategoryDict = [NSMutableDictionary dictionary];
        [condimentCategoryDict retain];
    }
    
    if ([condimentCategoryDict objectForKey:restName] == nil) {
        [condimentCategoryDict setObject:[NSMutableArray array] forKey:restName];
    }
}

-(void)updateCondimentCategoryDictWithSet:(NSSet *)seenCondiments
{
    NSMutableArray *curCondiments = [condimentCategoryDict objectForKey:self.restaurantId];

    for (NSString *condiment in seenCondiments) {
        if (![curCondiments containsObject:condiment]) {
            [curCondiments addObject:condiment];
        }        
    }
}

-(void)setValuesForArr:(NSArray *)stringArr
{
    [self setRestaurantId:[stringArr objectAtIndex:0]];
    [self setupDictsForRestaurant:self.restaurantId];
    [self setName:[stringArr objectAtIndex:1]];
    
    NSString *roles = [stringArr objectAtIndex:2];
    NSMutableSet *condimentCategories = [NSMutableSet set];
    NSMutableSet *potentialCondiments = [NSMutableSet set];

    NSArray *roleStrs = [roles componentsSeparatedByString:@"/"];
    for (NSString *role in roleStrs) {
        if ([role isEqualToString:@"meal"]) {
            [self setIsMeal:[NSNumber numberWithBool:YES]];
        }

        if ([role isEqualToString:@"side"]) {
            [self setIsSide:[NSNumber numberWithBool:YES]];
        }
        
        if ([role isEqualToString:@"entree"]) {
            [self setIsEntree:[NSNumber numberWithBool:YES]];
        }
        
        if ([role isEqualToString:@"dessert"]) {
            [self setIsDessert:[NSNumber numberWithBool:YES]];
        }
        
        if ([role isEqualToString:@"breakfast"]) {
            [self setIsBreakfast:[NSNumber numberWithBool:YES]];
        }
        
        NSArray *condimentStrs = [role componentsSeparatedByString:@":"];
        if ([condimentStrs count] == 2) {
            NSString *first  = [condimentStrs objectAtIndex:0];
            NSString *second = [condimentStrs objectAtIndex:1];
            
            if ([first isEqualToString:@"topper"]) {
                [potentialCondiments addObject:second];
            }
            else {
                [condimentCategories addObject:second];
            }
        }
    }
    
    [self updateCondimentCategoryDictWithSet:condimentCategories];
    [self updateCondimentCategoryDictWithSet:potentialCondiments];
    NSMutableSet *restaurantCondimentCategories = [condimentCategoryDict objectForKey:self.restaurantId];
    // We'll create a bitmask that represents whether or not a menuItem is 
    // compatible with a given condiment.  We won't know that TYPE of condiment
    // we're dealing with, but we will know what it's compatible with.
    uint curBit = 1;
    for (NSString *condiment in restaurantCondimentCategories) {
        if ([condimentCategories containsObject:condiment]) {
            condimentCategoriesMask |=  curBit;
        }
        if ([potentialCondiments containsObject:condiment]) {
            potentialCondimentsMask |=  curBit;
        }
        
        curBit = curBit << 1;
    }
    [self setCondimentCategories:[NSNumber numberWithInt:condimentCategoriesMask]];
    [self setPotentialCondiments:[NSNumber numberWithInt:potentialCondimentsMask]];

    [self setKcal:[NSNumber numberWithInt:[[stringArr objectAtIndex:3] intValue]]];
    [self setCholesterol:[NSNumber numberWithInt:[[stringArr objectAtIndex:4] intValue]]];
    [self setSodium:[NSNumber numberWithInt:[[stringArr objectAtIndex:5] intValue]]];
    [self setCarbs:[NSNumber numberWithInt:[[stringArr objectAtIndex:6] intValue]]];
    [self setIsVegetarian:[NSNumber numberWithInt:[[stringArr objectAtIndex:7] boolValue]]];
    [self setIsVegan:[NSNumber numberWithInt:[[stringArr objectAtIndex:8] boolValue]]];
}

@end
