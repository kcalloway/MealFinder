//
//  GraphSearch.h
//  MealLibrary
//
//  Created by sebbecai on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SortedSet.h"

@protocol GraphNode <NSObject>
-(BOOL)isEqualToNode:(id<GraphNode>)otherNode;
-(NSNumber *)costToNode:(id<GraphNode>)otherNode;
-(NSNumber *)heuristicEstimateToNode:(id<GraphNode>)otherNode;
-(NSArray *)neighborNodes;
@property (readonly) NSString *uniqueId;
@end

@protocol GraphSearch <NSObject>
-(NSArray *)pathForStart:(id<GraphNode>)startNode andGoal:(id<GraphNode>)goalNode;
@end

@interface GraphSearch : NSObject<GraphSearch> {
    SortedSet   *_open;

    NSMutableSet        *_closed;
    NSMutableDictionary *_prevNode;
    
    NSMutableDictionary *_gScore;
    NSMutableDictionary *_hScore;
    NSMutableDictionary *_fScore;
}

+(id<GraphSearch>)createAStar;
@end

