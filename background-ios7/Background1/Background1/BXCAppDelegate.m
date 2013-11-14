//
//  BXCAppDelegate.m
//  Background1
//
//  Created by Mickaël Rémond on 14/11/13.
//  Copyright (c) 2013 Mickaël Rémond. All rights reserved.
//

#import "BXCAppDelegate.h"

@implementation BXCAppDelegate

//Multitasking
UIBackgroundTaskIdentifier background_task;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //background_task = UIBackgroundTaskInvalid;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        NSLog(@"Multitasking Supported");
        if (background_task == UIBackgroundTaskInvalid) {
            background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
                
                NSLog(@"Background task expiration\n");
                //Clean up code. Tell the system that we are done.
                [application endBackgroundTask: background_task];
                background_task = UIBackgroundTaskInvalid;
            }];
            
            //To make the code block asynchronous
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //### background task starts
                NSLog(@"Running in the background\n");
                while(TRUE)
                {
                    NSLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
                    [NSThread sleepForTimeInterval:1]; //wait for 1 sec
                }
                //#### background task ends
                
                //Clean up code. Tell the system that we are done.
                [application endBackgroundTask: background_task];
                background_task = UIBackgroundTaskInvalid;
            });
        }
        else
        {
            NSLog(@"Multitasking Not Supported");
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
