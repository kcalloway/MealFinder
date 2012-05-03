//
//  GraphSearch.m
//  MealLibrary
//
//  Created by sebbecai on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphSearch.h"

@implementation GraphSearch

-(NSMutableArray *)reconstructPathFromNode:(id<GraphNode>)curNode
{
    NSMutableArray *path = [NSMutableArray array];
    if ([_prevNode objectForKey:[curNode uniqueId]]) {
        [path addObjectsFromArray:[self reconstructPathFromNode:[_prevNode objectForKey:[curNode uniqueId]]]];
    }

    [path addObject:curNode];    
    return path;
}

-(NSArray *)bestFirstPathForStart:(id<GraphNode>)startNode andGoal:(id<GraphNode>)goalNode
{
    if (startNode) {
        [_open addObject:startNode];
        [_gScore setObject:[NSNumber numberWithInt:0] forKey:[startNode uniqueId]];
        [_hScore setObject:[startNode heuristicEstimateToNode:goalNode] forKey:[startNode uniqueId]];
        int startFScore =  [[_gScore objectForKey:[startNode uniqueId]] intValue] + [[_hScore objectForKey:[startNode uniqueId]] intValue];
        [_fScore setObject:[NSNumber numberWithInt:startFScore] forKey:[startNode uniqueId]];
    }
    
    id<GraphNode> curNode = nil;
    while ([_open count]) {        
        curNode = [_open keyAtIndex:0];
        [_open   removeObject:curNode];
        [_closed addObject:curNode];

        if ([curNode isEqualToNode:goalNode]) {
            return [self reconstructPathFromNode:curNode];
        }

        for (id<GraphNode> neighborNode in [curNode neighborNodes]) {
//            if ([neighborNode isEqualToNode:goalNode]) {
//                return [self reconstructPathFromNode:curNode];
//            }

            if ([_closed containsObject:neighborNode] || [_prevNode objectForKey:[neighborNode uniqueId]]) {
                continue;            
            }
            
            if (![_open containsObject:neighborNode]) {
                [_hScore setObject:[neighborNode heuristicEstimateToNode:goalNode] forKey:[neighborNode uniqueId]];
                NSComparator compareStuff = ^(id<GraphNode> obj1, id<GraphNode> obj2) {
                    if ([[_hScore objectForKey:[obj1 uniqueId]] intValue] == [[_hScore objectForKey:[obj2 uniqueId]] intValue]) {
                        return NSOrderedSame;
                    }
                    else if ([[_hScore objectForKey:[obj1 uniqueId]] intValue] < [[_hScore objectForKey:[obj2 uniqueId]] intValue]) {
                        return NSOrderedAscending;
                    }

                    return NSOrderedDescending;
                };

                [_open addObject:neighborNode withComparator:compareStuff];
                [_prevNode setObject:curNode forKey:[neighborNode uniqueId]];
            }
        }
    }
    
    return nil;
}

