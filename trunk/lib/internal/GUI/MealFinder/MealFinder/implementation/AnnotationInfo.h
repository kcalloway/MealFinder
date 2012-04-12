//
//  AnnotationInfo.h
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AnnotationInfo <NSObject>
@property (readonly) NSString *title;
@property (readonly) NSString *subtitle;
@property (readonly) NSString *identifier;
@property (readonly) NSString *latitude;
@property (readonly) NSString *longitude;

@end
