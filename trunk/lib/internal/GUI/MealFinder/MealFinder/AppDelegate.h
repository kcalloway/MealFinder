//
//  AppDelegate.h
//  MealFinder
//
//  Created by sebbecai on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigurationController.h"

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    ConfigurationController *_configCont;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *mainViewController;

@end