-(NSArray *)aStarpathForStart:(id<GraphNode>)startNode andGoal:(id<GraphNode>)goalNode
{
    if (startNode) {
        [_open addObject:startNode];
        [_gScore setObject:[NSNumber numberWithInt:0] forKey:[startNode uniqueId]];
        [_hScore setObject:[startNode heuristicEstimateToNode:goalNode] forKey:[startNode uniqueId]];
        int startFScore =  [[_gScore objectForKey:[startNode uniqueId]] intValue] + [[_hScore objectForKey:[startNode uniqueId]] intValue];
        [_fScore setObject:[NSNumber numberWithInt:startFScore] forKey:[startNode uniqueId]];
    }

    id<GraphNode> curNode = nil;
    while ([_open count]) {        
        curNode = [_open keyAtIndex:0];
        [_open   removeObject:curNode];
        [_closed addObject:curNode];
        NSLog(@"%@ %d\n", curNode.uniqueId,  [[_fScore objectForKey:[curNode uniqueId]] intValue]);
        if ([curNode isEqualToNode:goalNode]) {
            return [self reconstructPathFromNode:curNode];
        }
        
        for (id<GraphNode> neighborNode in [curNode neighborNodes]) {
            if ([_closed containsObject:neighborNode] || [_prevNode objectForKey:[neighborNode uniqueId]]) {
                continue;            
            }
            
            int tentativeGScore = [[_gScore objectForKey:[curNode uniqueId]] intValue] + [[curNode costToNode:neighborNode] intValue];
            BOOL tentativeIsBetter;
            
            if (![_open containsObject:neighborNode]) {
                [_hScore setObject:[neighborNode heuristicEstimateToNode:goalNode] forKey:[neighborNode uniqueId]];
                NSComparator compareStuff = ^(id<GraphNode> obj1, id<GraphNode> obj2) {
                    if ([[_fScore objectForKey:[obj1 uniqueId]] intValue] == [[_fScore objectForKey:[obj2 uniqueId]] intValue]) {
                        return NSOrderedSame;
                    }
                    else if ([[_fScore objectForKey:[obj1 uniqueId]] intValue] < [[_fScore objectForKey:[obj2 uniqueId]] intValue]) {
                        return NSOrderedAscending;
                    }
                    return NSOrderedDescending;
                };
                [_open addObject:neighborNode withComparator:compareStuff];

                tentativeIsBetter = YES;
            }
            else if (tentativeGScore < [[_gScore objectForKey:[neighborNode uniqueId]] intValue]) {
                tentativeIsBetter = YES;
            }
            else {
                tentativeIsBetter = NO;
            }
            
            if (tentativeIsBetter) {
                [_prevNode setObject:curNode forKey:[neighborNode uniqueId]];
                [_gScore setObject:[NSNumber numberWithInt:tentativeGScore] forKey:[neighborNode uniqueId]];
                int newFScore = [[_gScore objectForKey:[neighborNode uniqueId]] intValue] + [[_hScore objectForKey:[neighborNode uniqueId]] intValue];
                [_fScore setObject:[NSNumber numberWithInt:newFScore] forKey:[neighborNode uniqueId]];
            }
        }
    }
    
    return nil;
}

-(NSArray *)pathForStart:(id<GraphNode>)startNode andGoal:(id<GraphNode>)goalNode
{
    return [self bestFirstPathForStart:startNode andGoal:goalNode];
}

#pragma mark Create/Destroy
-(id)initWithOpen:(SortedSet *)open andClosed:(NSMutableSet *)closed andPrev:(NSMutableDictionary *)prevNodes andGScore:(NSMutableDictionary *)gScore andHScore:(NSMutableDictionary *)hScore andFScore:(NSMutableDictionary *)fScore  
{
    self = [super init];
    
    if (self) {
        _open     = open;
        _closed   = closed;
        _prevNode = prevNodes;
        _gScore   = gScore;
        _hScore   = hScore;
        _fScore   = fScore;
        
        [_open     retain];
        [_closed   retain];
        [_prevNode retain];
        [_gScore   retain];
        [_hScore   retain];
        [_fScore   retain];
    }
    return self;
}

-(void)dealloc
{
    [_open     release];
    [_closed   release];
    [_prevNode release];
    [_gScore   release];
    [_hScore   release];
    [_fScore   release];

    [super dealloc];
}

+(id<GraphSearch>)createAStar
{
    NSMutableSet        *closed    = [NSMutableSet set];
    NSMutableDictionary *prevNodes = [NSMutableDictionary dictionary];
    NSMutableDictionary *gScore    = [NSMutableDictionary dictionary];
    NSMutableDictionary *hScore    = [NSMutableDictionary dictionary];
    NSMutableDictionary *fScore    = [NSMutableDictionary dictionary];
    
    SortedSet *open = [SortedSet set];
    GraphSearch *aStar = [[GraphSearch alloc] initWithOpen:open andClosed:closed andPrev:prevNodes andGScore:gScore andHScore:hScore andFScore:fScore];
    [aStar autorelease];

    return aStar;
}
@end

