//
//  DietaryConstraint.m
//  MealLibrary
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DietaryConstraint.h"
#import "QualitativeDietaryConstraint.h"

@interface DietaryConstraint ()
@property (retain,readwrite) NSString *selectorName;
@end

@implementation DietaryConstraint
@synthesize selectorName;
@synthesize maxValue;

#pragma mark Create/Destroy
- (id)initWithMin:(int)min andMax:(int)max andSelectorName:(NSString *) selName
{
    self = [super init];
    if (self) {
        maxValue     = max;
        minValue     = min;
        selectorName = selName;
        [selectorName retain];
    }
    
    return self;
}

-(void) dealloc
{
    [selectorName release];
    [super dealloc];
}

+(NSMutableDictionary *)namesToConstraints
{
    NSMutableDictionary *constraints = [NSMutableDictionary dictionary];

    [constraints setObject:[DietaryConstraint createCaloricWithMax:1000]      forKey:@"Calories"];
    [constraints setObject:[DietaryConstraint createCarbohydrateWithMax:1000] forKey:@"Carbs"];
    [constraints setObject:[DietaryConstraint createSodiumWithMax:1000]       forKey:@"Sodium"];
    [constraints setObject:[DietaryConstraint createCholesterolWithMax:1000]  forKey:@"Cholesterol"];
    
    id<QualitativeDietaryConstraint> qualConstraint = [DietaryConstraint createVegetarian];
    qualConstraint.enabled = NO;
    [constraints setObject:qualConstraint  forKey:@"Vegetarian"];

    qualConstraint = [DietaryConstraint createVegan];
    qualConstraint.enabled = NO;
    [constraints setObject:qualConstraint forKey:@"Vegan"];

    return constraints;
}

+(NSMutableArray *)quantitativeNames
{
    NSMutableArray *names = [NSMutableArray array];
    [names addObject:@"Calories"];
    [names addObject:@"Carbs"];
    [names addObject:@"Sodium"];
    [names addObject:@"Cholesterol"];

    return names;
}

+(id<QuantitativeDietaryConstraint>) createCaloricWithMax:(int)maxCalories
{
    DietaryConstraint *caloric = [[DietaryConstraint alloc] initWithMin:0 andMax:maxCalories andSelectorName:@"kcal"];
    [caloric autorelease];
    return caloric;
}

+(id<QuantitativeDietaryConstraint>) createCarbohydrateWithMax:(int)maxCarbs
{
    DietaryConstraint *carbs = [[DietaryConstraint alloc] initWithMin:0 andMax:maxCarbs andSelectorName:@"carbs"];
    [carbs autorelease];
    return carbs;
}

+(id<QuantitativeDietaryConstraint>) createSodiumWithMax:(int)maxSodium
{
    DietaryConstraint *constraint = [[DietaryConstraint alloc] initWithMin:0 andMax:maxSodium andSelectorName:@"sodium"];
    [constraint autorelease];
    return constraint;
}

+(id<QuantitativeDietaryConstraint>) createCholesterolWithMax:(int)maxChol
{
    DietaryConstraint *constraint = [[DietaryConstraint alloc] initWithMin:0 andMax:maxChol andSelectorName:@"cholesterol"];
    [constraint autorelease];
    return constraint; 
}

+(id<QualitativeDietaryConstraint>) createVegetarian
{
    QualitativeDietaryConstraint *constraint = [QualitativeDietaryConstraint createVegetarian];
    return constraint;
}

+(id<QualitativeDietaryConstraint>) createVegan
{
    QualitativeDietaryConstraint *constraint = [QualitativeDietaryConstraint createVegan];
    return constraint;
}



@end
