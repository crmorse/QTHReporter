//
//  AppDelegate.m
//  Read JSON
//
//  Created by TAMIM Ziad on 8/16/13.
//  Copyright (c) 2013 TAMIM Ziad. All rights reserved.
//

#import "AppDelegate.h"

#import "OQLocationManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    __unused id dummy = [OQLocationManager sharedOQLocationManager]; //make sure CL registers

    return YES;
}

@end
